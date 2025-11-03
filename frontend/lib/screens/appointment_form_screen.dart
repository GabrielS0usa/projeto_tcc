import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto/services/api_service.dart';
import '../theme/app_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment_model.dart'; // <-- 1. IMPORTA O MODELO CENTRAL

// 2. AS DEFINIÇÕES LOCAIS DE 'AppointmentType' E 'Appointment' FORAM REMOVIDAS DAQUI

class AppointmentFormScreen extends StatefulWidget {
  final Appointment? appointment; // <-- 3. Agora usa o modelo importado

  const AppointmentFormScreen({Key? key, this.appointment}) : super(key: key);

  @override
  _AppointmentFormScreenState createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _doctorController;
  late TextEditingController _locationController;
  late DateTime _selectedDate;
  AppointmentType _type = AppointmentType.consulta; // <-- 4. Agora usa o enum importado
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    final appointment = widget.appointment;
    _titleController = TextEditingController(text: appointment?.title ?? '');
    _doctorController = TextEditingController(text: appointment?.doctor ?? '');
    _locationController = TextEditingController(text: appointment?.location ?? '');
    _selectedDate = appointment?.date ?? DateTime.now();
    _type = appointment?.type ?? AppointmentType.consulta;
    _isCompleted = appointment?.isCompleted ?? false;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: VivaBemColors.vermelhoErro,
      ),
    );
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

  
    final data = {
      'title': _titleController.text,
      'doctor': _doctorController.text,
      'location': _locationController.text,
      'type': _type == AppointmentType.exame ? 'EXAME' : 'CONSULTA',
      'date': _selectedDate.toIso8601String(),
      'completed': _isCompleted,
    };

    try {
      http.Response response;

      if (widget.appointment == null) {
        response = await _apiService.post('/appointments', data);
      } else {
        response = await _apiService.put('/appointments/${widget.appointment!.id}', data);
      }

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        final errorData = jsonDecode(response.body);
        _showError(errorData['message'] ?? 'Erro ao salvar compromisso.');
      }
    } catch (e) {
      _showError('Erro de conexão: $e');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _deleteAppointment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VivaBemColors.cinzaEscuro,
        title: const Text('Excluir compromisso', style: TextStyle(color: Colors.white)),
        content: const Text('Tem certeza que deseja excluir este compromisso?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() { _isLoading = true; });

    try {
      final response = await _apiService.delete('/appointments/${widget.appointment!.id}');
      
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        Navigator.pop(context, true);
      } else {
        final errorData = jsonDecode(response.body);
        _showError(errorData['message'] ?? 'Erro ao excluir compromisso.');
      }
    } catch (e) {
      _showError('Erro de conexão: $e');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointment != null;

    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Compromisso' : 'Novo Compromisso'),
        backgroundColor: HealthPalete.vermelhoPrincipal,
        foregroundColor: VivaBemColors.branco,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              tooltip: 'Excluir compromisso',
              onPressed: _isLoading ? null : _deleteAppointment,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: VivaBemColors.branco),
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doctorController,
                style: const TextStyle(color: VivaBemColors.branco),
                decoration: const InputDecoration(labelText: 'Médico ou Clínica'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                style: const TextStyle(color: VivaBemColors.branco),
                decoration: const InputDecoration(labelText: 'Local'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AppointmentType>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: AppointmentType.consulta, child: Text('Consulta')),
                  DropdownMenuItem(value: AppointmentType.exame, child: Text('Exame')),
                ],
                onChanged: (v) => setState(() => _type = v!),
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(DateFormat('dd/MM/yyyy – HH:mm').format(_selectedDate),
                    style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.calendar_today, color: Colors.white),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    locale: const Locale('pt', 'BR'),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDate),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Marcar como realizado', style: TextStyle(color: Colors.white)),
                value: _isCompleted,
                onChanged: (v) => setState(() => _isCompleted = v),
                activeColor: HealthPalete.azulSereno,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveAppointment,
                icon: _isLoading 
                    ? Container(
                        width: 24, height: 24, 
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Salvando...' : 'Salvar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HealthPalete.azulSereno,
                  foregroundColor: VivaBemColors.branco,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

