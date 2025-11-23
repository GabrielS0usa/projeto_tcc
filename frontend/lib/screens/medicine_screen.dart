import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/medication_task.dart';
import '../models/medicine_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'add_medicine_screen.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({Key? key}) : super(key: key);

  @override
  _MedicinesScreenState createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  List<MedicationTask> _tasks = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchTodayTasks();
  }

  Future<void> _fetchTodayTasks() async {
    try {
      final response = await _apiService.get('/medicines/tasks/today');
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _tasks = data.map((json) => MedicationTask.fromJson(json)).toList();
        });
      } else {
        _showError('Falha ao carregar as tarefas.');
      }
    } catch (e) {
      _showError('Erro de conexão: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsTaken(int index, bool newState) async {
    final task = _tasks[index];

    setState(() {
      task.taken = newState;
    });

    try {
      final response = await _apiService.put(
        '/medicines/tasks/${task.taskId}',
        {'taken': newState},
      );

      if (response.statusCode != 200) {
        setState(() {
          task.taken = !newState;
        });
        _showError('Falha ao salvar o status. Tente novamente.');
      }
    } catch (e) {
      setState(() {
        task.taken = !newState;
      });
      _showError('Erro de conexão ao salvar.');
    }
  }

  Future<void> _deleteSchedule(int medicineId) async {
    try {
      final response = await _apiService.delete('/medicines/$medicineId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSuccess('Remédio removido com sucesso!');
        setState(() {
          _tasks.removeWhere((task) => task.medicineId == medicineId);
        });
      } else {
        _showError('Falha ao remover o remédio.');
      }
    } catch (e) {
      _showError('Erro de conexão ao remover.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), backgroundColor: VivaBemColors.vermelhoErro),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: VivaBemColors.verdeConfirmacao),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VivaBemColors.branco,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: VivaBemColors.branco,
        ),
        title: const Text('Remédios de Hoje',
            style: TextStyle(color: VivaBemColors.branco)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                HealthPalete.azulSereno,
                HealthPalete.azulSereno.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: HealthPalete.azulSereno))
          : _tasks.isEmpty
              ? const Center(
                  child: Text(
                  "Nenhum remédio agendado para hoje.",
                  style: TextStyle(color: VivaBemColors.cinzaEscuro),
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) =>
                      _buildMedicineItem(_tasks[index], index),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newMedicineSchedule = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
          );
          if (newMedicineSchedule != null && newMedicineSchedule is Medicine) {
            try {
              Map<String, dynamic> scheduleData = {
                "name": newMedicineSchedule.name,
                "dose": newMedicineSchedule.dose,
                "startTime": newMedicineSchedule.startTime,
                "intervalHours": newMedicineSchedule.intervalHours,
                "durationDays": newMedicineSchedule.durationDays,
                "startDate": newMedicineSchedule.startDate
              };
              final response =
                  await _apiService.post('/medicines/save', scheduleData);

              if (response.statusCode == 201) {
                _showSuccess('Remédio salvo com sucesso!');
                setState(() => _isLoading = true);
                _fetchTodayTasks();
              } else {
                final errorData = jsonDecode(response.body);
                _showError(
                    errorData['message'] ?? 'Falha ao salvar o novo remédio.');
              }
            } catch (e) {
              _showError('Erro de conexão ao salvar.');
            }
          }
        },
        backgroundColor: VivaBemColors.cinzaEscuro,
        child: const Icon(Icons.add, color: VivaBemColors.branco, size: 30),
        shape: const CircleBorder(),
      ),
    );
  }

  Widget _buildMedicineItem(MedicationTask task, int index) {
    return Dismissible(
      key: Key(task.taskId.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteSchedule(task.medicineId),
      background: Container(
        color: VivaBemColors.vermelhoErro,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: VivaBemColors.branco),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: VivaBemColors.branco,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: VivaBemColors.cinzaClaro),
        ),
        child: Row(
          children: [
            Transform.scale(
              scale: 1.8,
              child: Checkbox(
                value: task.taken,
                onChanged: (bool? newState) {
                  if (newState != null) {
                    _markAsTaken(index, newState);
                  }
                },
                activeColor: VivaBemColors.cinzaEscuro,
                checkColor: VivaBemColors.branco,
                side: BorderSide(
                    color: VivaBemColors.cinzaEscuro.withOpacity(0.5),
                    width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${task.name} ${task.dose}',
                style: TextStyle(
                  color: task.taken
                      ? VivaBemColors.cinzaEscuro.withOpacity(0.5)
                      : VivaBemColors.cinzaEscuro,
                  decoration: task.taken ? TextDecoration.lineThrough : null,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              DateFormat('HH:mm').format(task.scheduledTime),
              style: TextStyle(
                color: task.taken
                    ? MedicinePalete.cinzaStatusConcluido
                    : VivaBemColors.cinzaEscuro.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
