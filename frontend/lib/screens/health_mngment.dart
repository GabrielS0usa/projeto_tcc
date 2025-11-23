import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:projeto/screens/appointment_form_screen.dart'
    hide Appointment, AppointmentType;
import 'package:table_calendar/table_calendar.dart';

import '../models/appointment_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class SaudeGestaoScreen extends StatefulWidget {
  const SaudeGestaoScreen({Key? key}) : super(key: key);

  @override
  _SaudeGestaoScreenState createState() => _SaudeGestaoScreenState();
}

class _SaudeGestaoScreenState extends State<SaudeGestaoScreen> {
  final ApiService _apiService = ApiService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final response = await _apiService.get('/appointments');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _appointments = data.map((e) => Appointment.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        debugPrint('Erro ao buscar compromissos: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Erro na requisição: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addOrEditAppointment({Appointment? existing}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentFormScreen(appointment: existing),
      ),
    );

    if (result == true) {
      await _fetchAppointments();
    }
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    return _appointments.where((a) => isSameDay(a.date, day)).toList();
  }

  Appointment? get _nextAppointment {
    final now = DateTime.now();
    final upcoming = _appointments
        .where((a) => a.date.isAfter(now) && !a.isCompleted)
        .toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming.first;
  }

  @override
  Widget build(BuildContext context) {
    List<Appointment> selectedDayAppointments =
        _getAppointmentsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      appBar: AppBar(
        title: const Text('Minha Saúde'),
        backgroundColor: HealthPalete.vermelhoPrincipal,
        foregroundColor: VivaBemColors.branco,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: VivaBemColors.branco))
          : RefreshIndicator(
              onRefresh: _fetchAppointments,
              color: HealthPalete.vermelhoPrincipal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_nextAppointment != null)
                      _buildUpcomingAppointmentCard(_nextAppointment!),
                    const SizedBox(height: 24),
                    _buildCalendarCard(),
                    const SizedBox(height: 24),
                    _buildAppointmentListHeader(),
                    const SizedBox(height: 16),
                    if (selectedDayAppointments.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: selectedDayAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = selectedDayAppointments[index];
                          return GestureDetector(
                            onTap: () =>
                                _addOrEditAppointment(existing: appointment),
                            child: _buildAppointmentListItem(appointment),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditAppointment(),
        label: const Text('Adicionar'),
        icon: const Icon(Icons.add),
        backgroundColor: HealthPalete.azulSereno,
      ),
    );
  }

  Widget _buildUpcomingAppointmentCard(Appointment appointment) {
    final daysUntil = appointment.date.difference(DateTime.now()).inDays;
    final countdownText =
        daysUntil == 0 ? 'É hoje!' : 'Consulta em $daysUntil dias';

    return Card(
      color: HealthPalete.azulSereno.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: HealthPalete.azulSereno.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PRÓXIMO COMPROMISSO',
                style: TextStyle(
                    color: HealthPalete.azulSereno,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Text(appointment.title,
                style: const TextStyle(
                    color: VivaBemColors.branco,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(countdownText,
                style: const TextStyle(
                    color: VivaBemColors.branco,
                    fontSize: 18,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text('${appointment.doctor} • ${appointment.location}',
                style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.7),
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Card(
      color: VivaBemColors.cinzaEscuro.withRed(55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          locale: 'pt_BR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) => setState(
              () => {_selectedDay = selectedDay, _focusedDay = focusedDay}),
          eventLoader: _getAppointmentsForDay,
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: VivaBemColors.branco),
            weekendTextStyle:
                TextStyle(color: VivaBemColors.branco.withOpacity(0.7)),
            todayDecoration: BoxDecoration(
              color: HealthPalete.amareloAgendado.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: HealthPalete.laranjaCalendario,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: HealthPalete.azulSereno,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle:
                const TextStyle(color: VivaBemColors.branco, fontSize: 18),
            leftChevronIcon:
                const Icon(Icons.chevron_left, color: VivaBemColors.branco),
            rightChevronIcon:
                const Icon(Icons.chevron_right, color: VivaBemColors.branco),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentListHeader() {
    return Text(
      'Compromissos para ${DateFormat('d \'de\' MMMM', 'pt_BR').format(_selectedDay)}',
      style: const TextStyle(
          color: VivaBemColors.branco,
          fontSize: 20,
          fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAppointmentListItem(Appointment appointment) {
    final typeIcon = appointment.type == AppointmentType.consulta
        ? FontAwesomeIcons.stethoscope
        : FontAwesomeIcons.vial;
    final statusColor = appointment.isCompleted
        ? VivaBemColors.verdeConfirmacao
        : HealthPalete.amareloAgendado;
    final statusText = appointment.isCompleted ? "Realizado" : "Agendado";

    return Card(
      color: VivaBemColors.branco.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(typeIcon, color: statusColor, size: 28),
        title: Text(appointment.title,
            style: const TextStyle(
                color: VivaBemColors.branco,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        subtitle: Text(
            '${appointment.doctor}\n${DateFormat('HH:mm').format(appointment.date)} • ${appointment.location}',
            style: TextStyle(color: VivaBemColors.branco.withOpacity(0.7))),
        trailing: Chip(
          label: Text(statusText,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: statusColor.withOpacity(0.2),
          side: BorderSide(color: statusColor),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Text(
          'Nenhum compromisso para este dia.\nDia livre para relaxar!',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}
