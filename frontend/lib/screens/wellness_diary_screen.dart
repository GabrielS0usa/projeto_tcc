// lib/screens/wellness_diary_screen.dart (ou o nome do seu arquivo)

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

enum Humor { ansioso, triste, neutro, calmo, alegre }
enum PeriodoDia { manha, tarde, noite }

class WellnessDiaryScreen extends StatefulWidget {
  const WellnessDiaryScreen({Key? key}) : super(key: key);

  @override
  _WellnessDiaryScreenState createState() => _WellnessDiaryScreenState();
}


class _WellnessDiaryScreenState extends State<WellnessDiaryScreen> {
  Humor? _selectedHumor;
  final TextEditingController _noteController = TextEditingController();
  PeriodoDia _currentPeriod = PeriodoDia.manha;

  Humor? _registroManha;
  Humor? _registroTarde;
  Humor? _registroNoite;

  bool get _isPeriodoAtualRegistrado {
    if (_currentPeriod == PeriodoDia.manha) return _registroManha != null;
    if (_currentPeriod == PeriodoDia.tarde) return _registroTarde != null;
    if (_currentPeriod == PeriodoDia.noite) return _registroNoite != null;
    return false;
  }

  @override
  void initState() {
    super.initState();
    _determineCurrentPeriod();
  }

  void _determineCurrentPeriod() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      _currentPeriod = PeriodoDia.manha;
    } else if (hour >= 12 && hour < 18) {
      _currentPeriod = PeriodoDia.tarde;
    } else {
      _currentPeriod = PeriodoDia.noite;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _salvarSentimento() {
    if (_selectedHumor == null) return;

    setState(() {
      if (_currentPeriod == PeriodoDia.manha) _registroManha = _selectedHumor;
      if (_currentPeriod == PeriodoDia.tarde) _registroTarde = _selectedHumor;
      if (_currentPeriod == PeriodoDia.noite) _registroNoite = _selectedHumor;
      _selectedHumor = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seu sentimento foi guardado com carinho!'),
        backgroundColor: VivaBemColors.verdeConfirmacao,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      appBar: AppBar(
        backgroundColor: DiarioPalete.amareloPrincipal,
        title: const Text(
          'Meu Diário de Bem-Estar',

          style: TextStyle(color: VivaBemColors.cinzaEscuro, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: VivaBemColors.cinzaEscuro),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tela de Histórico a ser implementada!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDailyProgressTracker(),
            const SizedBox(height: 40), 
            if (!_isPeriodoAtualRegistrado) _buildRegistroSection(),
            if (_isPeriodoAtualRegistrado) _buildMensagemConcluido(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDailyProgressTracker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seus registros de hoje:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VivaBemColors.branco),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPeriodIcon(PeriodoDia.manha, FontAwesomeIcons.sun, "Manhã"),
            _buildPeriodIcon(PeriodoDia.tarde, FontAwesomeIcons.cloudSun, "Tarde"),
            _buildPeriodIcon(PeriodoDia.noite, FontAwesomeIcons.moon, "Noite"),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodIcon(PeriodoDia periodo, IconData icon, String label) {
    bool isActive = _currentPeriod == periodo;
    bool isCompleted = (_registroManha != null && periodo == PeriodoDia.manha) ||
                       (_registroTarde != null && periodo == PeriodoDia.tarde) ||
                       (_registroNoite != null && periodo == PeriodoDia.noite);
    Color inactiveColor = VivaBemColors.branco.withOpacity(0.4);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20), 
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? VivaBemColors.verdeConfirmacao.withOpacity(0.2)
                : isActive
                    ? DiarioPalete.periodoAtivo.withOpacity(0.2)
                    : Colors.transparent,
            border: Border.all(
              color: isCompleted
                  ? VivaBemColors.verdeConfirmacao
                  : isActive ? DiarioPalete.periodoAtivo : inactiveColor,
              width: 2.5, // AUMENTADO: Borda mais espessa
            ),
          ),
          child: isCompleted
              ? Icon(Icons.check_circle, color: VivaBemColors.verdeConfirmacao, size: 32) // AUMENTADO: Ícone maior
              : Icon(icon, color: isActive ? DiarioPalete.periodoAtivo : inactiveColor, size: 32),
        ),
        const SizedBox(height: 12),
        Text(label, style: TextStyle(fontSize: 14, color: isCompleted ? VivaBemColors.verdeConfirmacao : isActive ? DiarioPalete.periodoAtivo : inactiveColor))
      ],
    );
  }
  
  Widget _buildRegistroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Como você está se sentindo agora?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: VivaBemColors.branco),
        ),
        const SizedBox(height: 25),
        _buildHumorSelection(),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _selectedHumor != null ? _buildAnnotationSection() : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMensagemConcluido() {
    return Container(
      padding: const EdgeInsets.all(30), 
      decoration: BoxDecoration(
        color: VivaBemColors.verdeConfirmacao.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: VivaBemColors.verdeConfirmacao.withOpacity(0.3))
      ),
      child: const Center(
        child: Text(
          "Seu sentimento de hoje já foi registrado!\nVolte mais tarde.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: VivaBemColors.verdeConfirmacao, fontWeight: FontWeight.bold, height: 1.5), 
        ),
      ),
    );
  }
  
  Widget _buildHumorSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHumorButton(Humor.ansioso, FontAwesomeIcons.faceTired, "Ansioso", DiarioPalete.corAnsioso),
        _buildHumorButton(Humor.triste, FontAwesomeIcons.faceFrown, "Triste", DiarioPalete.corTriste),
        _buildHumorButton(Humor.neutro, FontAwesomeIcons.faceMeh, "Neutro", DiarioPalete.corNeutro),
        _buildHumorButton(Humor.calmo, FontAwesomeIcons.faceSmile, "Calmo", DiarioPalete.corCalmo),
        _buildHumorButton(Humor.alegre, FontAwesomeIcons.faceLaughBeam, "Alegre", DiarioPalete.corAlegre),
      ],
    );
  }

  Widget _buildHumorButton(Humor humor, IconData icon, String label, Color color) {
    bool isSelected = _selectedHumor == humor;
    return GestureDetector(
      onTap: () => setState(() => _selectedHumor = humor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), 
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 44, color: color),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 16, color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnnotationSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _getAnnotationPrompt(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: VivaBemColors.branco),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _noteController,
            maxLines: 4,
            style: const TextStyle(color: VivaBemColors.branco, fontSize: 16),
            decoration: InputDecoration(
              hintText: "Escreva aqui, se desejar...",
              hintStyle: TextStyle(color: VivaBemColors.branco.withOpacity(0.5)),
              filled: true,
              fillColor: VivaBemColors.branco.withOpacity(0.05),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: VivaBemColors.branco.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: DiarioPalete.corCalmo, width: 2),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.mic, color: DiarioPalete.corCalmo, size: 28), onPressed: () {/* TODO */}),
                  IconButton(icon: Icon(Icons.photo_camera, color: DiarioPalete.corCalmo, size: 28), onPressed: () {/* TODO */}),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _salvarSentimento,
            style: ElevatedButton.styleFrom(
              backgroundColor: DiarioPalete.amareloPrincipal,
              padding: const EdgeInsets.symmetric(vertical: 18), // AUMENTADO: Botão mais alto
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text(
              'Salvar Sentimento',
              style: TextStyle(fontSize: 20, color: VivaBemColors.cinzaEscuro, fontWeight: FontWeight.bold), 
            ),
          )
        ],
      ),
    );
  }

  String _getAnnotationPrompt() {
    switch (_selectedHumor) {
      case Humor.alegre: return "Que maravilha! O que te fez sorrir hoje?";
      case Humor.calmo: return "Que bom! O que te trouxe paz hoje?";
      case Humor.triste: return "Sinto muito por isso. Quer contar o que aconteceu?";
      case Humor.ansioso: return "Respire fundo. Se quiser, escreva o que está sentindo.";
      default: return "Quer adicionar uma anotação sobre seu sentimento?";
    }
  }
}