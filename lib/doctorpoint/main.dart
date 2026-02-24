import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase may be unconfigured in this workspace. DoctorPoint can run with mock data.
  }

  await di.init();

  runApp(const DoctorPointApp());
}
