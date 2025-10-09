// lib/screens/diario_bem_estar_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

// Enums para deixar o código mais limpo e seguro
enum Humor { ansioso, triste, neutro, calmo, alegre }
enum PeriodoDia { manha, tarde, noite }

class DiarioBemEstarScreen extends StatefulWidget {
  const DiarioBemEstarScreen({Key? key}) : super(key: key);

  @override
  _DiarioBemEstarScreenState createState() => _DiarioBemEstarScreenState();
}

class _DiarioBemEstarScreenState extends State<DiarioBemEstarScreen> {
  // Variáveis de estado da tela
  Humor? _selectedHumor;
  final TextEditingController _noteController = TextEditingController();
  PeriodoDia _currentPeriod = PeriodoDia.manha;
  
  // Simulação de registros salvos
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
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, d \'de\' MMMM', 'pt_BR').format(DateTime.now());
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
        backgroundColor: VivaBemColors.botaoAmareloSol,
        title: const Text(
          'Meu Diário de Bem-Estar',
          style: TextStyle(color: VivaBemColors.botaoAzulProfundo), // MUDANÇA: Texto branco
        ),
        iconTheme: const IconThemeData(color: VivaBemColors.botaoAzulProfundo), // MUDANÇA: Ícone de voltar branco
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailyProgressTracker(),
            const SizedBox(height: 30),
            if (!_isPeriodoAtualRegistrado) _buildRegistroSection(),
            if (_isPeriodoAtualRegistrado) _buildMensagemConcluido(),
            const SizedBox(height: 30),
            if (_registroManha != null || _registroTarde != null || _registroNoite != null)
              _buildInspirationCard(),
            const SizedBox(height: 20),
            _buildToolsCard(),
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
          // MUDANÇA: Texto branco para o tema escuro
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VivaBemColors.branco),
        ),
        const SizedBox(height: 16),
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
    // MUDANÇA: Cor inativa ajustada para o tema escuro
    Color inactiveColor = VivaBemColors.branco.withOpacity(0.4);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? VivaBemColors.verdeConfirmacao.withOpacity(0.2)
                : isActive
                    ? VivaBemColors.laranjaSuave.withOpacity(0.2)
                    : Colors.transparent, // Fundo transparente para inativos
            border: Border.all(
              color: isCompleted
                  ? VivaBemColors.verdeConfirmacao
                  : isActive ? VivaBemColors.laranjaSuave : inactiveColor,
              width: 2,
            ),
          ),
          child: isCompleted
              ? const Icon(Icons.check_circle, color: VivaBemColors.verdeConfirmacao, size: 28)
              : Icon(icon, color: isActive ? VivaBemColors.laranjaPrimario : inactiveColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: isCompleted ? VivaBemColors.verdeConfirmacao : isActive ? VivaBemColors.laranjaPrimario : inactiveColor))
      ],
    );
  }
  
  Widget _buildRegistroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Como você está se sentindo agora?',
          textAlign: TextAlign.center,
          // MUDANÇA: Texto branco
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: VivaBemColors.branco),
        ),
        const SizedBox(height: 20),
        _buildHumorSelection(),
        // Usando AnimatedSize para uma transição suave ao aparecer
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: VivaBemColors.verdeConfirmacao.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: VivaBemColors.verdeConfirmacao.withOpacity(0.3))
      ),
      child: const Center(
        child: Text(
          "Seu sentimento de hoje já foi registrado!\nVolte mais tarde.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: VivaBemColors.verdeConfirmacao, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  
  Widget _buildHumorSelection() {
    // ... (Este widget já funciona bem no tema escuro)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHumorButton(Humor.ansioso, FontAwesomeIcons.faceGrimace, "Ansioso", VivaBemColors.vermelhoSuave),
        _buildHumorButton(Humor.triste, FontAwesomeIcons.faceFrown, "Triste", VivaBemColors.laranjaPrimario),
        _buildHumorButton(Humor.neutro, FontAwesomeIcons.faceMeh, "Neutro", VivaBemColors.branco),
        _buildHumorButton(Humor.calmo, FontAwesomeIcons.faceSmile, "Calmo", VivaBemColors.azulPrimario),
        _buildHumorButton(Humor.alegre, FontAwesomeIcons.faceLaughBeam, "Alegre", VivaBemColors.verdeConfirmacao),
      ],
    );
  }

  Widget _buildHumorButton(Humor humor, IconData icon, String label, Color color) {
    bool isSelected = _selectedHumor == humor;
    return GestureDetector(
      onTap: () => setState(() => _selectedHumor = humor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.4) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
            style: const TextStyle(fontSize: 16, color: VivaBemColors.branco),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 4,
            style: const TextStyle(color: VivaBemColors.branco),
            decoration: InputDecoration(
              hintText: "Escreva aqui, se desejar...",
              hintStyle: TextStyle(color: VivaBemColors.branco.withOpacity(0.5)),
              filled: true,
              fillColor: VivaBemColors.branco.withOpacity(0.05),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: VivaBemColors.branco.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: VivaBemColors.azulClaro, width: 2),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.mic, color: VivaBemColors.azulClaro), onPressed: () {/* TODO: Voice Input */}),
                  IconButton(icon: const Icon(Icons.photo_camera, color: VivaBemColors.azulClaro), onPressed: () {/* TODO: Photo Input */}),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _salvarSentimento,
            style: ElevatedButton.styleFrom(
              backgroundColor: VivaBemColors.laranjaPrimario,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Salvar Sentimento',
              style: TextStyle(fontSize: 18, color: VivaBemColors.cinzaEscuro, fontWeight: FontWeight.bold),
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

  Widget _buildInspirationCard() {
    return Card(
      // MUDANÇA: Cor do card ajustada para o tema escuro
      color: VivaBemColors.laranjaPrimario.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: VivaBemColors.laranjaPrimario.withOpacity(0.5), width: 1),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ListTile(
          leading: Icon(FontAwesomeIcons.lightbulb, color: VivaBemColors.laranjaPrimario),
          title: Text("Frase do Dia", style: TextStyle(fontWeight: FontWeight.bold, color: VivaBemColors.laranjaPrimario)),
          subtitle: Text("A gentileza é a linguagem que o surdo pode ouvir e o cego pode ver.", style: TextStyle(color: VivaBemColors.branco, fontStyle: FontStyle.italic)),
        ),
      ),
    );
  }

  Widget _buildToolsCard() {
    return Card(
      // MUDANÇA: Cor do card ajustada para o tema escuro
      color: VivaBemColors.azulClaro.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: VivaBemColors.azulClaro.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Precisa de uma Pausa?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VivaBemColors.azulClaro)),
            const SizedBox(height: 4),
            const Text("Faça 1 minuto de respiração para acalmar a mente.", style: TextStyle(color: VivaBemColors.branco)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {/* TODO: Breathing exercise screen */},
                child: const Text("Começar Exercício →", style: TextStyle(color: VivaBemColors.azulClaro, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}