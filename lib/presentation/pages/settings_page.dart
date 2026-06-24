import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../providers/note_provider.dart';
import '../widgets/pingu_brand.dart';
import 'ask_pingu_page.dart';
import 'goals_page.dart';
import 'inbox_page.dart';
import 'memory_page.dart';
import 'projects_page.dart';
import 'timeline_page.dart';
import 'today_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Text(
                'Ajustes',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // App info card
            _AppInfoCard(isDark: isDark),
            const SizedBox(height: 20),

            const _SectionLabel(label: 'Preferências'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                    label: Text('Sistema'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Claro'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Escuro'),
                  ),
                ],
                selected: {provider.themeMode},
                onSelectionChanged: (set) => provider.setThemeMode(set.first),
              ),
            ),
            const SizedBox(height: 20),

            // Navigation section
            const _SectionLabel(label: 'Navegação'),
            _SettingsTile(
              icon: Icons.inbox_outlined,
              iconColor: AppColors.categoryNote,
              label: 'Caixa de Entrada',
              onTap: () => _push(context, const InboxPage()),
            ),
            _SettingsTile(
              icon: Icons.today_outlined,
              iconColor: AppColors.categoryProject,
              label: 'Central de Hoje',
              onTap: () => _push(context, const TodayPage()),
            ),
            _SettingsTile(
              icon: Icons.rocket_launch_outlined,
              iconColor: AppColors.categoryStudy,
              label: 'Projetos',
              onTap: () => _push(context, const ProjectsPage()),
            ),
            _SettingsTile(
              icon: Icons.psychology_outlined,
              iconColor: AppColors.categoryAudio,
              label: 'Memória',
              onTap: () => _push(context, const MemoryPage()),
            ),
            const SizedBox(height: 8),
            // Tools section
            const _SectionLabel(label: 'Ferramentas'),
            _SettingsTile(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: AppColors.categoryAI,
              label: 'Pergunte ao Pingu',
              subtitle: 'IA offline com heurísticas',
              onTap: () => _push(context, const AskPinguPage()),
            ),
            _SettingsTile(
              icon: Icons.track_changes_rounded,
              iconColor: AppColors.primaryGreen,
              label: 'Objetivos',
              onTap: () => _push(context, const GoalsPage()),
            ),
            _SettingsTile(
              icon: Icons.timeline_rounded,
              iconColor: AppColors.categoryTask,
              label: 'Evolução',
              onTap: () => _push(context, const TimelinePage()),
            ),
            const SizedBox(height: 8),
            // About section
            const _SectionLabel(label: 'Sobre'),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.mutedInk,
              label: 'Sobre o Pingu Notes',
              onTap: () => _showAboutDialog(context),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pingu Notes'),
        content: Text(
          'Versão 1.0.0\n\nTransforme texto, áudio e ideias em conhecimento organizado e reusável.\n\nCapture → Organize → Revise → Aprenda',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _AppInfoCard extends StatelessWidget {
  final bool isDark;

  const _AppInfoCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.warmYellow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const PinguMascot(size: 40),
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
                'Versão 1.0.0',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.mutedInk,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.mutedInk,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(isDark ? 40 : 22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.mutedInk,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark ? Colors.white38 : AppColors.mutedInk.withAlpha(150),
            ),
          ],
        ),
      ),
    );
  }
}
