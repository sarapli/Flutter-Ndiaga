import 'package:flutter/material.dart';

import 'dp_button.dart';

class DPErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const DPErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 46, color: cs.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              DPButton(
                label: 'Réessayer',
                onPressed: onRetry,
                variant: DPButtonVariant.outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
