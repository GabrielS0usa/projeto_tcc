import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projeto/screens/health_mngment.dart';
import 'package:projeto/screens/nutritional_diary_screen.dart';
import 'package:projeto/screens/wellness_diary_screen.dart';
import 'package:projeto/screens/stats_screen.dart';
import 'package:projeto/screens/settings_screen.dart';
import 'medicine_screen.dart';
import '../theme/app_colors.dart';
import '../models/user_profile.dart';
import '../models/health_metrics.dart';
import '../utils/color_utils.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  int _selectedIndex = 0;
  late UserProfile _userProfile;
  late HealthMetrics _healthMetrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Simulate loading user data (replace with actual API call in the future)
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _userProfile = UserProfile.mock();
      _healthMetrics = HealthMetrics.mock();
      _isLoading = false;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Show different screens based on bottom navigation selection
    if (_selectedIndex == 1) {
      return const StatsScreen();
    } else if (_selectedIndex == 2) {
      return const SettingsScreen();
    }

    // Main home screen
    return _buildHomeScreen(context);
  }

  Widget _buildHomeScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      body: _isLoading ? _buildLoadingState() : _buildContent(context),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(VivaBemColors.amareloDourado),
          ),
          const SizedBox(height: 20),
          Text(
            'Carregando...',
            style: TextStyle(
              color: VivaBemColors.branco.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 8),
            _buildProgressLabel(),
            const SizedBox(height: 30),
            _buildProgressBar(),
            const SizedBox(height: 40),
            Expanded(
              child: _buildHealthGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Text(
      'Olá, ${_userProfile.name}!',
      style: TextStyle(
        color: VivaBemColors.branco,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildProgressLabel() {
    return Text(
      'O seu progresso hoje:',
      style: TextStyle(
        color: VivaBemColors.branco.withOpacity(0.8),
        fontSize: 20,
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: VivaBemColors.azulMarinho,
      selectedItemColor: VivaBemColors.amareloDourado,
      unselectedItemColor: VivaBemColors.branco.withOpacity(0.7),
      currentIndex: _selectedIndex,
      onTap: _onBottomNavTap,
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
    );
  }

  Widget _buildHealthGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 25,
      mainAxisSpacing: 25,
      childAspectRatio: 0.95,
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
    );
  }

  Widget _buildProgressBar() {
    final progress = _healthMetrics.progressPercentage;
    final progressText = _healthMetrics.progressText;
    
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
              progressText,
              style: TextStyle(
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
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          VivaBemColors.laranjaVibrante,
                          VivaBemColors.amareloDourado,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
              Center(
                child: Text(
                  progressText,
                  style: const TextStyle(
                    color: VivaBemColors.branco,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
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
        );
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
