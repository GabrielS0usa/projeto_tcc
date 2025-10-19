import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projeto/screens/health_mngment.dart';
import 'package:projeto/screens/nutritional_diary_screen.dart';
import 'package:projeto/screens/wellness_diary_screen.dart';
import 'health_mngment.dart';
import 'medicine_screen.dart';
import '../theme/app_colors.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, Raimundo!',
                style: TextStyle(
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
                      color: VivaBemColors.amareloDourado, // MUDANÇA
                      context: context,
                      destinationPage: const WellnessDiaryScreen(),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.heartPulse,
                      color: VivaBemColors.vermelhoVibrante, // MUDANÇA
                      context: context,
                      destinationPage: const SaudeGestaoScreen(),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.brain,
                      color: VivaBemColors.azulRoyal, // MUDANÇA
                      context: context,
                      destinationPage: const DetailPage(
                        title: 'Mente Ativa',
                        backgroundColor: VivaBemColors.azulRoyal, // MUDANÇA
                      ),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.dumbbell,
                      color: VivaBemColors.rosaVibrante, // MUDANÇA
                      context: context,
                      destinationPage: const DetailPage(
                        title: 'Exercícios',
                        backgroundColor: VivaBemColors.rosaVibrante, // MUDANÇA
                      ),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.plateWheat,
                      color: VivaBemColors.laranjaVibrante, // MUDANÇA
                      context: context,
                      destinationPage: const NutricaoDiarioScreen(),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.pills,
                      color: VivaBemColors.verdeEsmeralda, // MUDANÇA
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

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: VivaBemColors.azulMarinho, // MUDANÇA
        selectedItemColor: VivaBemColors.amareloDourado, // MUDANÇA
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
      ),
    );
  }


  Widget _buildProgressBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: VivaBemColors.azulMarinho.withOpacity(0.5), // MUDANÇA
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth * (18 / 20),
                decoration: BoxDecoration(
                  color: VivaBemColors.laranjaVibrante, // MUDANÇA
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
          const Center(
            child: Text(
              '18 / 20',
              style: TextStyle(
                color: VivaBemColors.branco,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required Color color,
    required BuildContext context,
    required Widget destinationPage,
  }) {
    // MUDANÇA: Lógica de contraste atualizada com o novo nome da cor
    final Color iconColor = (color == VivaBemColors.amareloDourado)
        ? VivaBemColors.cinzaEscuro // Ícone escuro para o fundo amarelo
        : VivaBemColors.branco;     // Ícone branco para os demais fundos

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
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 60,
            color: iconColor,
          ),
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
    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: (backgroundColor == VivaBemColors.amareloDourado || backgroundColor == VivaBemColors.azulRoyal || backgroundColor == VivaBemColors.laranjaVibrante || backgroundColor == VivaBemColors.verdeEsmeralda) 
                ? VivaBemColors.cinzaEscuro 
                : VivaBemColors.branco,
          ),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(
          color: (backgroundColor == VivaBemColors.amareloDourado || backgroundColor == VivaBemColors.azulRoyal || backgroundColor == VivaBemColors.laranjaVibrante || backgroundColor == VivaBemColors.verdeEsmeralda) 
              ? VivaBemColors.cinzaEscuro 
              : VivaBemColors.branco,
        ),
      ),
      body: Center(
        child: Text(
          'Página de $title',
          style: const TextStyle(color: VivaBemColors.branco, fontSize: 24),
        ),
      ),
    );
  }
}