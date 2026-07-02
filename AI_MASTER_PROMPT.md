# Pingu Notes — Prompt-Mestre de IA

> Documento vivo que descreve **todos os aprimoramentos de IA** do Pingu Notes,
> a arquitetura para aplicá-los e o plano de execução. Serve como (1) spec de
> desenvolvimento e (2) base para o system prompt do chat "Pergunte ao Pingu".

## 1. Visão

Pingu Notes transforma texto, áudio, imagens e ideias em **conhecimento
organizado, estudável e reutilizável**. Fluxo: **Capturar → Organizar →
Relacionar → Revisar → Aprender → Expandir**. O app é **offline-first**: quando
um recurso de IA não está disponível (offline, sem chave, erro), o usuário é
avisado com clareza e caímos no modo heurístico local — **nunca em mock
silencioso**.

## 2. Princípio de arquitetura (não negociável)

Toda IA passa por **um único seam**: `IntelligenceService`
(`domain/services/intelligence_service.dart`). Para ligar IA real, criamos uma
nova implementação e trocamos **uma linha** no `service_locator.dart`. Nada mais
muda — a UI (`AskPinguPage`, `AudioRecorderWidget`, páginas de estudo) já está
conectada ao seam.

```
IntelligenceService (abstract)
 ├─ LocalIntelligenceService     ← heurístico, offline, JÁ EXISTE
 └─ CloudIntelligenceService     ← NOVO: Claude API (HTTP) + fallback local
      ├─ online + API key válida → Messages API (api.anthropic.com/v1/messages)
      └─ offline / sem key / erro → delega ao LocalIntelligenceService + avisa
```

### Regras do CloudIntelligenceService
- Recebe `LocalIntelligenceService` por injeção (é seu fallback).
- Verifica conectividade e presença da API key **antes** de cada chamada de rede.
- Em qualquer falha (timeout, 4xx/5xx, offline) → fallback local + flag para a UI
  exibir "resposta offline (IA em nuvem indisponível)".
- Faz o parse de JSON com `jsonDecode`, nunca por string-matching.
- Timeout de rede explícito; sem truncar conteúdo de notas silenciosamente.

## 3. Backend de texto — Claude API (HTTP puro)

Dart não tem SDK oficial → usamos `package:http` contra a Messages API.

- Endpoint: `POST https://api.anthropic.com/v1/messages`
- Headers: `x-api-key`, `anthropic-version: 2023-06-01`, `content-type: application/json`
- Modelos em camadas (custo/qualidade):
  - `claude-haiku-4-5` — tarefas leves por nota: **tags, detecção de tarefa, questões**.
  - `claude-opus-4-8` — alta qualidade: **chat, roadmap de aprendizado, lacunas, tradução/estilo**.
- `max_tokens`: ~1024 para respostas curtas; ~4096 para chat/roadmap.
- Saída estruturada: usar `output_config.format` (json_schema) para métodos que
  retornam listas/objetos (tags, questões, roadmap), evitando parsing frágil.
- Chave guardada em `flutter_secure_storage`, configurada em `SettingsPage`.

### Contrato dos métodos (o que cada um deve devolver com IA real)

| Método | Modelo | Entrada → Saída |
|---|---|---|
| `suggestTags(note)` | Haiku | conteúdo → 3–5 tags curtas em pt-BR |
| `looksLikeTask(note)` | Haiku | conteúdo → bool (é tarefa acionável?) |
| `generateQuestions(note)` | Haiku | conteúdo → lista `{question, answer}` de revisão |
| `getStudySuggestions(note, ctx)` | Opus | nota + notas relacionadas → 3–5 próximos tópicos |
| `getResearchSuggestions(note)` | Opus | nota → 3 ângulos de pesquisa |
| `getLearningRoadmap(note)` | Opus | assunto → trilha ordenada (fundamentos→avançado) |
| `findRelatedNotes(note, all)` | Opus | nota + todas → notas semanticamente próximas |
| `detectKnowledgeGaps(notes)` | Opus | corpus → lacunas de conhecimento |
| `translate(text, lang)` | Opus | texto → tradução (pt→en/es/fr/de/it) |
| `convertStyle(text, style)` | Opus | texto → resumo/acadêmico/técnico/iniciante/flashcards |
| `chatWithNotes(query, notes)` | Opus | pergunta + notas (RAG-lite) → resposta ancorada nas notas |

### System prompt do "Pergunte ao Pingu" (chatWithNotes)
> Você é o Pingu, tutor de estudos dentro do Pingu Notes. Responda **apenas** com
> base nas notas fornecidas do usuário; se a resposta não estiver nelas, diga isso
> e sugira criar/expandir uma nota. Seja conciso, em pt-BR, e cite os títulos das
> notas usadas. Nunca invente fatos que não estejam nas notas.

As notas relevantes entram no prompt como contexto (RAG-lite: por enquanto,
seleção por overlap de palavras/tags no cliente; no futuro, embeddings — ver §6).

## 4. Áudio — Pingu Voice (seam SEPARADO)

**Importante e honesto:** a Claude Messages API **não transcreve áudio**. O método
`transcribeAudio()` precisa de um STT dedicado. Duas opções:

- **Whisper on-device** (alinhado ao offline-first) — preferível a longo prazo;
  exige dependência de modelo (pedir autorização explícita antes de adicionar).
- **STT em nuvem** — mais simples de ligar hoje, mas quebra o offline; avisar o usuário.

Fluxo alvo: `AudioRecorderWidget` grava (ex.: `package:record`) →
`transcribeAudio(path)` devolve texto → `extractIntelligentData(text)` (via Haiku)
extrai tarefa/data/tags → vira nota. Enquanto o STT não existir, `transcribeAudio`
continua guardando `if (audioPath.isEmpty) return ''` e a UI informa indisponível.

## 5. Plano de execução (fases)

**Fase 0 — Fundação (hoje):**
1. `flutter_secure_storage` + campo de API key em `SettingsPage`.
2. `CloudIntelligenceService implements IntelligenceService` (HTTP + fallback local).
3. Registrar no `service_locator.dart` (trocar a linha do `LocalIntelligenceService`,
   injetando o local como fallback).
4. Ligar **primeiro** os 3 recursos de texto de maior impacto:
   `chatWithNotes`, `getStudySuggestions`, `generateQuestions`.
5. `flutter analyze` = 0 issues; validar com a chave real que o chat responde
   ancorado nas notas e que, sem chave/offline, cai no local com aviso na UI.

**Fase 1 — Cobertura de texto:** tags, tarefa, roadmap, lacunas, tradução, estilo.

**Fase 2 — Áudio:** escolher STT (Whisper vs nuvem), ligar gravação e `transcribeAudio`.

**Fase 3 — RAG local:** tabela de embeddings + similaridade vetorial para melhorar
seleção de contexto do chat e `findRelatedNotes` (ver Roadmap no CLAUDE.md).

## 6. Futuro — RAG local

Guardar embeddings das notas (nova tabela SQLite), buscar por similaridade de
cosseno no cliente e alimentar `chatWithNotes`/`findRelatedNotes` com os top-k
trechos. Mantém o domínio limpo (o cálculo fica em `data/`/`services/`).

## 7. Checklist de qualidade (todo PR)
- [ ] `flutter analyze` com 0 issues.
- [ ] Offline/sem chave → fallback local + aviso claro na UI (sem mock silencioso).
- [ ] Nenhuma feature existente removida.
- [ ] Identidade visual intacta.
- [ ] Recurso validado de ponta a ponta antes de expandir.
