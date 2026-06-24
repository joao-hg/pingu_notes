import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/note_icon.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/quick_add_modal.dart';
import '../widgets/review_panel.dart';
import '../widgets/pingu_brand.dart';
import '../../services/notification_service.dart';
import '../../services/service_locator.dart' as di;
import 'note_edit_page.dart';
import 'inbox_page.dart';
import 'today_page.dart';
import 'projects_page.dart';
import 'memory_page.dart';
import 'ask_pingu_page.dart';
import 'goals_page.dart';
import 'timeline_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<int>? _notificationSub;

  @override
  void initState() {
    super.initState();
    _notificationSub =
        di.sl<NotificationService>().notificationTaps.listen(_openNoteById);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteId = di.sl<NotificationService>().consumeLaunchNoteId();
      if (noteId != null && mounted) _openNoteById(noteId);
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _openNoteById(int noteId) {
    if (!mounted) return;
    final notes = context.read<NoteProvider>().notes;
    final matches = notes.where((n) => n.id == noteId).toList();
    if (matches.isEmpty) return;
    debugPrint('[Notification] Abrindo nota id=$noteId');
    _editNote(context, matches.first);
  }

  Future<void> _showSmartModal() async {
    final result = await showModalBottomSheet<Note>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const QuickAddModal(),
      ),
    );

    if (result != null && mounted) {
      debugPrint('[EXPANDIR] Editor aberto para nota ID=${result.id}');
      context.read<NoteProvider>().markAsViewed(result);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NoteEditPage(note: result)),
      );
    }
  }

  void _editNote(BuildContext ctx, Note note) {
    context.read<NoteProvider>().markAsViewed(note);
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => NoteEditPage(note: note)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      drawer: _buildDrawer(context, isDark),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _NoteListTab(
            scaffoldKey: _scaffoldKey,
            searchController: _searchController,
            onShowModal: _showSmartModal,
            onEditNote: _editNote,
          ),
          _SearchTab(onEditNote: _editNote),
          _FavoritesTab(
            onEditNote: _editNote,
            onShowModal: _showSmartModal,
          ),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        height: 64,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.warmYellow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const PinguMascot(size: 36),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pingu Notes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Seu Segundo Cérebro',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.mutedInk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.inbox_outlined,
              label: 'Caixa de Entrada',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxPage()));
              },
            ),
            _DrawerItem(
              icon: Icons.today_outlined,
              label: 'Central de Hoje',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TodayPage()));
              },
            ),
            _DrawerItem(
              icon: Icons.rocket_launch_outlined,
              label: 'Projetos',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsPage()));
              },
            ),
            _DrawerItem(
              icon: Icons.psychology_outlined,
              label: 'Memória',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryPage()));
              },
            ),
            Divider(
              height: 24,
              indent: 20,
              endIndent: 20,
              color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
            ),
            _DrawerItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Pergunte ao Pingu',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AskPinguPage()));
              },
            ),
            _DrawerItem(
              icon: Icons.track_changes_rounded,
              label: 'Objetivos',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsPage()));
              },
            ),
            _DrawerItem(
              icon: Icons.timeline_rounded,
              label: 'Evolução',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TimelinePage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 0: Note List
// ─────────────────────────────────────────────

class _NoteListTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController searchController;
  final VoidCallback onShowModal;
  final void Function(BuildContext, Note) onEditNote;

  const _NoteListTab({
    required this.scaffoldKey,
    required this.searchController,
    required this.onShowModal,
    required this.onEditNote,
  });

  @override
  State<_NoteListTab> createState() => _NoteListTabState();
}

class _NoteListTabState extends State<_NoteListTab> {
  String _selectedTag = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<NoteProvider>(
        builder: (context, provider, _) {
          if (provider.error != null) {
            final errorMsg = provider.error!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              context.read<NoteProvider>().clearError();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro: $errorMsg'),
                  backgroundColor: AppColors.danger,
                ),
              );
            });
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildSearchBar(context, provider)),
              SliverToBoxAdapter(child: _buildFilterChips(context, provider)),
              if (provider.dueReviews.isNotEmpty ||
                  provider.forgottenNotes.isNotEmpty)
                const SliverToBoxAdapter(child: ReviewPanel()),
              if (widget.searchController.text.isEmpty)
                SliverToBoxAdapter(child: _buildRecentSection(context, provider)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Text(
                    widget.searchController.text.isEmpty
                        ? 'Todas as Notas'
                        : 'Resultados',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              _buildNotesList(context, provider),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warmYellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const PinguMascot(size: 30),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Pingu Notes',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: widget.onShowModal,
            tooltip: 'Nova Nota',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, NoteProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: widget.searchController,
        decoration: InputDecoration(
          hintText: 'Pesquisar notas...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    widget.searchController.clear();
                    provider.searchNotes('');
                    setState(() {});
                  },
                ),
              IconButton(
                icon: const Icon(Icons.tune_rounded, size: 20),
                onPressed: () => _showSortMenu(context, provider),
                color: AppColors.mutedInk,
              ),
            ],
          ),
        ),
        onChanged: (v) {
          setState(() {
            if (v != _selectedTag) _selectedTag = '';
          });
          provider.searchNotes(v);
        },
      ),
    );
  }

  void _showSortMenu(BuildContext context, NoteProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Ordenação Inteligente'),
            selected: provider.sortBy == 'intelligent',
            onTap: () {
              provider.setSortBy('intelligent');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Mais Recentes Primeiro'),
            selected: provider.sortBy == 'newest',
            onTap: () {
              provider.setSortBy('newest');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Mais Antigas Primeiro'),
            selected: provider.sortBy == 'oldest',
            onTap: () {
              provider.setSortBy('oldest');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Ordem Alfabética'),
            selected: provider.sortBy == 'alphabetical',
            onTap: () {
              provider.setSortBy('alphabetical');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, NoteProvider provider) {
    final tags = provider.allTags;
    if (tags.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterPill(
            label: 'Todas',
            selected: _selectedTag.isEmpty,
            onTap: () {
              setState(() => _selectedTag = '');
              provider.searchNotes('');
              widget.searchController.clear();
            },
          ),
          const SizedBox(width: 8),
          ...tags.map(
            (tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterPill(
                label: tag,
                selected: _selectedTag == tag,
                onTap: () {
                  setState(() {
                    _selectedTag = tag;
                    widget.searchController.text = tag;
                  });
                  provider.searchNotes(tag);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection(BuildContext context, NoteProvider provider) {
    final recent = provider.recentNotes;
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Text(
            'Recentes',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.mutedInk,
            ),
          ),
        ),
        SizedBox(
          height: 116,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recent.length.clamp(0, 6),
            itemBuilder: (ctx, i) {
              final note = recent[i];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _MiniNoteCard(
                  note: note,
                  onTap: () => widget.onEditNote(ctx, note),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildNotesList(BuildContext context, NoteProvider provider) {
    if (provider.isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final notes = provider.notes;
    if (notes.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: PinguEmptyState(
            message: 'Suas ideias merecem um lugar especial.',
            actionLabel: 'Criar nota',
            onAction: widget.onShowModal,
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => _buildSwipeableNote(ctx, notes[i], provider),
          childCount: notes.length,
        ),
      ),
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
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.warning,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.star_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          provider.toggleFavorite(note);
          return false;
        }
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir nota?'),
            content: const Text('Esta ação não pode ser desfeita.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          provider.deleteNote(note.id!);
        }
        return confirm;
      },
      child: NoteCard(
        note: note,
        onTap: () => widget.onEditNote(context, note),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 1: Search
// ─────────────────────────────────────────────

class _SearchTab extends StatefulWidget {
  final void Function(BuildContext, Note) onEditNote;

  const _SearchTab({required this.onEditNote});

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<NoteProvider>(
        builder: (context, provider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  'Buscar',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar notas, projetos...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _controller.clear();
                              provider.searchNotes('');
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) {
                    setState(() {});
                    provider.searchNotes(v);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: provider.notes.isEmpty
                    ? Center(
                        child: Text(
                          _controller.text.isEmpty
                              ? 'Digite para buscar suas notas'
                              : 'Nenhuma nota encontrada',
                          style: GoogleFonts.poppins(
                            color: AppColors.mutedInk,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.notes.length,
                        itemBuilder: (ctx, i) {
                          final note = provider.notes[i];
                          return NoteCard(
                            note: note,
                            onTap: () => widget.onEditNote(ctx, note),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 2: Favorites
// ─────────────────────────────────────────────

class _FavoritesTab extends StatelessWidget {
  final void Function(BuildContext, Note) onEditNote;
  final VoidCallback onShowModal;

  const _FavoritesTab({
    required this.onEditNote,
    required this.onShowModal,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<NoteProvider>(
        builder: (context, provider, _) {
          final favorites =
              provider.notes.where((n) => n.isFavorite).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  children: [
                    Text(
                      'Favoritos',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${favorites.length} ${favorites.length == 1 ? 'nota' : 'notas'}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: favorites.isEmpty
                    ? const PinguEmptyState(
                        message:
                            'Marque suas notas favoritas\npara encontrá-las rapidamente.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: favorites.length,
                        itemBuilder: (ctx, i) {
                          final note = favorites[i];
                          return NoteCard(
                            note: note,
                            onTap: () => onEditNote(ctx, note),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGreen
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withAlpha(80),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.primaryGreen
                : Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withAlpha(100),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _MiniNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const _MiniNoteCard({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = noteIconColor(note);
    final icon = noteIconData(note);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(28),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              note.title.isEmpty ? 'Sem título' : note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22, color: AppColors.mutedInk),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      visualDensity: VisualDensity.compact,
    );
  }
}

