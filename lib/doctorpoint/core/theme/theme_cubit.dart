import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'dp_colors.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  static const _boxName = 'doctorpoint_settings';
  static const _key = 'theme_mode';

  Future<void> load() async {
    final box = await Hive.openBox(_boxName);
    final v = box.get(_key, defaultValue: 'light') as String;
    emit(v == 'dark' ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(next);
    final box = await Hive.openBox(_boxName);
    await box.put(_key, next == ThemeMode.dark ? 'dark' : 'light');
  }
}

class DoctorPointThemes {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DPColors.primary,
        secondary: DPColors.secondary,
        brightness: Brightness.light,
      ).copyWith(
        primary: DPColors.primary,
        secondary: DPColors.secondary,
        error: DPColors.error,
        surface: Colors.white,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: DPColors.background,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DPColors.primary,
        secondary: DPColors.secondary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: DPColors.primary,
        secondary: DPColors.secondary,
        error: DPColors.error,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
