# ARCHITECTURE — Pingu Notes

> Este documento descreve a arquitetura do projeto para referência de todos os contribuidores.

---

## Princípio Central

**Clean Architecture** com três camadas. A regra de dependência é **inward-only**:

```
Presentation → Domain ← Data
```

`domain/` não importa nada de `data/` nem de `presentation/`. `data/` importa de `domain/`. `presentation/` importa de `domain/` e de `services/`.

---

## Camadas

### Domain (`lib/domain/`)

Núcleo do sistema. **Sem Flutter, sem sqflite, sem dependências externas.**

- **`entities/`** — Objetos de domínio imutáveis (Equatable):
  - `Note` — entidade principal; tem `masteryLevel`, `reviewCount`, `nextReviewAt`, `audioPath`, `aiAnalysis`
  - `Project` — agrupamento de notas; cor armazenada como `int` (ARGB32)
  - `StudyGoal` + `StudyStep` — objetivos de aprendizado com progresso
  - `KnowledgeConnection` — aresta entre duas notas (grafo de conhecimento)
  - `NoteQuestion` — pergunta de revisão associada a uma nota
  - `Achievement` — conquista com `unlockedAt` nullable
  - `Attachment` — arquivo anexado (áudio, imagem, documento)
  - `AiInsight` — entidade reservada para futura análise; sem repositório ativo

- **`repositories/`** — Interfaces abstratas:
  - `NoteRepository` — CRUD de notas e projetos
  - `KnowledgeRepository` — CRUD de objetivos, conexões, questões, conquistas, anexos

- **`usecases/`** — Um use case por arquivo, cada um é uma classe callable (`call()`):
  - `GetNotes`, `SearchNotes`, `AddNote`, `UpdateNote`, `DeleteNote`
  - `GetProjects`, `AddProject`, `UpdateProject`, `DeleteProject`
  - `ReviewNote` — aplica lógica de espaçamento (1/3/7/15/30 dias) e atualiza `masteryLevel`

- **`services/`** — Abstração de IA:
  - `IntelligenceService` — interface com todos os métodos de inteligência; é o **único ponto de extensão** para modelos futuros (Whisper, Gemma, Llama)

---

### Data (`lib/data/`)

Implementações concretas de persistência. Importa `domain/`.

- **`datasource/note_local_datasource.dart`** — SQLite via `sqflite`. Contém:
  - `NoteLocalDataSource` (interface)
  - `NoteLocalDataSourceImpl` (implementação)
  - Schema atual: **versão 8**
  - `onConfigure`: `PRAGMA journal_mode=WAL` + `PRAGMA foreign_keys=ON` (performance e integridade)
  - `_seedAchievements()` — idempotente via `INSERT OR IGNORE`, chamado em `onCreate` e `onOpen`
  - `_createIndexes()` — índices em `updated_at`, `is_favorite`, `project_id`, `category`, `next_review_at`
  - `unlockAchievement()` — idempotente: só escreve se `unlocked_at IS NULL`

- **`models/`** — Subclasses dos domain entities com serialização SQLite:
  - `NoteModel.fromMap()` / `toMap()` — converte `tags` entre `List<String>` e CSV
  - `NoteModel.fromEntity()` — usado nos repositórios para converter antes de persistir

- **`repositories/`** — Implementações que delegam ao datasource:
  - `NoteRepositoryImpl` — implementa `NoteRepository`
  - `KnowledgeRepositoryImpl` — implementa `KnowledgeRepository`

**Nota importante:** `tags` são armazenadas como CSV no campo `tags TEXT`. Tags com vírgulas ou que contenham espaços podem causar split incorreto.

---

### Services (`lib/services/`)

Implementações concretas fora das camadas clean, registradas via GetIt.

- **`service_locator.dart`** — DI com GetIt. Ordem de registro obrigatória (ver seção abaixo).
- **`local_intelligence_service.dart`** — Implementação offline de `IntelligenceService`. Usa heurísticas e busca por keyword. Nenhuma dependência de modelo externo.
- **`notification_service.dart`** — Singleton com `flutter_local_notifications`. 3 canais: `review`, `reminder`, `memory`. IDs calculados como `noteId * 10 + type.index + 1`.

---

### Presentation (`lib/presentation/`)

Flutter + Provider. Importa `domain/` e `services/`.

- **`providers/note_provider.dart`** — `ChangeNotifier` único para todo o estado do app (ver seção abaixo).
- **`pages/`** — Telas completas, uma por arquivo.
- **`widgets/`** — Componentes reutilizáveis. Nunca contêm lógica de negócio.

---

## Dependency Injection (GetIt)

`service_locator.dart` usa `GetIt.instance` como `sl`. A ordem de registro importa porque GetIt resolve lazily mas verifica dependências na criação:

```
1. NoteLocalDataSourceImpl     ← nenhuma dependência
2. NoteRepositoryImpl          ← depende de DataSource
   KnowledgeRepositoryImpl     ← depende de DataSource
3. GetNotes, SearchNotes, ...  ← dependem de NoteRepository
   ReviewNote, ...             ← dependem de NoteRepository
4. LocalIntelligenceService    ← nenhuma dependência
   NotificationService         ← requer await init() antes de registrar
```

`NotificationService` é um singleton (`registerSingleton`) porque sua instância é criada e inicializada antes do registro. Os demais são `registerLazySingleton`.

---

## State Management (NoteProvider)

`NoteProvider` é o único `ChangeNotifier` do app. Centraliza todo o estado para simplificar o data flow em um app offline-first.

### Campos privados
```dart
List<Note> _notes
List<Project> _projects
List<StudyGoal> _studyGoals
List<KnowledgeConnection> _connections
List<Achievement> _achievements
bool _isLoading
String? _error
bool _showOnlyFavorites
String _currentQuery
```

### Getters computados (síncronos, calculados sobre _notes)
- `dueReviews` — notas com `nextReviewAt.isBefore(now)` ou criadas há ≥1 dia se `nextReviewAt == null`
- `forgottenNotes` — notas sem revisão há ≥7 dias (baseline: `lastReviewedAt ?? createdAt`)
- `dashboardStats` — mapa com totais para o dashboard
- `todayStats`, `inboxNotes`, `tasksDueToday`, `remindersToday`, etc.

Estes getters **não fazem queries ao banco**. São recalculados a cada rebuild do Consumer.

### Fluxo de escrita
```
addNote / updateNote / deleteNote
  → await usecase(...)
  → await searchNotes(_currentQuery)   ← sempre reconstrói _notes
    → se query vazia: loadNotes()       ← getNotes() do banco
    → se não vazia: searchNotes(query)  ← searchNotes() do banco
  → notifyListeners()
```

### loadInitialData
```dart
Future<void> loadInitialData() async {
  _isLoading = true; _error = null; notifyListeners();
  try {
    _notes = await getNotesUseCase();
    _projects = await getProjectsUseCase();
    // ... knowledge data ...
  } catch (e) {
    _error = e.toString();
    debugPrint('[NoteProvider] $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

---

## Banco de Dados (SQLite)

**Arquivo:** `pingu_notes.db` | **Versão atual:** 8

### Tabelas ativas

| Tabela | Uso |
|--------|-----|
| `notes` | Entidade principal; 22 colunas |
| `projects` | Projetos; cor em `INTEGER` (ARGB32) |
| `study_goals` + `study_steps` | Objetivos; N+1 query no load |
| `knowledge_connections` | Grafo de relações entre notas |
| `note_questions` | Perguntas de revisão por nota |
| `achievements` | Semeada com 7 conquistas; `unlocked_at` nullable |
| `attachments` | Reservado para áudio/imagem/documento |

### Tabelas sem uso ativo na UI

| Tabela | Status |
|--------|--------|
| `ai_insights` | Tabela existe, sem repositório nem UI |

### Histórico de versões

| Versão | O que mudou |
|--------|-------------|
| 1 | Schema inicial: `notes`, `projects` |
| 2 | `last_viewed_at` |
| 3 | `reminder_at` |
| 4 | Tasks, prioridade, projeto, categoria |
| 5 | `ai_insights` table |
| 6 | Campos de revisão espaçada |
| 7 | `audio_path`, `transcription`, `ai_analysis`; Knowledge OS tables |
| 8 | Índices de performance; seeding de conquistas padrão |

### Regra de migração

```dart
if (oldVersion < N) {
  // ALTER TABLE apenas para ADD COLUMN
  // CREATE TABLE IF NOT EXISTS para tabelas novas
}
```

SQLite não suporta DROP COLUMN nem RENAME COLUMN. Para mudanças destrutivas: criar tabela nova, migrar dados, renomear.

---

## IntelligenceService — O Seam de IA

```dart
// domain/services/intelligence_service.dart
abstract class IntelligenceService {
  // Pingu Studies
  Future<List<String>> getStudySuggestions(Note note, List<Note> contextNotes);
  Future<List<String>> getLearningRoadmap(Note note);

  // Questões
  Future<List<Map<String, String>>> generateQuestions(Note note);

  // Pergunte ao Pingu / Pingu Tutor
  Future<String> chatWithNotes(String query, List<Note> notes);

  // Pingu Voice
  Future<String> transcribeAudio(String audioPath);

  // Conversor
  Future<String> translate(String text, String targetLanguage);
  Future<String> convertStyle(String text, String style);

  // Knowledge Gaps
  Future<List<String>> detectKnowledgeGaps(List<Note> notes);

  // ... outros métodos
}
```

**Para adicionar um modelo real:**
1. Criar `lib/services/whisper_intelligence_service.dart` implementando `IntelligenceService`
2. Em `service_locator.dart`, substituir `LocalIntelligenceService` pela nova implementação
3. Nada mais precisa mudar

**`LocalIntelligenceService`** é a implementação offline-first atual:
- `chatWithNotes()` — busca real por keyword nas notas; responde perguntas sobre stats, tags, favoritas, esquecidas
- `getStudySuggestions()` — mapa de 20+ domínios tecnológicos com sugestões relacionadas
- `translate()` — mensagem honesta sobre limitação offline
- `transcribeAudio()` — retorna `''` (guard no provider impede chamada com path vazio)

---

## Padrões Críticos

### 1. Color → int
```dart
// ✅ Correto (Flutter 3.44+)
final colorInt = color.toARGB32();
final color = Color(intValue);

// ❌ Deprecated
final colorInt = color.value;
```

### 2. FutureBuilder — nunca chamar async no build()
```dart
// ✅ Correto
class _MyState extends State<MyWidget> {
  late Future<List<String>> _myFuture;

  @override
  void initState() {
    super.initState();
    _myFuture = context.read<NoteProvider>().someAsyncMethod();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _myFuture, ...);
  }
}

// ❌ Causa rebuild loop
FutureBuilder(future: context.read<Provider>().asyncMethod(), ...)
```

### 3. context.watch em widgets de lista
Não usar `context.watch` em widgets construídos dentro de `ListView.builder`. Usar `context.read` dentro de event handlers. Cálculos que dependem apenas dos dados do item (como severidade de esquecimento) devem ser métodos estáticos/puros.

### 4. Locale
```dart
// Em main() — antes de di.init() e runApp()
Intl.defaultLocale = 'pt_BR';
await initializeDateFormatting('pt_BR', null);
```

### 5. Mastery Levels (fonte da verdade: ReviewNote use case)
- `0` → Nunca revisada
- `1` → Em aprendizado (reviewCount 1-3)
- `2` → Dominada (reviewCount ≥ 4)

O comentário na entidade `Note` foi corrigido e está alinhado com a implementação.

---

## Identidade Visual

Não alterar sem autorização explícita.

| Token | Valor |
|-------|-------|
| `AppColors.deepOceanBlue` | `#0D3B66` — primária |
| `AppColors.iceBlue` | `#D6ECF7` — fundo, acentos |
| `AppColors.warmYellow` | `#FFD166` — FAB, destaques |
| `AppColors.softOrange` | `#FF9F66` — secundária |
| `AppColors.success` | `#2F9E7E` |
| `AppColors.danger` | `#D95D5D` |
| Tipografia | Playfair Display (títulos) + Poppins (corpo) |
| Mascote | `PinguMascot` — desenhado via `CustomPainter` em `pingu_brand.dart` |
