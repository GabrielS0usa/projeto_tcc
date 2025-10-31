import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // Importa suas cores

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos um Scaffold para manter a estrutura padrão,
    // mas sem AppBar, pois ela já está na HealthScreen (ou MainScreen)
    // se precisarmos de uma AppBar específica aqui, podemos adicioná-la.
    return const Scaffold(
      backgroundColor: VivaBemColors.cinzaClaro, // Cor de fundo suave
      body: Center(
        child: Text(
          'Tela de Estatísticas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: VivaBemColors.cinzaEscuro,
          ),
        ),
      ),
    );
  }
}
