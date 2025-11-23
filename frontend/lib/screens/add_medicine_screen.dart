import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medicine_model.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({Key? key}) : super(key: key);

  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _startDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _intervalController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();
    _intervalController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _saveMedicine() {
    if (_formKey.currentState!.validate()) {
      final newMedicine = Medicine(
        id: 0,
        name: _nameController.text,
        dose: _doseController.text,
        startDate: _startDateController.text,
        startTime: _startTimeController.text,
        intervalHours: int.tryParse(_intervalController.text) ?? 8,
        durationDays: int.tryParse(_durationController.text) ?? 1,
      );

      Navigator.pop(context, newMedicine);
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _startDateController.text = formattedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final now = DateTime.now();
      final dt = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      final format = DateFormat('HH:mm:ss');
      setState(() {
        _startTimeController.text = format.format(dt);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Adicionar Remédio',
            style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF89D2F3), Color(0xFFC0E6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                  controller: _nameController, label: 'Nome do Remédio'),
              const SizedBox(height: 20),
              _buildTextField(
                  controller: _doseController, label: 'Dose (ex: 500mg)'),
              const SizedBox(height: 20),
              _buildDateField(
                  controller: _startDateController,
                  label: 'Data de Início',
                  onTap: _selectDate),
              const SizedBox(height: 20),
              _buildDateField(
                  controller: _startTimeController,
                  label: 'Horário de Início',
                  onTap: _selectTime),
              const SizedBox(height: 20),
              _buildTextField(
                  controller: _intervalController,
                  label: 'Intervalo (em horas)',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              _buildTextField(
                  controller: _durationController,
                  label: 'Duração (em dias)',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveMedicine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Salvar', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, preencha este campo';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(
      {required TextEditingController controller,
      required String label,
      required VoidCallback onTap}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione uma data';
        }
        return null;
      },
    );
  }
}
