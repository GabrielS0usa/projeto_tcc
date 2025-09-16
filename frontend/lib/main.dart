import 'package:flutter/material.dart';
import 'screens/health_screen.dart'; // 1. Importe o arquivo da sua tela

void main() {
  // A função main() é o ponto de partida de todo aplicativo Flutter.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove o banner de "Debug" no canto superior direito
      debugShowCheckedModeBanner: false,

      // Define a tela inicial do aplicativo.
      // Aqui estamos chamando a classe da nossa tela.
      home: HealthScreen(),
    );
  }
}