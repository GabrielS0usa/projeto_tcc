// lib/models/medicine_model.dart

class Medicine {
  final String name;
  final String dose;
  final String time;
  bool taken;

  Medicine({
    required this.name,
    required this.dose,
    required this.time,
    this.taken = false,
  });
}
