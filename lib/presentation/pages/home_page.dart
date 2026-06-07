import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/quick_add_modal.dart';
import '../widgets/review_panel.dart';
import '../widgets/today_panel.dart';
import '../widgets/dashboard_panel.dart';
import '../widgets/pingu_brand.dart';
import '../widgets/achievements_widget.dart';
import 'note_edit_page.dart';
import 'inbox_page.dart';
import 'today_page.dart';
import 'projects_page.dart';
import 'memory_page.dart';
import 'ask_pingu_page.dart';
import 'goals_page.dart';
import 'timeline_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quickAddController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _quickAddController.dispose();
    super.dispose();
  }

  void _saveQuickNote() {
    final text = _quickAddController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final note = Note(
      title: '',
      content: text,
      createdAt: now,
      updatedAt: now,
      lastViewedAt: now,
      isFavorite: false,
      tags: const [],
    );

    context.read<NoteProvider>().addNote(note);
    _quickAddController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🐧 Pingu guardou sua nota!'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSmartModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const QuickAddModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🐧 Pingu Brain'), centerTitle: true),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🐧', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    'Pingu Notes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Seu Segundo Cérebro',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: const Text('Caixa de Entrada'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InboxPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.today_outlined),
              title: const Text('Central de Hoje'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TodayPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.rocket_launch_outlined),
              title: const Text('Projetos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProjectsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.psychology_outlined),
              title: const Text('Memória'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemoryPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded),
              title: const Text('Pergunte ao Pingu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AskPinguPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes_rounded),
              title: const Text('Objetivos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GoalsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.timeline_rounded),
              title: const Text('Evolução'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TimelinePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: WatercolorBackdrop(
        child: Column(
          children: [
            // Fixed Top Section
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  // Search Bar - Fixed
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: 'Pesquisar em tudo...',
                      leading: const Icon(Icons.search),
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withAlpha(100),
                      ),
                      trailing: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<NoteProvider>().searchNotes('');
                            },
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {});
                        context.read<NoteProvider>().searchNotes(value);
                      },
                    ),
                  ),
                  // Quick Capture Field - Fixed
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: _quickAddController,
                      decoration: InputDecoration(
                        hintText: 'Qual assunto você não pode esquecer?',
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withAlpha(50),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send_rounded),
                          onPressed: _saveQuickNote,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      onSubmitted: (_) => _saveQuickNote(),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardPanel(),
                    const AchievementsWidget(),
                    const TodayPanel(),
                    const ReviewPanel(),

                    // Filter Chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Consumer<NoteProvider>(
                        builder: (context, provider, child) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: const Text('⭐ Favoritos'),
                                  selected: provider.showOnlyFavorites,
                                  onSelected: (_) =>
                                      provider.toggleShowOnlyFavorites(),
                                ),
                                const SizedBox(width: 8),
                                ...provider.allTags.map(
                                  (tag) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ActionChip(
                                      label: Text('#$tag'),
                                      onPressed: () {
                                        _searchController.text = tag;
                                        provider.searchNotes(tag);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // History Sections (Created / Updated)
                    Consumer<NoteProvider>(
                      builder: (context, provider, child) {
                        if (_searchController.text.isNotEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHistorySection(
                              context,
                              '📌 Últimas Criadas',
                              provider.recentNotes,
                            ),
                            _buildHistorySection(
                              context,
                              '🔄 Últimas Atualizadas',
                              provider.recentlyUpdatedNotes,
                            ),
                          ],
                        );
                      },
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        '📋 Todas as Notas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Main List with Swipe Gestures
                    Consumer<NoteProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final notes = provider.notes;
                        if (notes.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: PinguEmptyState(
                              message: 'Suas ideias merecem um lugar especial.',
                              actionLabel: 'Criar nota',
                              onAction: _showSmartModal,
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return _buildSwipeableNote(context, note, provider);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSmartModal,
        tooltip: 'Nova Nota Inteligente',
        child: const Icon(Icons.bolt_rounded),
      ),
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    String title,
    List<Note> notes,
  ) {
    if (notes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                child: NoteCard(
                  note: note,
                  onTap: () => _editNote(context, note),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeableNote(
    BuildContext context,
    Note note,
    NoteProvider provider,
  ) {
    return Dismissible(
      key: Key('note_${note.id}'),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.star_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          provider.toggleFavorite(note);
          return false;
        } else {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Excluir nota?'),
              content: const Text('Esta ação não pode ser desfeita.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Excluir'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            provider.deleteNote(note.id!);
          }
          return confirm;
        }
      },
      child: NoteCard(note: note, onTap: () => _editNote(context, note)),
    );
  }

  void _editNote(BuildContext context, Note note) {
    context.read<NoteProvider>().markAsViewed(note);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage(note: note)),
    );
  }
}
