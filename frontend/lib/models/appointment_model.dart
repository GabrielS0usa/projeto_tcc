import 'package:flutter/material.dart';

enum AppointmentType { consulta, exame }

class Appointment {
  final int id;
  final String title;
  final String? doctor;
  final String? location;
  final DateTime date;
  final AppointmentType type;
  final bool isCompleted;

  Appointment({
    required this.id,
    required this.title,
    this.doctor,
    this.location,
    required this.date,
    required this.type,
    required this.isCompleted,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] == 'EXAME' 
          ? AppointmentType.exame 
          : AppointmentType.consulta,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      doctor: json['doctor'] ?? '',
      location: json['location'] ?? '',
      isCompleted: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type == AppointmentType.exame ? 'EXAME' : 'CONSULTA',
      'date': date.toIso8601String(),
      'doctor': doctor,
      'location': location,
      'completed': isCompleted,
    };
  }
}