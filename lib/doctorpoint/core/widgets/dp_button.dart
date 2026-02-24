import 'package:flutter/material.dart';

import '../theme/dp_colors.dart';

enum DPButtonVariant {
  primary,
  secondary,
  outlined,
  danger,
  ghost,
}

class DPButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DPButtonVariant variant;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;

  const DPButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DPButtonVariant.primary,
    this.isLoading = false,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    final ColorScheme cs = Theme.of(context).colorScheme;

    Color foreground;
    Color? background;
    BorderSide? side;

    switch (variant) {
      case DPButtonVariant.primary:
        background = DPColors.primary;
        foreground = Colors.white;
        break;
      case DPButtonVariant.secondary:
        background = DPColors.secondary;
        foreground = Colors.white;
        break;
      case DPButtonVariant.outlined:
        background = Colors.transparent;
        foreground = DPColors.primary;
        side = BorderSide(color: cs.outlineVariant);
        break;
      case DPButtonVariant.danger:
        background = DPColors.error;
        foreground = Colors.white;
        break;
      case DPButtonVariant.ghost:
        background = Colors.transparent;
        foreground = DPColors.primary;
        break;
    }

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          ),
          const SizedBox(width: 10),
        ] else ...[
          if (leading != null) ...[
            IconTheme(data: IconThemeData(color: foreground), child: leading!),
            const SizedBox(width: 8),
          ],
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isLoading && trailing != null) ...[
          const SizedBox(width: 8),
          IconTheme(data: IconThemeData(color: foreground), child: trailing!),
        ],
      ],
    );

    final style = ButtonStyle(
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );

    if (variant == DPButtonVariant.outlined || variant == DPButtonVariant.ghost) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: style.copyWith(
            foregroundColor: WidgetStateProperty.all(foreground),
            side: WidgetStateProperty.all(side),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: style.copyWith(
          backgroundColor: WidgetStateProperty.all(background),
          foregroundColor: WidgetStateProperty.all(foreground),
        ),
        child: child,
      ),
    );
  }
}
