import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projeto/screens/walking_tracker_screen.dart';
import 'package:projeto/screens/exercise_history_screen.dart';
import '../theme/app_colors.dart';
import '../models/physical_activity.dart';
import '../services/api_service.dart';

class PhysicalExercisesScreen extends StatefulWidget {
  const PhysicalExercisesScreen({Key? key}) : super(key: key);

  @override
  State<PhysicalExercisesScreen> createState() => _PhysicalExercisesScreenState();
}

class _PhysicalExercisesScreenState extends State<PhysicalExercisesScreen> {
  bool _isLoading = false;
  DailyExerciseGoal _dailyGoal = DailyExerciseGoal.defaultGoal();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadDailyGoal();
  }

  Future<void> _loadDailyGoal() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _apiService.getTodayExerciseGoal();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _dailyGoal = DailyExerciseGoal.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _dailyGoal = DailyExerciseGoal.defaultGoal();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar meta diária: $e'),
            backgroundColor: VivaBemColors.vermelhoErro,
          ),
        );
      }
    }
  }

  Future<void> _savePhysicalActivity(
    TextEditingController activityNameController,
    TextEditingController durationController,
    TextEditingController caloriesController,
    PhysicalActivityType selectedType,
    int selectedIntensity,
  ) async {
    if (activityNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o nome da atividade'),
          backgroundColor: VivaBemColors.vermelhoErro,
        ),
      );
      return;
    }

    final duration = int.tryParse(durationController.text) ?? 0;
    final calories = int.tryParse(caloriesController.text) ?? 0;

    if (duration <= 0 || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira valores válidos para duração e calorias'),
          backgroundColor: VivaBemColors.vermelhoErro,
        ),
      );
      return;
    }

    try {
      final activityData = {
        'activityType': selectedType.toString().split('.').last,
        'activityName': activityNameController.text,
        'date': DateTime.now().toIso8601String(),
        'durationMinutes': duration,
        'caloriesBurned': calories,
        'notes': null,
        'intensityLevel': selectedIntensity,
      };

      final response = await _apiService.createPhysicalActivity(activityData);

      if (response.statusCode == 201) {
        Navigator.pop(context);
        await _loadDailyGoal(); // Reload to get updated stats
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Atividade registrada! Continue assim! 💪'),
              backgroundColor: PhysicalExercisesPalete.verdeObjetivo,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao registrar atividade: ${response.statusCode}'),
              backgroundColor: VivaBemColors.vermelhoErro,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar atividade: $e'),
            backgroundColor: VivaBemColors.vermelhoErro,
          ),
        );
      }
    }
  }

  void _showManualActivityDialog() {
    final activityNameController = TextEditingController();
    final durationController = TextEditingController();
    final caloriesController = TextEditingController();
    PhysicalActivityType selectedType = PhysicalActivityType.walking;
    int selectedIntensity = 3;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: VivaBemColors.cinzaEscuro,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Registrar Atividade',
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
                Text(
                  'Tipo de Atividade',
                  style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PhysicalActivityType.values.map((type) {
                    final isSelected = selectedType == type;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? PhysicalExercisesPalete.rosaPrincipal.withOpacity(0.3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? PhysicalExercisesPalete.rosaPrincipal
                                : VivaBemColors.branco.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getActivityIcon(type),
                              color: isSelected
                                  ? PhysicalExercisesPalete.rosaPrincipal
                                  : VivaBemColors.branco.withOpacity(0.7),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getActivityName(type),
                              style: TextStyle(
                                color: isSelected
                                    ? PhysicalExercisesPalete.rosaPrincipal
                                    : VivaBemColors.branco.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: activityNameController,
                  label: 'Nome da Atividade',
                  icon: Icons.fitness_center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: durationController,
                        label: 'Duração (min)',
                        icon: Icons.timer,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: caloriesController,
                        label: 'Calorias',
                        icon: Icons.local_fire_department,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Intensidade',
                  style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final level = index + 1;
                    final isSelected = selectedIntensity == level;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedIntensity = level),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getIntensityColor(level).withOpacity(0.3)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? _getIntensityColor(level)
                                : VivaBemColors.branco.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$level',
                            style: TextStyle(
                              color: isSelected
                                  ? _getIntensityColor(level)
                                  : VivaBemColors.branco.withOpacity(0.7),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
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
              onPressed: () => _savePhysicalActivity(
                activityNameController,
                durationController,
                caloriesController,
                selectedType,
                selectedIntensity,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: PhysicalExercisesPalete.rosaPrincipal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  IconData _getActivityIcon(PhysicalActivityType type) {
    switch (type) {
      case PhysicalActivityType.walking:
        return Icons.directions_walk;
      case PhysicalActivityType.running:
        return Icons.directions_run;
      case PhysicalActivityType.cycling:
        return Icons.directions_bike;
      case PhysicalActivityType.swimming:
        return Icons.pool;
      case PhysicalActivityType.yoga:
        return Icons.self_improvement;
      case PhysicalActivityType.other:
        return Icons.fitness_center;
    }
  }

  String _getActivityName(PhysicalActivityType type) {
    switch (type) {
      case PhysicalActivityType.walking:
        return 'Caminhada';
      case PhysicalActivityType.running:
        return 'Corrida';
      case PhysicalActivityType.cycling:
        return 'Ciclismo';
      case PhysicalActivityType.swimming:
        return 'Natação';
      case PhysicalActivityType.yoga:
        return 'Yoga';
      case PhysicalActivityType.other:
        return 'Outro';
    }
  }

  Color _getIntensityColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFF4CAF50);
      case 2:
        return const Color(0xFF8BC34A);
      case 3:
        return const Color(0xFFF7B300);
      case 4:
        return const Color(0xFFFF9800);
      case 5:
        return const Color(0xFFDC411E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: VivaBemColors.branco, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: VivaBemColors.branco.withOpacity(0.7),
          fontSize: 16,
        ),
        prefixIcon: Icon(icon, color: PhysicalExercisesPalete.rosaPrincipal),
        filled: true,
        fillColor: VivaBemColors.branco.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: PhysicalExercisesPalete.rosaPrincipal.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: PhysicalExercisesPalete.rosaPrincipal.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: PhysicalExercisesPalete.rosaPrincipal,
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      appBar: AppBar(
        title: const Text(
          'Exercícios Físicos',
          style: TextStyle(
            color: VivaBemColors.branco,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: PhysicalExercisesPalete.rosaPrincipal,
        iconTheme: const IconThemeData(color: VivaBemColors.branco),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExerciseHistoryScreen(),
                ),
              ).then((_) => _loadDailyGoal());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: PhysicalExercisesPalete.rosaPrincipal,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDailyGoal,
              color: PhysicalExercisesPalete.rosaPrincipal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 30),
                    _buildGoalRing(),
                    const SizedBox(height: 35),
                    _buildQuickActions(),
                    const SizedBox(height: 30),
                    _buildTodayStats(),
                    const SizedBox(height: 30),
                    _buildMotivationalMessage(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mexa-se!',
          style: TextStyle(
            color: VivaBemColors.branco,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Cada movimento conta para sua saúde',
          style: TextStyle(
            color: VivaBemColors.branco.withOpacity(0.8),
            fontSize: 18,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalRing() {
    final progress = _dailyGoal.overallProgress / 100;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PhysicalExercisesPalete.rosaPrincipal.withOpacity(0.3),
            PhysicalExercisesPalete.roxoEnergia.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PhysicalExercisesPalete.rosaPrincipal.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Meta Diária',
            style: TextStyle(
              color: VivaBemColors.branco,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: GoalRingPainter(
                progress: progress,
                backgroundColor: VivaBemColors.branco.withOpacity(0.2),
                progressColor: _dailyGoal.isGoalMet
                    ? PhysicalExercisesPalete.verdeObjetivo
                    : PhysicalExercisesPalete.rosaPrincipal,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_dailyGoal.overallProgress.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: VivaBemColors.branco,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _dailyGoal.isGoalMet ? 'Meta Atingida!' : 'Concluído',
                      style: TextStyle(
                        color: VivaBemColors.branco.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_dailyGoal.isGoalMet) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: PhysicalExercisesPalete.verdeObjetivo.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: PhysicalExercisesPalete.verdeObjetivo,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: PhysicalExercisesPalete.amareloTempo,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Parabéns! Você atingiu sua meta!',
                    style: TextStyle(
                      color: VivaBemColors.branco,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
          style: TextStyle(
            color: VivaBemColors.branco,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          title: 'Iniciar Caminhada',
          subtitle: 'Rastreie sua caminhada em tempo real',
          icon: Icons.directions_walk,
          color: PhysicalExercisesPalete.laranjaCaminhada,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WalkingTrackerScreen(),
              ),
            ).then((_) => _loadDailyGoal());
          },
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          title: 'Registrar Atividade',
          subtitle: 'Adicione manualmente uma atividade',
          icon: Icons.add_circle,
          color: PhysicalExercisesPalete.roxoEnergia,
          onTap: _showManualActivityDialog,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: VivaBemColors.branco,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: VivaBemColors.branco.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VivaBemColors.branco.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: VivaBemColors.branco.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoje',
            style: TextStyle(
              color: VivaBemColors.branco,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatRow(
            icon: Icons.directions_walk,
            label: 'Passos',
            current: '${_dailyGoal.currentSteps}',
            target: '${_dailyGoal.targetSteps}',
            color: PhysicalExercisesPalete.laranjaCaminhada,
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            icon: Icons.timer,
            label: 'Minutos',
            current: '${_dailyGoal.currentMinutes}',
            target: '${_dailyGoal.targetMinutes}',
            color: PhysicalExercisesPalete.amareloTempo,
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            icon: Icons.local_fire_department,
            label: 'Calorias',
            current: '${_dailyGoal.currentCalories}',
            target: '${_dailyGoal.targetCalories}',
            color: PhysicalExercisesPalete.rosaPrincipal,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String current,
    required String target,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: VivaBemColors.branco.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$current / $target',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalMessage() {
    final messages = [
      '💪 Você está indo muito bem!',
      '🎯 Continue assim, cada passo conta!',
      '⭐ Seu corpo agradece o movimento!',
      '🔥 Mantenha o ritmo, você consegue!',
    ];

    final messageIndex = _dailyGoal.currentSteps % messages.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PhysicalExercisesPalete.verdeObjetivo.withOpacity(0.2),
            PhysicalExercisesPalete.amareloTempo.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PhysicalExercisesPalete.verdeObjetivo.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Text(
        messages[messageIndex],
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: VivaBemColors.branco,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }
}

// Custom painter for the goal ring
class GoalRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  GoalRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = 20.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(GoalRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
