import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF0F9D8A);
const Color kTextColor = Color(0xFF6F6F86);
const Color kMutedTextColor = Color(0xFFB1B6C7);
const Color kDividerColor = Color(0xFFE9EBF2);

bool isWideLayout(BuildContext context) {
  return MediaQuery.of(context).size.width >= 700;
}

BoxConstraints authMaxWidthConstraints(BuildContext context) {
  return BoxConstraints(maxWidth: isWideLayout(context) ? 520 : double.infinity);
}
