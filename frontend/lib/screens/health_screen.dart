import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projeto/screens/medicine_screen.dart';
import 'package:projeto/screens/nutritional_diary_screen.dart';
import 'package:projeto/screens/settings_screen.dart';
import 'package:projeto/screens/stats_screen.dart';
import 'package:projeto/screens/wellness_diary_screen.dart';
import 'package:projeto/services/api_service.dart';
import '../theme/app_colors.dart';

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
    return Scaffold(
        appBar: AppBar(title: Text(title)), body: Center(child: Text(title)));
  }
}

class HealthScreen extends StatefulWidget {
  const HealthScreen({Key? key}) : super(key: key);
  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _userName = "...";
  int _completedTasks = 0;
  int _totalTasks = 10;
  int _selectedIndex = 0;
  Timer? _updateTimer;
  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _selectedIndex == 0) {
        _fetchDashboardData();
      }
    });
  }

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
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeScreenContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: VivaBemColors.branco),
      );
    }
    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      body: SafeArea(
        child: Padding(
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
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25,
                  childAspectRatio: 1.1,
                  children: [
                    _buildGridItem(
                      icon: FontAwesomeIcons.faceSmile,
                      color: VivaBemColors.amareloDourado,
                      context: context,
                      destinationPage: const WellnessDiaryScreen(),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.heartPulse,
                      color: VivaBemColors.vermelhoVibrante,
                      context: context,
                      destinationPage: const DetailPage(
                        title: 'Saúde',
                        backgroundColor: VivaBemColors.vermelhoVibrante,
                      ),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.brain,
                      color: VivaBemColors.azulRoyal,
                      context: context,
                      destinationPage: const DetailPage(
                        title: 'Mente Ativa',
                        backgroundColor: VivaBemColors.azulRoyal,
                      ),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.dumbbell,
                      color: VivaBemColors.rosaVibrante,
                      context: context,
                      destinationPage: const DetailPage(
                        title: 'Exercícios',
                        backgroundColor: VivaBemColors.rosaVibrante,
                      ),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.plateWheat,
                      color: VivaBemColors.laranjaVibrante,
                      context: context,
                      destinationPage: const NutricaoDiarioScreen(),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.pills,
                      color: VivaBemColors.verdeEsmeralda,
                      context: context,
                      destinationPage: const MedicinesScreen(),
                    ),
                  ],
                ),
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
    return Container(
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
                      color: VivaBemColors.laranjaVibrante,
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required Color color,
    required BuildContext context,
    required Widget destinationPage,
  }) {
    final Color iconColor = (color == VivaBemColors.amareloDourado)
        ? VivaBemColors.cinzaEscuro
        : VivaBemColors.branco;
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
        ),
        child: Center(
          child: FaIcon(icon, size: 60, color: iconColor),
        ),
      ),
    );
  }
}