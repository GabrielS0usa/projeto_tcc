import 'package:flutter/material.dart';

/// Classe que centraliza toda a paleta de cores do aplicativo VivaBem+.
///
/// Usar esta classe garante consistência visual e facilita a manutenção,
/// pois uma alteração de cor aqui se reflete em todo o app.
class VivaBemColors {
  VivaBemColors._(); // Construtor privado para evitar instanciamento.

  // Cores da Paleta Sugerida (mantidas)
  static const Color laranjaPrimario = Color(0xFFF7B300);
  static const Color azulPrimario = Color(0xFF2E5AAC);
  static const Color laranjaSuave = Color(0xFFFFA65C);
  static const Color azulClaro = Color(0xFF6C8CDB);
  static const Color branco = Color(0xFFFFFFFF);
  static const Color cinzaClaro = Color(0xFFF5F5F5);
  static const Color cinzaEscuro = Color(0xFF333333);
  static const Color verdeConfirmacao = Color(0xFF4CAF50);
  static const Color vermelhoSuave = Color(0xFFF52525);
  
  // NOVAS CORES PARA OS BOTÕES DA GRADE (baseadas na sua imagem)
  static const Color botaoVerdeEsmeralda = Color(0xFF2CB57A); // Para Remédios
  static const Color botaoRoxoAmetista = Color(0xFF6F4A8E);    // Para Exercícios
  static const Color botaoLaranjaQueimado = Color(0xFFF07B53); // Para Alimentação
  static const Color botaoAzulProfundo = Color(0xFF0D5A9A);    // Para Hidratação
  static const Color botaoAmareloSol = Color(0xFFF7E600);      // Para Humor (amarelo puro)
  static const Color botaoVermelhoPaixao = Color(0xFFE74C3C);  // Para Saúde (vermelho mais forte)
}