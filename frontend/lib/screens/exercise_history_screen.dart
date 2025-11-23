import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/physical_activity.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class ExerciseHistoryScreen extends StatefulWidget {
  const ExerciseHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseHistoryScreen> createState() => _ExerciseHistoryScreenState();
}

class _ExerciseHistoryScreenState extends State<ExerciseHistoryScreen> {
  bool _isLoading = false;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<WalkingSession> _sessions = [];
  WeeklyExerciseSummary _weeklySummary = WeeklyExerciseSummary.empty();

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final responses = await Future.wait([
        _apiService.getWeeklyExerciseSummary(),
        _apiService.getAllWalkingSessions()
      ]);

      final summaryResponse = responses[0];
      final sessionsResponse = responses[1];

      if (summaryResponse.statusCode == 200 &&
          sessionsResponse.statusCode == 200) {
        final summaryData = jsonDecode(utf8.decode(summaryResponse.bodyBytes));
        final newWeeklySummary = WeeklyExerciseSummary.fromJson(summaryData);

        final List<dynamic> sessionsData =
            jsonDecode(utf8.decode(sessionsResponse.bodyBytes));
        final newSessions =
            sessionsData.map((json) => WalkingSession.fromJson(json)).toList();

        setState(() {
          _weeklySummary = newWeeklySummary;
          _sessions = newSessions;
        });
      } else {
        if (summaryResponse.statusCode != 200) {
          print('Erro ao carregar resumo: ${summaryResponse.body}');
        }
        if (sessionsResponse.statusCode != 200) {
          print('Erro ao carregar sessões: ${sessionsResponse.body}');
        }
        _showErrorSnackBar('Não foi possível carregar o histórico.');
      }
    } catch (e) {
      print('Exceção ao carregar histórico: $e');
      _showErrorSnackBar('Erro de conexão. Tente novamente.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  List<WalkingSession> _getSessionsForDay(DateTime day) {
    return _sessions.where((session) {
      return isSameDay(session.startTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDaySessions = _getSessionsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      appBar: AppBar(
        title: const Text(
          'Histórico de Exercícios',
          style: TextStyle(
            color: VivaBemColors.branco,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: PhysicalExercisesPalete.rosaPrincipal,
        iconTheme: const IconThemeData(color: VivaBemColors.branco),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: PhysicalExercisesPalete.rosaPrincipal,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadHistory,
              color: PhysicalExercisesPalete.rosaPrincipal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeeklySummary(),
                    const SizedBox(height: 24),
                    _buildCalendar(),
                    const SizedBox(height: 24),
                    _buildSelectedDayHeader(),
                    const SizedBox(height: 16),
                    if (selectedDaySessions.isEmpty)
                      _buildEmptyState()
                    else
                      ...selectedDaySessions
                          .map((session) => _buildSessionCard(session)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWeeklySummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PhysicalExercisesPalete.rosaPrincipal.withOpacity(0.3),
            PhysicalExercisesPalete.roxoEnergia.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PhysicalExercisesPalete.rosaPrincipal.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: PhysicalExercisesPalete.amareloTempo,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Resumo Semanal',
                style: TextStyle(
                  color: VivaBemColors.branco,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                icon: Icons.directions_walk,
                value: '${_weeklySummary.totalSteps}',
                label: 'Passos',
                color: PhysicalExercisesPalete.laranjaCaminhada,
              ),
              _buildSummaryItem(
                icon: Icons.timer,
                value: '${_weeklySummary.totalMinutes}min',
                label: 'Tempo',
                color: PhysicalExercisesPalete.amareloTempo,
              ),
              _buildSummaryItem(
                icon: Icons.local_fire_department,
                value: '${_weeklySummary.totalCalories}',
                label: 'Calorias',
                color: PhysicalExercisesPalete.rosaPrincipal,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PhysicalExercisesPalete.verdeObjetivo.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PhysicalExercisesPalete.verdeObjetivo,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: PhysicalExercisesPalete.verdeObjetivo,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_weeklySummary.activeDays} dias ativos esta semana',
                  style: const TextStyle(
                    color: VivaBemColors.branco,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: VivaBemColors.branco.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: VivaBemColors.cinzaEscuro.withRed(55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PhysicalExercisesPalete.rosaPrincipal.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TableCalendar(
          locale: 'pt_BR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: _getSessionsForDay,
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: VivaBemColors.branco),
            weekendTextStyle: TextStyle(
              color: VivaBemColors.branco.withOpacity(0.7),
            ),
            todayDecoration: BoxDecoration(
              color: PhysicalExercisesPalete.amareloTempo.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: PhysicalExercisesPalete.rosaPrincipal,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: PhysicalExercisesPalete.verdeObjetivo,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(
              color: VivaBemColors.branco,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: VivaBemColors.branco,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: VivaBemColors.branco,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: VivaBemColors.branco.withOpacity(0.7),
            ),
            weekendStyle: TextStyle(
              color: VivaBemColors.branco.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayHeader() {
    return Text(
      'Atividades de ${DateFormat('d \'de\' MMMM', 'pt_BR').format(_selectedDay)}',
      style: const TextStyle(
        color: VivaBemColors.branco,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: VivaBemColors.branco.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: VivaBemColors.branco.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 60,
            color: VivaBemColors.branco.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma atividade neste dia',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: VivaBemColors.branco.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(WalkingSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PhysicalExercisesPalete.laranjaCaminhada.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PhysicalExercisesPalete.laranjaCaminhada.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      PhysicalExercisesPalete.laranjaCaminhada.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_walk,
                  color: PhysicalExercisesPalete.laranjaCaminhada,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Caminhada',
                      style: TextStyle(
                        color: VivaBemColors.branco,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(session.startTime),
                      style: TextStyle(
                        color: VivaBemColors.branco.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: PhysicalExercisesPalete.verdeObjetivo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PhysicalExercisesPalete.verdeObjetivo,
                  ),
                ),
                child: Text(
                  session.formattedDuration,
                  style: const TextStyle(
                    color: PhysicalExercisesPalete.verdeObjetivo,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSessionStat(
                  icon: Icons.directions_walk,
                  label: 'Passos',
                  value: '${session.steps}',
                  color: PhysicalExercisesPalete.laranjaCaminhada,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSessionStat(
                  icon: Icons.straighten,
                  label: 'Distância',
                  value: session.formattedDistance,
                  color: PhysicalExercisesPalete.azulDistancia,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSessionStat(
                  icon: Icons.local_fire_department,
                  label: 'Calorias',
                  value: '${session.caloriesBurned}',
                  color: PhysicalExercisesPalete.rosaPrincipal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSessionStat(
                  icon: Icons.speed,
                  label: 'Ritmo',
                  value:
                      '${(session.distanceKm / (session.durationMinutes / 60)).toStringAsFixed(1)} km/h',
                  color: PhysicalExercisesPalete.roxoEnergia,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
