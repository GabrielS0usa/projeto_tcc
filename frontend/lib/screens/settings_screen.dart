import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: VivaBemColors.cinzaClaro,
      body: Center(
        child: Text(
          'Tela de Configurações',
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
