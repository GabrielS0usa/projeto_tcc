import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'dart:convert';

class MealRecord {
  final int id;
  final DateTime timestamp;
  final List<String> items;

  MealRecord({
    required this.id,
    required this.timestamp,
    required this.items,
  });
}

class NutricaoDiarioScreen extends StatefulWidget {
  const NutricaoDiarioScreen({Key? key}) : super(key: key);

  @override
  _NutricaoDiarioScreenState createState() => _NutricaoDiarioScreenState();
}

class _NutricaoDiarioScreenState extends State<NutricaoDiarioScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;

  int _waterCount = 0;
  final int _waterGoal = 8;

  MealRecord? _cafeDaManhaRecord;
  MealRecord? _almocoRecord;
  MealRecord? _jantarRecord;
  MealRecord? _lanchesRecord;

  final Map<String, List<String>> _mealOptions = {
    'Café da Manhã': ['Pão', 'Frutas', 'Ovos', 'Café', 'Leite', 'Iogurte'],
    'Almoço': ['Arroz', 'Feijão', 'Salada', 'Carne', 'Frango', 'Peixe', 'Legumes'],
    'Jantar': ['Sopa', 'Salada', 'Frango Grelhado', 'Omelete', 'Legumes Cozidos'],
    'Lanches': ['Fruta', 'Castanhas', 'Biscoito Integral', 'Vitamina'],
  };

  Map<String, int> get _totalProgress {
    int tasksCompleted = _waterCount > _waterGoal ? _waterGoal : _waterCount;
    if (_cafeDaManhaRecord != null) tasksCompleted++;
    if (_almocoRecord != null) tasksCompleted++;
    if (_jantarRecord != null) tasksCompleted++;
    if (_lanchesRecord != null) tasksCompleted++;

    final int totalTasks = _waterGoal + 4;
    return {'completed': tasksCompleted, 'total': totalTasks};
  }

  @override
  void initState() {
    super.initState();
    _fetchDiaryEntries();
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _fetchDiaryEntries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final date = _getFormattedDate(DateTime.now());
      final response = await _apiService.getDiaryEntries(date);

      if (response.statusCode == 200) {
        List<dynamic> entries = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          _cafeDaManhaRecord = null;
          _almocoRecord = null;
          _jantarRecord = null;
          _lanchesRecord = null;

          for (var entryJson in entries) {
            List<String> items = (entryJson['foodName'] as String? ?? '')
                .split(', ')
                .where((s) => s.isNotEmpty)
                .toList();

            DateTime timestamp = entryJson['updatedAt'] != null
                ? DateTime.parse(entryJson['updatedAt'])
                : DateTime.parse(entryJson['date']);

            final record = MealRecord(
              id: entryJson['id'],
              timestamp: timestamp,
              items: items,
            );

            String mealType = entryJson['mealType'] ?? '';
            switch (mealType) {
              case 'Café da Manhã':
                _cafeDaManhaRecord = record;
                break;
              case 'Almoço':
                _almocoRecord = record;
                break;
              case 'Jantar':
                _jantarRecord = record;
                break;
              case 'Lanches':
                _lanchesRecord = record;
                break;
            }
          }
        });
      } else {
        setState(() {
          _error = 'Erro ao buscar dados: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro de conexão: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logWater(int index) {
    setState(() {
      if (index + 1 > _waterCount) {
        _waterCount = index + 1;
      } else if (index + 1 == _waterCount) {
        _waterCount--;
      } else {
        _waterCount = index;
      }
    });

    if (_waterCount == _waterGoal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parabéns! Meta de hidratação atingida! 🎉'),
          backgroundColor: VivaBemColors.verdeConfirmacao,
        ),
      );
    }
  }

  Future<void> _showMealOptionsModal(String title, Function(MealRecord) onSave) async {
    List<String> availableOptions = _mealOptions[title] ?? [];
    List<String> selectedItems = [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VivaBemColors.cinzaEscuro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ...availableOptions.map((item) {
                    final bool isSelected = selectedItems.contains(item);
                    return ChoiceChip(
                      label: Text(item),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() {
                          if (selected) {
                            selectedItems.add(item);
                          } else {
                            selectedItems.remove(item);
                          }
                        });
                      },
                      selectedColor: NutritionPalete.amareloDourado,
                      backgroundColor: VivaBemColors.cinzaEscuro.withRed(60),
                    );
                  }).toList(),
                  ActionChip(
                    label: const Text("Outro..."),
                    avatar: const Icon(Icons.add),
                    onPressed: () async {
                      final customItem = await _showCustomFoodDialog();
                      if (customItem != null && customItem.isNotEmpty) {
                        setModalState(() {
                          selectedItems.add(customItem);
                        });
                      }
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedItems.isEmpty ? null : () async {
                        try {
                          final Map<String, dynamic> payload = {
                            'date': _getFormattedDate(DateTime.now()),
                            'foodName': selectedItems.join(', '),
                            'mealType': title,
                            'calories': 0.0,
                            'protein': 0.0,
                            'carbs': 0.0,
                            'fat': 0.0,
                          };

                          final response = await _apiService.createDiaryEntry(payload);

                          // ✅ CORRIGIDO: Aceita 200 e 201
                          if (response.statusCode == 200 || response.statusCode == 201) {
                            final newEntryJson = jsonDecode(utf8.decode(response.bodyBytes));

                            onSave(MealRecord(
                              id: newEntryJson['id'],
                              timestamp: DateTime.now(),
                              items: selectedItems,
                            ));
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Refeição registrada com sucesso! ✅'),
                                backgroundColor: VivaBemColors.verdeConfirmacao,
                              ),
                            );
                          } else {
                            // ✅ CORRIGIDO: Tenta decodificar erro JSON
                            String errorMessage = 'Erro: ${response.statusCode}';
                            try {
                              final errorJson = jsonDecode(utf8.decode(response.bodyBytes));
                              errorMessage = errorJson['message'] ?? errorMessage;
                            } catch (_) {}

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: VivaBemColors.vermelhoErro,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro de conexão: $e'),
                              backgroundColor: VivaBemColors.vermelhoErro,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NutritionPalete.laranjaPrincipal,
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: const Text(
                        "Salvar Refeição",
                        style: TextStyle(
                          color: VivaBemColors.cinzaClaro,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _showCustomFoodDialog() async {
    final TextEditingController customFoodController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: VivaBemColors.cinzaEscuro,
          title: const Text('Adicionar Item', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: customFoodController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "Digite o alimento"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, customFoodController.text),
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  // ✅ NOVO: Função para deletar refeição
  Future<void> _deleteMeal(MealRecord record, String mealType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VivaBemColors.cinzaEscuro,
        title: const Text('Confirmar exclusão', style: TextStyle(color: Colors.white)),
        content: Text(
          'Deseja excluir o registro de $mealType?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: VivaBemColors.vermelhoErro),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _apiService.deleteDiaryEntry(record.id);

        if (response.statusCode == 204 || response.statusCode == 200) {
          setState(() {
            switch (mealType) {
              case 'Café da Manhã':
                _cafeDaManhaRecord = null;
                break;
              case 'Almoço':
                _almocoRecord = null;
                break;
              case 'Jantar':
                _jantarRecord = null;
                break;
              case 'Lanches':
                _lanchesRecord = null;
                break;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refeição excluída com sucesso!'),
              backgroundColor: VivaBemColors.verdeConfirmacao,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: ${response.statusCode}'),
              backgroundColor: VivaBemColors.vermelhoErro,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro de conexão: $e'),
            backgroundColor: VivaBemColors.vermelhoErro,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      appBar: AppBar(
        title: const Text('Meu Diário Nutricional'),
        backgroundColor: NutritionPalete.laranjaPrincipal,
        foregroundColor: VivaBemColors.branco,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Erro ao carregar diário',
                          style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchDiaryEntries,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(),
                        const SizedBox(height: 24),
                        _buildHydrationCard(),
                        const SizedBox(height: 24),
                        _buildMealsCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeaderCard() {
    final progress = _totalProgress;
    final double progressValue = progress['completed']! / progress['total']!;

    return Card(
      color: VivaBemColors.cinzaEscuro.withRed(55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progresso Nutricional do Dia',
              style: TextStyle(
                color: VivaBemColors.branco,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: NutritionPalete.azulHidratacao.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        width: constraints.maxWidth * progressValue,
                        decoration: BoxDecoration(
                          color: NutritionPalete.amareloDourado,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Text(
                      '${progress['completed']} / ${progress['total']}',
                      style: const TextStyle(
                        color: VivaBemColors.branco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHydrationCard() {
    return Card(
      color: VivaBemColors.cinzaEscuro.withRed(55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sua Hidratação Hoje',
              style: TextStyle(
                color: NutritionPalete.azulHidratacao,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_waterCount de $_waterGoal copos',
              style: const TextStyle(color: VivaBemColors.branco, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: List.generate(_waterGoal, (index) {
                bool isFilled = index < _waterCount;
                return GestureDetector(
                  onTap: () => _logWater(index),
                  child: Icon(
                    isFilled ? FontAwesomeIcons.glassWater : FontAwesomeIcons.circle,
                    color: isFilled
                        ? NutritionPalete.azulHidratacao
                        : VivaBemColors.branco.withOpacity(0.3),
                    size: 32,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsCard() {
    return Card(
      color: VivaBemColors.cinzaEscuro.withRed(55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Suas Refeições do Dia',
              style: TextStyle(
                color: NutritionPalete.verdeFolha,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildMealTrackerRow(
              icon: FontAwesomeIcons.mugSaucer,
              title: 'Café da Manhã',
              record: _cafeDaManhaRecord,
              onRegister: () => _showMealOptionsModal(
                'Café da Manhã',
                (record) => setState(() => _cafeDaManhaRecord = record),
              ),
            ),
            const Divider(color: Colors.white24),
            _buildMealTrackerRow(
              icon: FontAwesomeIcons.utensils,
              title: 'Almoço',
              record: _almocoRecord,
              onRegister: () => _showMealOptionsModal(
                'Almoço',
                (record) => setState(() => _almocoRecord = record),
              ),
            ),
            const Divider(color: Colors.white24),
            _buildMealTrackerRow(
              icon: FontAwesomeIcons.plateWheat,
              title: 'Jantar',
              record: _jantarRecord,
              onRegister: () => _showMealOptionsModal(
                'Jantar',
                (record) => setState(() => _jantarRecord = record),
              ),
            ),
            const Divider(color: Colors.white24),
            _buildMealTrackerRow(
              icon: FontAwesomeIcons.appleWhole,
              title: 'Lanches',
              record: _lanchesRecord,
              onRegister: () => _showMealOptionsModal(
                'Lanches',
                (record) => setState(() => _lanchesRecord = record),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTrackerRow({
    required IconData icon,
    required String title,
    required MealRecord? record,
    required VoidCallback onRegister,
  }) {
    if (record == null) {
      return ListTile(
        onTap: onRegister,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: VivaBemColors.branco.withOpacity(0.7), size: 30),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        subtitle: Text(
          "Toque para registrar",
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
        trailing: Icon(Icons.add_circle, color: NutritionPalete.amareloDourado, size: 36),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: VivaBemColors.verdeConfirmacao, size: 30),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Registrado às ${DateFormat('HH:mm').format(record.timestamp)}',
              style: const TextStyle(color: VivaBemColors.verdeConfirmacao),
            ),
            trailing: const Icon(Icons.check_circle, color: VivaBemColors.verdeConfirmacao, size: 36),
            onLongPress: () => _deleteMeal(record, title),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: record.items
                  .map((item) => Chip(
                        label: Text(item),
                        backgroundColor: NutritionPalete.amareloDourado.withOpacity(0.3),
                      ))
                  .toList(),
            ),
          ),
        ],
      );
    }
  }
}