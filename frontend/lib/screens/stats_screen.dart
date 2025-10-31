// lib/screens/stats_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

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
                'Estatísticas',
                style: TextStyle(
                  color: VivaBemColors.branco,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Acompanhe seu progresso',
                style: TextStyle(
                  color: VivaBemColors.branco.withOpacity(0.8),
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: VivaBemColors.azulMarinho.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.chartLine,
                          size: 80,
                          color: VivaBemColors.amareloDourado,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Estatísticas em Desenvolvimento',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: VivaBemColors.branco,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Em breve você poderá visualizar gráficos detalhados do seu progresso de saúde e bem-estar.',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
