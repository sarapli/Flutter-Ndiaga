import 'package:flutter/material.dart';

import 'models/appointment.dart';

enum UserRole { patient, doctor, admin }

class AppSession extends ChangeNotifier {
  UserRole? role;
  String? specialty;
  String? doctorId;
  String? doctorName;
  AppointmentSelection? appointment;
  String? patientName;
  String? patientAgeRange;
  String? patientGender;
  String? patientPhone;
  String? patientProblem;
  Locale? locale;

  void setRole(UserRole value) {
    role = value;
    notifyListeners();
  }

  void setSpecialty(String value) {
    specialty = value;
    notifyListeners();
  }

  void setDoctor(String id, String name) {
    doctorId = id;
    doctorName = name;
    notifyListeners();
  }

  void setAppointment(AppointmentSelection value) {
    appointment = value;
    notifyListeners();
  }

  void setPatientDetails({
    required String name,
    required String ageRange,
    required String gender,
    required String phone,
    required String problem,
  }) {
    patientName = name;
    patientAgeRange = ageRange;
    patientGender = gender;
    patientPhone = phone;
    patientProblem = problem;
    notifyListeners();
  }

  void setLocale(Locale? value) {
    locale = value;
    notifyListeners();
  }
}

final AppSession appSession = AppSession();
