import 'package:flutter/material.dart';

import 'models/appointment.dart';

enum UserRole { patient, doctor }

class AppSession extends ChangeNotifier {
  UserRole? role;
  String? specialty;
  String? doctorName;
  AppointmentSelection? appointment;

  void setRole(UserRole value) {
    role = value;
    notifyListeners();
  }

  void setSpecialty(String value) {
    specialty = value;
    notifyListeners();
  }

  void setDoctor(String name) {
    doctorName = name;
    notifyListeners();
  }

  void setAppointment(AppointmentSelection value) {
    appointment = value;
    notifyListeners();
  }
}

final AppSession appSession = AppSession();
