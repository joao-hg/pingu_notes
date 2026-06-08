# ROADMAP — Pingu Notes Knowledge OS

> Atualizado: 2026-06-08  
> Versão atual do app: 1.0.0+1 | DB: v8

---

## Legenda de Status

| Status | Descrição |
|--------|-----------|
| **Complete** | Implementado, testado, funcional |
| **Partial** | UI e estrutura prontas, lógica de negócio parcial ou heurística |
| **Stub** | Interface definida, implementação retorna mensagem honesta ao usuário |
| **Disabled** | Visível na UI mas desabilitado com SnackBar explicativo |
| **Future** | Planejado, arquitetura preparada, nenhum código UI ainda |

---

## Módulos Core

| Feature | Status | Prioridade | Seam / Nota |
|---------|--------|------------|-------------|
| Notas (CRUD) | **Complete** | — | SQLite; tags como CSV; `NoteLocalDataSourceImpl` |
| Projetos | **Complete** | — | Cor via `flutter_colorpicker`; cascade delete limpa `project_id` das notas |
| Favoritos | **Complete** | — | Swipe na HomePage; toggle via `NoteProvider.toggleFavorite()` |
| Busca | **Complete** | — | LIKE em título/conteúdo/tags no SQLite |
| Revisão Espaçada | **Complete** | — | Intervalos: 1/3/7/15/30 dias (`ReviewNote` use case); mastery 0→1→2 |
| Dashboard | **Complete** | — | Stats síncronos via getters calculados em `NoteProvider` |
| Timeline | **Complete** | — | Notas agrupadas por mês com `DateFormat('MMMM yyyy', 'pt_BR')` |
| Objetivos de Aprendizado | **Complete** | — | `StudyGoal` + `StudyStep`; progress bar manual; CRUD completo |
| Conquistas (Achievements) | **Complete** | — | Tabela semeada com 7 conquistas; triggers automáticos em `addNote`, `reviewNote`, `addProject`; `unlockAchievement()` idempotente (só dispara uma vez por conquista) |
| Caixa de Entrada (Inbox) | **Complete** | — | Filtro `category == 'inbox'` |
| Página de Hoje | **Complete** | — | Tasks do dia + lembretes + favoritas + revisões pendentes |
| Memória & Evolução | **Complete** | — | Notas esquecidas (>7 dias) + barra de mastery |

---

## Knowledge OS

| Feature | Status | Prioridade | Seam / Nota |
|---------|--------|------------|-------------|
| **Pergunte ao Pingu** | **Partial** | Alta | `chatWithNotes()` em `LocalIntelligenceService`; busca offline real por keyword, stats e tags; UI de chat completa em `AskPinguPage` |
| **Pingu Studies** | **Partial** | Média | `getStudySuggestions()` baseado em mapa de domínios (20+ tecnologias); `getLearningRoadmap()` com fallback genérico |
| **Conversor de Linguagem** | **Stub** | Média | `translate()` exibe mensagem honesta offline; `convertStyle()` funciona para: Resumo, Flashcard, Acadêmico, Iniciante |
| **Pingu Voice** | **Disabled** | Média | `AudioRecorderWidget` mostra SnackBar; seam: `transcribeAudio(String audioPath)` em `IntelligenceService`; guard `if (audioPath.isEmpty)` no provider |
| Gaps de Conhecimento | **Partial** | Baixa | `detectKnowledgeGaps()` com regras para 8 domínios; mostrado no Dashboard |
| Questões de Revisão | **Partial** | Média | `generateQuestions()` gera 1-3 questões heurísticas por nota; armazenadas em `note_questions` |
| Conexões de Conhecimento | **Partial** | Baixa | Tabela `knowledge_connections` existe; `findRelatedNotes()` por interseção de tags+título; nenhuma UI dedicada ainda |
| Conquistas Automáticas | **Complete** | — | Triggers integrados em `addNote`, `reviewNote`, `addProject`; `unlockAchievement` é idempotente via `AND unlocked_at IS NULL` |

---

## Futuro (Sprint 3+)

| Feature | Status | Prioridade | Seam |
|---------|--------|------------|------|
| **Pingu Tutor** | **Future** | Alta | Superset do "Pergunte ao Pingu"; mesmo seam `chatWithNotes()` + histórico de sessão |
| **Whisper (transcrição real)** | **Future** | Alta | Implementar `IntelligenceService` com `whisper.cpp` via FFI ou plugin nativo |
| **RAG Local** | **Future** | Média | Nova tabela `note_embeddings` no SQLite; nova implementação de `IntelligenceService` com busca vetorial |
| **Tradução Local** | **Future** | Média | Modelos leves: LibreTranslate offline ou Argos Translate via plugin |
| **Pingu Tutor com Gemma/Llama** | **Future** | Baixa | Implementar `IntelligenceService` com `llama.cpp` via FFI |
| **Análise de Imagem** | **Future** | Baixa | Seam: `analyzeImage(String imagePath)` em `IntelligenceService` |
| **Análise de Documento PDF** | **Future** | Baixa | Seam: `analyzeDocument(String docPath)` em `IntelligenceService` |

---

## Próxima Sprint Recomendada

### Sprint 2 — Knowledge OS + Qualidade

**Objetivo:** Expandir funcionalidades de conhecimento e polir a experiência atual.

1. ~~**Triggers de conquistas automáticas**~~ — ✅ Concluído na auditoria de qualidade (2026-06-08).
2. **Conversor de Linguagem UI** — Criar página dedicada com seletor de idioma/estilo. A lógica de `convertStyle()` já existe; adicionar seleção de idioma-alvo e campo de resultado.
3. **Pergunte ao Pingu — melhorias UX** — Adicionar sugestões de query na tela vazia ("O que sei sobre...?", "Quais assuntos...?").
4. **Conexões de Conhecimento UI** — Visualizar notas relacionadas dentro de `NoteEditPage` usando `findRelatedNotes()`.
5. **DB: índices existem, monitorar** — Índices criados na migração v8; validar performance com muitas notas.

### Sprint 3 — Pingu Voice

1. Integrar plugin de gravação (`record` package).
2. Salvar arquivo de áudio na pasta de documentos do app.
3. Associar caminho do áudio à nota via `audioPath`.
4. Exibir player básico na `NoteEditPage`.
5. Preparar `transcribeAudio()` para receber path real.

---

## Idiomas planejados para Conversor

- Português → Inglês
- Português → Espanhol
- Português → Francês
- Português → Alemão
- Português → Italiano

## Estilos planejados

- Resumo *(funcional)*
- Flashcard *(funcional)*
- Acadêmico *(funcional)*
- Iniciante *(funcional)*
- Técnico *(a implementar)*
