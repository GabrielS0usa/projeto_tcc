import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../models/physical_activity.dart';

class WalkingTrackerScreen extends StatefulWidget {
  const WalkingTrackerScreen({Key? key}) : super(key: key);

  @override
  State<WalkingTrackerScreen> createState() => _WalkingTrackerScreenState();
}

class _WalkingTrackerScreenState extends State<WalkingTrackerScreen> {
  bool _isTracking = false;
  bool _isPaused = false;
  Timer? _timer;
  int _seconds = 0;
  int _steps = 0;
  double _distanceKm = 0.0;
  int _calories = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTracking() {
    setState(() {
      _isTracking = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        // Simulate step counting (in real app, use pedometer sensor)
        if (_seconds % 2 == 0) {
          _steps += 2;
          _distanceKm = _steps * 0.0008; // Approximate: 1 step ≈ 0.8m
          _calories = (_steps * 0.04).round(); // Approximate: 1 step ≈ 0.04 cal
        }
      });
    });
  }

  void _pauseTracking() {
    setState(() {
      _isPaused = true;
    });
    _timer?.cancel();
  }

  void _resumeTracking() {
    setState(() {
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        if (_seconds % 2 == 0) {
          _steps += 2;
          _distanceKm = _steps * 0.0008;
          _calories = (_steps * 0.04).round();
        }
      });
    });
  }

  void _stopTracking() {
    _timer?.cancel();

    if (_seconds < 60) {
      // Too short, just cancel
      Navigator.pop(context);
      return;
    }

    // Show summary dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: VivaBemColors.cinzaEscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: PhysicalExercisesPalete.amareloTempo,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Parabéns!',
              style: TextStyle(
                color: VivaBemColors.branco,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Você completou sua caminhada!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: VivaBemColors.branco,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            _buildSummaryItem(
              icon: Icons.timer,
              label: 'Tempo',
              value: _formatDuration(_seconds),
              color: PhysicalExercisesPalete.amareloTempo,
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              icon: Icons.directions_walk,
              label: 'Passos',
              value: '$_steps',
              color: PhysicalExercisesPalete.laranjaCaminhada,
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              icon: Icons.straighten,
              label: 'Distância',
              value: '${_distanceKm.toStringAsFixed(2)} km',
              color: PhysicalExercisesPalete.azulDistancia,
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              icon: Icons.local_fire_department,
              label: 'Calorias',
              value: '$_calories kcal',
              color: PhysicalExercisesPalete.rosaPrincipal,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Caminhada salva com sucesso! 🎉'),
                  backgroundColor: PhysicalExercisesPalete.verdeObjetivo,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PhysicalExercisesPalete.verdeObjetivo,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Concluir',
              style: TextStyle(
                color: VivaBemColors.branco,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
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
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}min ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isTracking && !_isPaused) {
          // Show confirmation dialog
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: VivaBemColors.cinzaEscuro,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Cancelar Caminhada?',
                style: TextStyle(
                  color: VivaBemColors.branco,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Você tem certeza que deseja cancelar? Seu progresso será perdido.',
                style: TextStyle(
                  color: VivaBemColors.branco,
                  fontSize: 18,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      color: VivaBemColors.branco,
                      fontSize: 18,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VivaBemColors.vermelhoErro,
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: VivaBemColors.branco,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: VivaBemColors.cinzaEscuro,
        appBar: AppBar(
          title: const Text(
            'Rastreador de Caminhada',
            style: TextStyle(
              color: VivaBemColors.branco,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          backgroundColor: PhysicalExercisesPalete.laranjaCaminhada,
          iconTheme: const IconThemeData(color: VivaBemColors.branco),
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildMapPlaceholder(),
                      const SizedBox(height: 30),
                      _buildTimerDisplay(),
                      const SizedBox(height: 30),
                      _buildStatsGrid(),
                    ],
                  ),
                ),
              ),
              _buildControlButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: VivaBemColors.branco.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PhysicalExercisesPalete.laranjaCaminhada.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 80,
                  color: PhysicalExercisesPalete.laranjaCaminhada.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Mapa em Tempo Real',
                  style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '(Funcionalidade GPS em breve)',
                  style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_isTracking)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: PhysicalExercisesPalete.verdeObjetivo,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: VivaBemColors.branco,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Rastreando',
                      style: TextStyle(
                        color: VivaBemColors.branco,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PhysicalExercisesPalete.laranjaCaminhada.withOpacity(0.3),
            PhysicalExercisesPalete.amareloTempo.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PhysicalExercisesPalete.laranjaCaminhada.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timer,
            color: PhysicalExercisesPalete.amareloTempo,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _formatDuration(_seconds),
            style: const TextStyle(
              color: VivaBemColors.branco,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isPaused ? 'Pausado' : _isTracking ? 'Em Andamento' : 'Pronto para Começar',
            style: TextStyle(
              color: VivaBemColors.branco.withOpacity(0.8),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.directions_walk,
                label: 'Passos',
                value: '$_steps',
                color: PhysicalExercisesPalete.laranjaCaminhada,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.straighten,
                label: 'Distância',
                value: '${_distanceKm.toStringAsFixed(2)} km',
                color: PhysicalExercisesPalete.azulDistancia,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                label: 'Calorias',
                value: '$_calories',
                color: PhysicalExercisesPalete.rosaPrincipal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.speed,
                label: 'Ritmo',
                value: _seconds > 0 ? '${(_distanceKm / (_seconds / 3600)).toStringAsFixed(1)} km/h' : '0.0 km/h',
                color: PhysicalExercisesPalete.roxoEnergia,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
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
      ),
    );
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: VivaBemColors.cinzaEscuro,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_isTracking) ...[
            // Pause/Resume button
            _buildControlButton(
              icon: _isPaused ? Icons.play_arrow : Icons.pause,
              label: _isPaused ? 'Retomar' : 'Pausar',
              color: PhysicalExercisesPalete.amareloTempo,
              onPressed: _isPaused ? _resumeTracking : _pauseTracking,
            ),
            // Stop button
            _buildControlButton(
              icon: Icons.stop,
              label: 'Parar',
              color: VivaBemColors.vermelhoErro,
              onPressed: _stopTracking,
            ),
          ] else ...[
            // Start button
            Expanded(
              child: ElevatedButton(
                onPressed: _startTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PhysicalExercisesPalete.verdeObjetivo,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.play_arrow, size: 32),
                    SizedBox(width: 12),
                    Text(
                      'Iniciar Caminhada',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
