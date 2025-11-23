class MedicationTask {
  final int taskId; 
  final int medicineId;
  final String name;
  final String dose;
  final DateTime scheduledTime;
  bool taken; 

  MedicationTask({
    required this.taskId,
    required this.medicineId,
    required this.name,
    required this.dose,
    required this.scheduledTime,
    required this.taken,
  });

  factory MedicationTask.fromJson(Map<String, dynamic> json) {
    return MedicationTask(
      taskId: json['taskId'] ?? 0,
      medicineId: json['medicineId'] ?? 0,
      name: json['name'] ?? 'No Name',
      dose: json['dose'] ?? 'No Dose',
      scheduledTime: DateTime.tryParse(json['scheduledTime'] ?? '') ?? DateTime.now(),
      taken: json['taken'] ?? false,
    );
  }
}