import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projeto/screens/reading_log_screen.dart';
import 'package:projeto/screens/crosswords_screen.dart';
import 'package:projeto/screens/movies_screen.dart';
import '../theme/app_colors.dart';
import '../models/cognitive_activity.dart';
import '../services/api_service.dart';

class ActiveMindScreen extends StatefulWidget {
  const ActiveMindScreen({Key? key}) : super(key: key);

  @override
  State<ActiveMindScreen> createState() => _ActiveMindScreenState();
}

class _ActiveMindScreenState extends State<ActiveMindScreen> {
  bool _isLoading = false;
  CognitiveActivityStats _stats = CognitiveActivityStats.empty();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = ApiService();
      final response = await apiService.getCognitiveStats();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _stats = CognitiveActivityStats.fromJson(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar estatísticas');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar estatísticas: $e'),
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
        title: const Text(
          'Mente Ativa',
          style: TextStyle(
            color: VivaBemColors.branco,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: ActiveMindPalete.azulPrincipal,
        iconTheme: const IconThemeData(color: VivaBemColors.branco),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: ActiveMindPalete.azulPrincipal,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: ActiveMindPalete.azulPrincipal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 30),
                    _buildStatsCard(),
                    const SizedBox(height: 35),
                    _buildActivitiesGrid(),
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
          'Exercite sua mente!',
          style: TextStyle(
            color: VivaBemColors.branco,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Mantenha seu cérebro ativo com atividades estimulantes',
          style: TextStyle(
            color: VivaBemColors.branco.withOpacity(0.8),
            fontSize: 18,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ActiveMindPalete.azulPrincipal.withOpacity(0.3),
            ActiveMindPalete.roxoLeitura.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ActiveMindPalete.azulPrincipal.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: ActiveMindPalete.amareloDestaque,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                'Suas Conquistas',
                style: TextStyle(
                  color: VivaBemColors.branco,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: FontAwesomeIcons.book,
                value: '${_stats.booksRead}',
                label: 'Livros',
                color: ActiveMindPalete.roxoLeitura,
              ),
              _buildStatItem(
                icon: FontAwesomeIcons.puzzlePiece,
                value: '${_stats.crosswordsCompleted}',
                label: 'Palavras\nCruzadas',
                color: ActiveMindPalete.azulPalavrasCruzadas,
              ),
              _buildStatItem(
                icon: FontAwesomeIcons.film,
                value: '${_stats.moviesWatched}',
                label: 'Filmes',
                color: ActiveMindPalete.rosaFilmes,
              ),
            ],
          ),
          if (_stats.weeklyStreak > 0) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: ActiveMindPalete.verdeProgresso.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: ActiveMindPalete.verdeProgresso,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: ActiveMindPalete.amareloDestaque,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_stats.weeklyStreak} dias de sequência!',
                    style: const TextStyle(
                      color: VivaBemColors.branco,
                      fontSize: 18,
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

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: FaIcon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VivaBemColors.branco.withOpacity(0.8),
            fontSize: 14,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escolha uma Atividade',
          style: TextStyle(
            color: VivaBemColors.branco,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildActivityCard(
          title: 'Leitura',
          subtitle: 'Registre seus livros e progresso',
          icon: FontAwesomeIcons.bookOpen,
          color: ActiveMindPalete.roxoLeitura,
          onTap: () => _navigateToActivity(const ReadingLogScreen()),
        ),
        const SizedBox(height: 20),
        _buildActivityCard(
          title: 'Palavras Cruzadas',
          subtitle: 'Acompanhe seus quebra-cabeças',
          icon: FontAwesomeIcons.puzzlePiece,
          color: ActiveMindPalete.azulPalavrasCruzadas,
          onTap: () => _navigateToActivity(const CrosswordsScreen()),
        ),
        const SizedBox(height: 20),
        _buildActivityCard(
          title: 'Filmes',
          subtitle: 'Seu diário de cinema',
          icon: FontAwesomeIcons.film,
          color: ActiveMindPalete.rosaFilmes,
          onTap: () => _navigateToActivity(const MoviesScreen()),
        ),
      ],
    );
  }

  Widget _buildActivityCard({
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
        padding: const EdgeInsets.all(24),
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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: FaIcon(
                icon,
                color: color,
                size: 36,
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
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

  Widget _buildMotivationalMessage() {
    final messages = [
      '🧠 Cada atividade fortalece sua mente!',
      '⭐ Continue assim, você está indo muito bem!',
      '📚 O conhecimento é um tesouro que ninguém pode roubar!',
      '🎯 Pequenos passos levam a grandes conquistas!',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ActiveMindPalete.verdeProgresso.withOpacity(0.2),
            ActiveMindPalete.amareloDestaque.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ActiveMindPalete.verdeProgresso.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Text(
        messages[_stats.totalActivities % messages.length],
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

  void _navigateToActivity(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) => _loadStats());
  }
}
