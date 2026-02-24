import 'package:flutter/material.dart';

import '../theme/dp_colors.dart';

enum DPBadgeVariant {
  success,
  warning,
  error,
  info,
  neutral,
}

class DPBadge extends StatelessWidget {
  final String label;
  final DPBadgeVariant variant;
  final bool dot;

  const DPBadge({
    super.key,
    required this.label,
    this.variant = DPBadgeVariant.neutral,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _colors(BuildContext context) {
    switch (variant) {
      case DPBadgeVariant.success:
        return (DPColors.success.withValues(alpha: 0.14), DPColors.success);
      case DPBadgeVariant.warning:
        return (DPColors.warning.withValues(alpha: 0.14), DPColors.warning);
      case DPBadgeVariant.error:
        return (DPColors.error.withValues(alpha: 0.14), DPColors.error);
      case DPBadgeVariant.info:
        return (DPColors.primary.withValues(alpha: 0.14), DPColors.primary);
      case DPBadgeVariant.neutral:
        final cs = Theme.of(context).colorScheme;
        return (cs.surfaceContainerHighest, cs.onSurfaceVariant);
    }
  }
}
