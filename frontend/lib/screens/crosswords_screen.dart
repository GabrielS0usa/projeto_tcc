import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/cognitive_activity.dart';

import 'dart:convert';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;

class CrosswordsScreen extends StatefulWidget {
  const CrosswordsScreen({Key? key}) : super(key: key);

  @override
  State<CrosswordsScreen> createState() => _CrosswordsScreenState();
}

class _CrosswordsScreenState extends State<CrosswordsScreen> {
  bool _isLoading = false;
  List<CrosswordActivity> _crosswords = [];

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCrosswords();
  }

  Future<void> _loadCrosswords() async {
    setState(() => _isLoading = true);

    try {
      final http.Response response = await _apiService.getCrosswordActivities();

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        setState(() {
          _crosswords = responseData
              .map((json) => CrosswordActivity.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        print('Erro ao carregar dados: ${response.statusCode}');
        print('Corpo: ${response.body}');
        setState(() => _isLoading = false);
        _showErrorSnackBar('Não foi possível carregar o histórico.');
      }
    } catch (e) {
      print('Exceção ao carregar dados: $e');
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erro de conexão. Tente novamente.');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: VivaBemColors.vermelhoErro,
        ),
      );
    }
  }

  void _showAddDialog() {
    final puzzleNameController = TextEditingController();
    final timeController = TextEditingController();
    final notesController = TextEditingController();
    String selectedDifficulty = 'medium';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: VivaBemColors.cinzaEscuro,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Registrar Palavras Cruzadas',
            style: TextStyle(
              color: VivaBemColors.branco,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: puzzleNameController,
                  label: 'Nome do Quebra-Cabeça',
                  icon: FontAwesomeIcons.puzzlePiece,
                ),
                const SizedBox(height: 20),
                Text(
                  'Dificuldade',
                  style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildDifficultyChip(
                      label: 'Fácil',
                      value: 'easy',
                      selectedValue: selectedDifficulty,
                      onSelected: (value) {
                        setDialogState(() => selectedDifficulty = value);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildDifficultyChip(
                      label: 'Médio',
                      value: 'medium',
                      selectedValue: selectedDifficulty,
                      onSelected: (value) {
                        setDialogState(() => selectedDifficulty = value);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildDifficultyChip(
                      label: 'Difícil',
                      value: 'hard',
                      selectedValue: selectedDifficulty,
                      onSelected: (value) {
                        setDialogState(() => selectedDifficulty = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: timeController,
                  label: 'Tempo Gasto (minutos)',
                  icon: Icons.timer,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: notesController,
                  label: 'Notas (opcional)',
                  icon: Icons.note,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: VivaBemColors.branco, fontSize: 18),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (puzzleNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Por favor, insira o nome do quebra-cabeça'),
                      backgroundColor: VivaBemColors.vermelhoErro,
                    ),
                  );
                  return;
                }

                final Map<String, dynamic> data = {
                  'puzzleName': puzzleNameController.text,
                  'difficulty': selectedDifficulty,
                  'date': DateTime.now().toIso8601String(),
                  'timeSpentMinutes': int.tryParse(timeController.text) ?? 0,
                  'isCompleted': true,
                  'notes': notesController.text.isEmpty
                      ? null
                      : notesController.text,
                };

                try {
                  final http.Response response =
                      await _apiService.createCrosswordActivity(data);

                  if (response.statusCode == 201) {
                    final newCrossword =
                        CrosswordActivity.fromJson(jsonDecode(response.body));

                    setState(() {
                      _crosswords.insert(0, newCrossword);
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Palavras cruzadas registradas! 🎉'),
                        backgroundColor: ActiveMindPalete.verdeProgresso,
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                    _showErrorSnackBar('Erro ao salvar: ${response.body}');
                  }
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorSnackBar('Erro de conexão. Tente novamente.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ActiveMindPalete.azulPalavrasCruzadas,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Registrar',
                style: TextStyle(
                  color: VivaBemColors.branco,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip({
    required String label,
    required String value,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    final isSelected = value == selectedValue;
    Color color;

    switch (value) {
      case 'easy':
        color = const Color(0xFF4CAF50);
        break;
      case 'hard':
        color = const Color(0xFFDC411E);
        break;
      default:
        color = const Color(0xFFF7B300);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : VivaBemColors.branco.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : VivaBemColors.branco.withOpacity(0.7),
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: VivaBemColors.branco, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: VivaBemColors.branco.withOpacity(0.7),
          fontSize: 16,
        ),
        prefixIcon: Icon(icon, color: ActiveMindPalete.azulPalavrasCruzadas),
        filled: true,
        fillColor: VivaBemColors.branco.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ActiveMindPalete.azulPalavrasCruzadas.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ActiveMindPalete.azulPalavrasCruzadas.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ActiveMindPalete.azulPalavrasCruzadas,
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _crosswords.where((c) => c.isCompleted).length;
    final totalTime = _crosswords.fold<int>(
      0,
      (sum, c) => sum + c.timeSpentMinutes,
    );

    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      appBar: AppBar(
        title: const Text(
          'Palavras Cruzadas',
          style: TextStyle(
            color: VivaBemColors.branco,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: ActiveMindPalete.azulPalavrasCruzadas,
        iconTheme: const IconThemeData(color: VivaBemColors.branco),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: ActiveMindPalete.azulPalavrasCruzadas,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCrosswords,
              color: ActiveMindPalete.azulPalavrasCruzadas,
              child: Column(
                children: [
                  _buildStatsHeader(completedCount, totalTime),
                  Expanded(
                    child: _crosswords.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _crosswords.length,
                            itemBuilder: (context, index) {
                              return _buildCrosswordCard(_crosswords[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: ActiveMindPalete.azulPalavrasCruzadas,
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Registrar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatsHeader(int completedCount, int totalTime) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ActiveMindPalete.azulPalavrasCruzadas.withOpacity(0.3),
            ActiveMindPalete.azulPrincipal.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ActiveMindPalete.azulPalavrasCruzadas.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: FontAwesomeIcons.puzzlePiece,
            value: '$completedCount',
            label: 'Completados',
          ),
          Container(
            width: 2,
            height: 40,
            color: VivaBemColors.branco.withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Icons.timer,
            value: '${totalTime}min',
            label: 'Tempo Total',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: ActiveMindPalete.amareloDestaque, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: VivaBemColors.branco,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: VivaBemColors.branco.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.puzzlePiece,
              size: 80,
              color: ActiveMindPalete.azulPalavrasCruzadas.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum quebra-cabeça registrado',
              style: TextStyle(
                color: VivaBemColors.branco,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Comece a desafiar sua mente!\nRegistre suas palavras cruzadas completadas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: VivaBemColors.branco.withOpacity(0.7),
                fontSize: 18,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrosswordCard(CrosswordActivity crossword) {
    final difficultyColor = crossword.getDifficultyColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ActiveMindPalete.azulPalavrasCruzadas.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ActiveMindPalete.azulPalavrasCruzadas.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(
                  FontAwesomeIcons.puzzlePiece,
                  color: difficultyColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crossword.puzzleName,
                      style: const TextStyle(
                        color: VivaBemColors.branco,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: difficultyColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: difficultyColor),
                          ),
                          child: Text(
                            crossword.difficulty == 'easy'
                                ? 'Fácil'
                                : crossword.difficulty == 'medium'
                                    ? 'Médio'
                                    : 'Difícil',
                            style: TextStyle(
                              color: difficultyColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (crossword.isCompleted)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ActiveMindPalete.verdeProgresso.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: ActiveMindPalete.verdeProgresso,
                    size: 28,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.timer,
                color: ActiveMindPalete.amareloDestaque,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${crossword.timeSpentMinutes} minutos',
                style: TextStyle(
                  color: VivaBemColors.branco.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.calendar_today,
                color: ActiveMindPalete.amareloDestaque,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd/MM/yyyy').format(crossword.date),
                style: TextStyle(
                  color: VivaBemColors.branco.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (crossword.notes != null && crossword.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VivaBemColors.branco.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    color: ActiveMindPalete.amareloDestaque,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      crossword.notes!,
                      style: TextStyle(
                        color: VivaBemColors.branco.withOpacity(0.8),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
