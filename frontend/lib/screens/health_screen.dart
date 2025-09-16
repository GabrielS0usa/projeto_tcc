import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'medicine_screen.dart';
import '../theme/app_colors.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({Key? key}) : super(key: key);

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
                      icon: FontAwesomeIcons.pills,
                      color: VivaBemColors.botaoVerdeEsmeralda, 
                      context: context,
                      destinationPage: const MedicinesScreen(),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.dumbbell,
                      color: VivaBemColors.botaoRoxoAmetista,    
                      context: context,
                      destinationPage: const DetailPage(
                        title: 'Exercícios',
                        backgroundColor: VivaBemColors.botaoRoxoAmetista,
                      ),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.utensils,
                      color: VivaBemColors.botaoLaranjaQueimado, 
                      context: context,
                      destinationPage: const DetailPage(
                        title: 'Alimentação',
                        backgroundColor: VivaBemColors.botaoLaranjaQueimado,
                      ),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.glassWater,
                      color: VivaBemColors.botaoAzulProfundo,    
                      context: context,
                      destinationPage: const DetailPage(
                        title: 'Hidratação',
                        backgroundColor: VivaBemColors.botaoAzulProfundo,
                      ),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.faceSmile,
                      color: VivaBemColors.botaoAmareloSol,      
                      context: context,
                      destinationPage: const DetailPage(
                        title: 'Humor',
                        backgroundColor: VivaBemColors.botaoAmareloSol,
                      ),
                    ),
                    _buildGridItem(
                      icon: FontAwesomeIcons.heartPulse,
                      color: VivaBemColors.botaoVermelhoPaixao,  
                      context: context,
                      destinationPage: const DetailPage(
                        title: 'Saúde',
                        backgroundColor: VivaBemColors.botaoVermelhoPaixao,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: VivaBemColors.azulPrimario,
        selectedItemColor: VivaBemColors.laranjaPrimario,
        unselectedItemColor: VivaBemColors.branco.withOpacity(0.7),
        showSelectedLabels: false,
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
        color: VivaBemColors.azulClaro.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth * (18 / 20),
                decoration: BoxDecoration(
                  color: VivaBemColors.laranjaPrimario,
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
    final Color iconColor = (color == VivaBemColors.botaoAmareloSol || color == VivaBemColors.cinzaClaro) 
        ? VivaBemColors.cinzaEscuro
        : VivaBemColors.branco;     
        
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
            color: (backgroundColor == VivaBemColors.botaoAmareloSol || backgroundColor == VivaBemColors.azulClaro || backgroundColor == VivaBemColors.laranjaSuave || backgroundColor == VivaBemColors.botaoVerdeEsmeralda) 
                ? VivaBemColors.cinzaEscuro 
                : VivaBemColors.branco,
          ),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(
          color: (backgroundColor == VivaBemColors.botaoAmareloSol || backgroundColor == VivaBemColors.azulClaro || backgroundColor == VivaBemColors.laranjaSuave || backgroundColor == VivaBemColors.botaoVerdeEsmeralda) 
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