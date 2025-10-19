import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_colors.dart';

enum AppointmentType { consulta, exame }

class Appointment {
  final String title;
  final AppointmentType type;
  final DateTime date;
  final String doctor;
  final String location;
  bool isCompleted;

  Appointment({
    required this.title,
    required this.type,
    required this.date,
    required this.doctor,
    required this.location,
    this.isCompleted = false,
  });
}

class SaudeGestaoScreen extends StatefulWidget {
  const SaudeGestaoScreen({Key? key}) : super(key: key);

  @override
  _SaudeGestaoScreenState createState() => _SaudeGestaoScreenState();
}

class _SaudeGestaoScreenState extends State<SaudeGestaoScreen> {
  // Simulação de uma lista de compromissos (mantida)
  final List<Appointment> _appointments = [
    Appointment(title: 'Exame de Sangue', type: AppointmentType.exame, date: DateTime.now().add(const Duration(hours: 2)), doctor: 'Laboratório VivaBem', location: 'Unidade Centro', isCompleted: false),
    Appointment(title: 'Cardiologista', type: AppointmentType.consulta, date: DateTime.now().add(const Duration(days: 3, hours: 4)), doctor: 'Dr. Carlos Andrade', location: 'Hospital Vida e Saúde'),
    Appointment(title: 'Oftalmologista', type: AppointmentType.consulta, date: DateTime.now().subtract(const Duration(days: 10)), doctor: 'Dra. Lúcia', location: 'Clínica Visão Clara', isCompleted: true),
    Appointment(title: 'Raio-X do Tórax', type: AppointmentType.exame, date: DateTime.now().add(const Duration(days: 15)), doctor: 'Radiologia Imagem', location: 'Hospital Vida e Saúde'),
  ];

  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    return _appointments.where((appointment) => isSameDay(appointment.date, day)).toList();
  }
  
  Appointment? get _nextAppointment {
    try {
      return _appointments.where((a) => a.date.isAfter(DateTime.now()) && !a.isCompleted).first;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Appointment> selectedDayAppointments = _getAppointmentsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      appBar: AppBar(
        title: const Text('Minha Saúde'),
        // MUDANÇA: Usando a nova paleta
        backgroundColor: SaudePalete.vermelhoPrincipal,
        foregroundColor: VivaBemColors.branco,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_nextAppointment != null) _buildUpcomingAppointmentCard(_nextAppointment!),
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
                  return _buildAppointmentListItem(selectedDayAppointments[index]);
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () { /* TODO: Navegar para tela de adicionar compromisso */ },
        label: const Text('Adicionar'),
        icon: const Icon(Icons.add),
        backgroundColor: SaudePalete.vermelhoPrincipal,
      ),
    );
  }

  Widget _buildUpcomingAppointmentCard(Appointment appointment) {
    final daysUntil = appointment.date.difference(DateTime.now()).inDays;
    String countdownText = daysUntil == 0 ? 'É hoje!' : 'Consulta em $daysUntil dias';

    return Card(
      color: SaudePalete.azulSereno.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: SaudePalete.azulSereno.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PRÓXIMO COMPROMISSO', style: TextStyle(color: SaudePalete.azulSereno, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Text(appointment.title, style: const TextStyle(color: VivaBemColors.branco, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(countdownText, style: const TextStyle(color: VivaBemColors.branco, fontSize: 18, fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text('${appointment.doctor} • ${appointment.location}', style: TextStyle(color: VivaBemColors.branco.withOpacity(0.7), fontSize: 16)),
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
          onDaySelected: (selectedDay, focusedDay) => setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          }),
          eventLoader: _getAppointmentsForDay,
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: VivaBemColors.branco),
            weekendTextStyle: TextStyle(color: VivaBemColors.branco.withOpacity(0.7)),
            todayDecoration: BoxDecoration(
              color: SaudePalete.amareloAgendado.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: SaudePalete.laranjaCalendario,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: SaudePalete.azulSereno,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(color: VivaBemColors.branco, fontSize: 18),
            leftChevronIcon: const Icon(Icons.chevron_left, color: VivaBemColors.branco),
            rightChevronIcon: const Icon(Icons.chevron_right, color: VivaBemColors.branco),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentListHeader() {
    return Text(
      'Compromissos para ${DateFormat('d \'de\' MMMM', 'pt_BR').format(_selectedDay)}',
      style: const TextStyle(color: VivaBemColors.branco, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAppointmentListItem(Appointment appointment) {
    IconData typeIcon = appointment.type == AppointmentType.consulta ? FontAwesomeIcons.stethoscope : FontAwesomeIcons.vial;
    Color statusColor = appointment.isCompleted ? VivaBemColors.verdeConfirmacao : SaudePalete.amareloAgendado;
    String statusText = appointment.isCompleted ? "Realizado" : "Agendado";

    return Card(
      color: VivaBemColors.branco.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(typeIcon, color: statusColor, size: 28),
        title: Text(appointment.title, style: const TextStyle(color: VivaBemColors.branco, fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('${appointment.doctor}\n${DateFormat('HH:mm').format(appointment.date)} • ${appointment.location}', style: TextStyle(color: VivaBemColors.branco.withOpacity(0.7))),
        trailing: Chip(
          label: Text(statusText, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: statusColor.withOpacity(0.2),
          side: BorderSide(color: statusColor),
        ),
        onTap: () { /* TODO */ },
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
          style: TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}