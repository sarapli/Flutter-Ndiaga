import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/theme_cubit.dart';
import 'router/app_router.dart';

class DoctorPointApp extends StatelessWidget {
  const DoctorPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit()..load(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'DoctorPoint',
            themeMode: mode,
            theme: DoctorPointThemes.light,
            darkTheme: DoctorPointThemes.dark,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
