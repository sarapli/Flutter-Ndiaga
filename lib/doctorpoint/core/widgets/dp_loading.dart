import 'package:flutter/material.dart';

class DPLoading extends StatelessWidget {
  const DPLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
