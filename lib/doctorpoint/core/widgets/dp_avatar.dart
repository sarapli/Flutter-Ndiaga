import 'package:flutter/material.dart';

class DPAvatar extends StatelessWidget {
  final String initials;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;

  const DPAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Theme.of(context).colorScheme.primaryContainer;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bg,
      backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty) ? NetworkImage(imageUrl!) : null,
      child: (imageUrl == null || imageUrl!.isEmpty)
          ? Text(
              initials.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }
}
