import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FormatToolbar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onOpenMetadata;
  final VoidCallback onFormatUsed;

  const FormatToolbar({
    super.key,
    required this.controller,
    required this.onOpenMetadata,
    required this.onFormatUsed,
  });

  void _wrapInline(String marker) {
    onFormatUsed();
    final sel = controller.selection;
    final text = controller.text;
    if (!sel.isValid) return;

    if (sel.isCollapsed) {
      final pos = sel.baseOffset.clamp(0, text.length);
      final newText = text.replaceRange(pos, pos, '$marker$marker');
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: pos + marker.length),
      );
    } else {
      final selected = text.substring(sel.start, sel.end);
      // Toggle: unwrap if already wrapped
      if (selected.startsWith(marker) &&
          selected.endsWith(marker) &&
          selected.length > marker.length * 2) {
        final unwrapped =
            selected.substring(marker.length, selected.length - marker.length);
        controller.value = controller.value.copyWith(
          text: text.replaceRange(sel.start, sel.end, unwrapped),
          selection: TextSelection(
            baseOffset: sel.start,
            extentOffset: sel.start + unwrapped.length,
          ),
        );
      } else {
        final wrapped = '$marker$selected$marker';
        controller.value = controller.value.copyWith(
          text: text.replaceRange(sel.start, sel.end, wrapped),
          selection: TextSelection(
            baseOffset: sel.start,
            extentOffset: sel.start + wrapped.length,
          ),
        );
      }
    }
  }

  void _insertBlockPrefix(String prefix) {
    onFormatUsed();
    final sel = controller.selection;
    final text = controller.text;
    final pos = sel.isValid ? sel.baseOffset.clamp(0, text.length) : text.length;
    final lineStart = pos > 0 ? (text.lastIndexOf('\n', pos - 1) + 1) : 0;
    final lineText = text.substring(lineStart);

    // Toggle off if same prefix already present
    if (lineText.startsWith(prefix)) {
      final newText = text.replaceRange(lineStart, lineStart + prefix.length, '');
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
          offset: (pos - prefix.length).clamp(0, newText.length),
        ),
      );
      return;
    }

    // Replace existing block prefix
    const others = ['- [x] ', '- [ ] ', '- ', '> ', '## '];
    for (final other in others) {
      if (lineText.startsWith(other) && other != prefix) {
        final newText =
            text.replaceRange(lineStart, lineStart + other.length, prefix);
        controller.value = controller.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(
            offset: pos - other.length + prefix.length,
          ),
        );
        return;
      }
    }

    // Insert new prefix
    final newText = text.replaceRange(lineStart, lineStart, prefix);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + prefix.length),
    );
  }

  void _insertChecklist() {
    onFormatUsed();
    final sel = controller.selection;
    final text = controller.text;
    final pos = sel.isValid ? sel.baseOffset.clamp(0, text.length) : text.length;
    final lineStart = pos > 0 ? (text.lastIndexOf('\n', pos - 1) + 1) : 0;
    final lineText = text.substring(lineStart);

    if (lineText.startsWith('- [x] ')) {
      final newText =
          text.replaceRange(lineStart, lineStart + '- [x] '.length, '');
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
          offset: (pos - '- [x] '.length).clamp(0, newText.length),
        ),
      );
    } else if (lineText.startsWith('- [ ] ')) {
      final newText =
          text.replaceRange(lineStart, lineStart + '- [ ] '.length, '');
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
          offset: (pos - '- [ ] '.length).clamp(0, newText.length),
        ),
      );
    } else {
      const prefix = '- [ ] ';
      const others = ['- ', '> ', '## '];
      for (final other in others) {
        if (lineText.startsWith(other)) {
          final newText =
              text.replaceRange(lineStart, lineStart + other.length, prefix);
          controller.value = controller.value.copyWith(
            text: newText,
            selection: TextSelection.collapsed(
              offset: pos - other.length + prefix.length,
            ),
          );
          return;
        }
      }
      final newText = text.replaceRange(lineStart, lineStart, prefix);
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: pos + prefix.length),
      );
    }
  }

  void _insertCode() {
    onFormatUsed();
    final sel = controller.selection;
    if (!sel.isValid) return;
    final text = controller.text;

    if (sel.isCollapsed) {
      final pos = sel.baseOffset.clamp(0, text.length);
      final newText = text.replaceRange(pos, pos, '``');
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: pos + 1),
      );
    } else {
      final selected = text.substring(sel.start, sel.end);
      final isMultiLine = selected.contains('\n');
      final wrapped = isMultiLine ? '```\n$selected\n```' : '`$selected`';
      controller.value = controller.value.copyWith(
        text: text.replaceRange(sel.start, sel.end, wrapped),
        selection: TextSelection(
          baseOffset: sel.start,
          extentOffset: sel.start + wrapped.length,
        ),
      );
    }
  }

  void _insertDivider() {
    onFormatUsed();
    final sel = controller.selection;
    final pos =
        sel.isValid ? sel.baseOffset.clamp(0, controller.text.length) : controller.text.length;
    const insertion = '\n---\n';
    final newText = controller.text.replaceRange(pos, pos, insertion);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + insertion.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.cardBorder;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            _ToolBtn(
              icon: Icons.format_bold,
              tooltip: 'Negrito',
              onTap: () => _wrapInline('**'),
            ),
            _ToolBtn(
              icon: Icons.format_italic,
              tooltip: 'Itálico',
              onTap: () => _wrapInline('_'),
            ),
            _ToolBtn(
              icon: Icons.check_box_outline_blank_rounded,
              tooltip: 'Checklist',
              onTap: _insertChecklist,
            ),
            _ToolBtn(
              icon: Icons.format_list_bulleted_rounded,
              tooltip: 'Lista',
              onTap: () => _insertBlockPrefix('- '),
            ),
            _ToolBtn(
              icon: Icons.format_quote_rounded,
              tooltip: 'Citação',
              onTap: () => _insertBlockPrefix('> '),
            ),
            _ToolBtn(
              icon: Icons.code_rounded,
              tooltip: 'Código',
              onTap: _insertCode,
            ),
            _ToolBtn(
              icon: Icons.horizontal_rule_rounded,
              tooltip: 'Divisor',
              onTap: _insertDivider,
            ),
            const VerticalDivider(indent: 8, endIndent: 8, width: 16),
            _ToolBtn(
              icon: Icons.tune_rounded,
              tooltip: 'Detalhes',
              onTap: onOpenMetadata,
              color: AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _ToolBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Icon(
            icon,
            size: 20,
            color: color ??
                (isDark ? Colors.white70 : AppColors.mutedInk),
          ),
        ),
      ),
    );
  }
}
