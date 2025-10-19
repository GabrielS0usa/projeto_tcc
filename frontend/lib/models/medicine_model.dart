// lib/models/medicine_model.dart

class Medicine {
  final int id;
  final String name;
  final String dose;
  final String startTime;
  final int intervalHours;
  final int durationDays;
  final String startDate;

  bool taken;

  Medicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.startTime,
    required this.intervalHours,
    required this.durationDays,
    required this.startDate,
    this.taken = false,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      dose: json['dose'] ?? 'No Dose',
      startTime: json['startTime'] ?? '00:00', 
      intervalHours: json['intervalHours'] ?? 24,
      durationDays: json['durationDays'] ?? 1,
      startDate: json['startDate'] ?? '',
    );
  }
}