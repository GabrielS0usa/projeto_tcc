import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projeto/screens/medicine_screen.dart';
import 'package:projeto/screens/nutritional_diary_screen.dart';
import 'package:projeto/screens/settings_screen.dart';
import 'package:projeto/screens/stats_screen.dart';
import 'package:projeto/screens/wellness_diary_screen.dart';
import 'package:projeto/screens/health_mngment.dart';
import 'package:projeto/services/api_service.dart';
import '../theme/app_colors.dart';
import '../utils/color_utils.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;
  bool _isLoading = true;
  String _userName = "Usuário";
  int _completedTasks = 0;
  int _totalTasks = 10;
  Timer? _updateTimer;

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchDashboardData();
  //   _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
  //     if (mounted && _selectedIndex == 0) {
  //       _fetchDashboardData();
  //     }
  //   });
  // }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    String tempUserName = "Usuário";
    int tempCompletedTasks = 0;
    int tempTotalTasks = 1;

    try {
      final profileResponseFuture = _apiService.get('/user/profile');
      final progressResponseFuture = _apiService.get('/user/progress/today');

      final responses = await Future.wait([
        profileResponseFuture,
        progressResponseFuture,
      ]);

      if (!mounted) return;

      if (responses[0].statusCode == 200) {
        final profileData = jsonDecode(responses[0].body);
        tempUserName = profileData['name'] ?? "Usuário";
      } else {
        _showError("Falha ao carregar perfil.");
      }

      if (responses[1].statusCode == 200) {
        final progressData = jsonDecode(responses[1].body);
        tempCompletedTasks = progressData['completed'] ?? 0;
        tempTotalTasks = progressData['total'] ?? 1;
        if (tempCompletedTasks == 0 && tempTotalTasks <= 1) {
          tempCompletedTasks = 0;
          tempTotalTasks = 0;
        }
      } else {
        _showError("Falha ao carregar progresso.");
      }
    } catch (e) {
      _showError('Erro de conexão: $e');
    } finally {
      if (mounted) {
        setState(() {
          _userName = tempUserName;
          _completedTasks = tempCompletedTasks;
          _totalTasks = tempTotalTasks;
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _fetchDashboardData();
    }
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = [
      _buildHomeScreenContent(),
      const StatsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: VivaBemColors.azulMarinho,
        selectedItemColor: VivaBemColors.amareloDourado,
        unselectedItemColor: VivaBemColors.branco.withOpacity(0.7),
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 30),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeScreenContent() {
  if (_isLoading) {
    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      body: const Center(
        child: CircularProgressIndicator(color: VivaBemColors.amareloDourado),
      ),
    );
  }

  return Scaffold(
    backgroundColor: VivaBemColors.cinzaEscuro,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, $_userName!',
              style: const TextStyle(
                color: VivaBemColors.branco,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'O seu progresso hoje:',
              style: TextStyle(
                color: VivaBemColors.branco.withOpacity(0.8),
                fontSize: 20,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 30),
            _buildProgressBar(),
            const SizedBox(height: 40),

            // Grid com shrinkWrap e rolagem desativada (ele rola junto com a tela)
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 25,
              mainAxisSpacing: 25,
              childAspectRatio: 0.95,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGridItem(
                  icon: FontAwesomeIcons.faceSmile,
                  label: 'Bem-Estar',
                  color: VivaBemColors.amareloDourado,
                  context: context,
                  destinationPage: const WellnessDiaryScreen(),
                ),
                _buildGridItem(
                  icon: FontAwesomeIcons.heartPulse,
                  label: 'Saúde',
                  color: VivaBemColors.vermelhoVibrante,
                  context: context,
                  destinationPage: const SaudeGestaoScreen(),
                ),
                _buildGridItem(
                  icon: FontAwesomeIcons.brain,
                  label: 'Mente Ativa',
                  color: VivaBemColors.azulRoyal,
                  context: context,
                  destinationPage: const DetailPage(
                    title: 'Mente Ativa',
                    backgroundColor: VivaBemColors.azulRoyal,
                  ),
                ),
                _buildGridItem(
                  icon: FontAwesomeIcons.dumbbell,
                  label: 'Exercícios',
                  color: VivaBemColors.rosaVibrante,
                  context: context,
                  destinationPage: const DetailPage(
                    title: 'Exercícios',
                    backgroundColor: VivaBemColors.rosaVibrante,
                  ),
                ),
                _buildGridItem(
                  icon: FontAwesomeIcons.plateWheat,
                  label: 'Nutrição',
                  color: VivaBemColors.laranjaVibrante,
                  context: context,
                  destinationPage: const NutricaoDiarioScreen(),
                ),
                _buildGridItem(
                  icon: FontAwesomeIcons.pills,
                  label: 'Medicamentos',
                  color: VivaBemColors.verdeEsmeralda,
                  context: context,
                  destinationPage: const MedicinesScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildProgressBar() {
    double progress = _totalTasks > 0 ? (_completedTasks / _totalTasks) : 0.0;
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0) progress = 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tarefas de Saúde',
              style: TextStyle(
                color: VivaBemColors.branco.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$_completedTasks / $_totalTasks',
              style: const TextStyle(
                color: VivaBemColors.amareloDourado,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: VivaBemColors.azulMarinho.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                        width: constraints.maxWidth * progress,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              VivaBemColors.laranjaVibrante,
                              VivaBemColors.amareloDourado,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Text(
                  '$_completedTasks / $_totalTasks',
                  style: const TextStyle(
                    color: VivaBemColors.branco,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String label,
    required Color color,
    required BuildContext context,
    required Widget destinationPage,
  }) {
    final iconColor = ColorUtils.getIconColor(color);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        ).then((_) {
          _fetchDashboardData();
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 50,
              color: iconColor,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: iconColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final Color backgroundColor;

  const DetailPage({
    Key? key,
    required this.title,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contentColor = ColorUtils.getAppBarContentColor(backgroundColor);

    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: contentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: contentColor),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.construction,
                size: 80,
                color: backgroundColor,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Página de $title',
              style: const TextStyle(
                color: VivaBemColors.branco,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Esta funcionalidade está em desenvolvimento e estará disponível em breve.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: VivaBemColors.branco.withOpacity(0.7),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
