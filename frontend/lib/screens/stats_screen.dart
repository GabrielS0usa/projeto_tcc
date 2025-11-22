// lib/screens/stats_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../models/statistics.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  UserStatistics? _userStatistics;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getUserStats();
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userStatistics = UserStatistics.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Falha ao carregar estatísticas';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro de conexão: $e';
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: VivaBemColors.vermelhoErro,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estatísticas',
                style: TextStyle(
                  color: VivaBemColors.branco,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Acompanhe seu progresso',
                style: TextStyle(
                  color: VivaBemColors.branco.withOpacity(0.8),
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: VivaBemColors.amareloDourado,
                        ),
                      )
                    : _error != null
                        ? _buildErrorView()
                        : _userStatistics != null
                            ? _buildStatisticsView()
                            : _buildEmptyView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: VivaBemColors.vermelhoErro.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.exclamationTriangle,
              size: 80,
              color: VivaBemColors.vermelhoErro,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Erro ao carregar estatísticas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: VivaBemColors.branco,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _error ?? 'Ocorreu um erro inesperado.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: VivaBemColors.branco.withOpacity(0.7),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _fetchStatistics,
            style: ElevatedButton.styleFrom(
              backgroundColor: VivaBemColors.amareloDourado,
              foregroundColor: VivaBemColors.azulMarinho,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Tentar Novamente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: VivaBemColors.azulMarinho.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.chartLine,
              size: 80,
              color: VivaBemColors.amareloDourado,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Nenhuma estatística disponível',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: VivaBemColors.branco,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Comece a registrar suas atividades para ver suas estatísticas aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: VivaBemColors.branco.withOpacity(0.7),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            title: 'Total de Atividades',
            value: _userStatistics!.summary.totalActivities.toString(),
            icon: FontAwesomeIcons.listCheck,
            color: VivaBemColors.amareloDourado,
          ),
          const SizedBox(height: 20),
          _buildStatCard(
            title: 'Valor Total',
            value: _userStatistics!.summary.totalValue.toStringAsFixed(1),
            icon: FontAwesomeIcons.chartLine,
            color: VivaBemColors.verdeEsmeralda,
          ),
          const SizedBox(height: 20),
          _buildCategoryBreakdown(),
          const SizedBox(height: 20),
          _buildWeeklyTrends(),
          const SizedBox(height: 20),
          _buildCompletionRates(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VivaBemColors.azulMarinho.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: VivaBemColors.branco,
                    fontSize: 24,
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

  Widget _buildCategoryBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VivaBemColors.azulMarinho.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atividades por Categoria',
            style: TextStyle(
              color: VivaBemColors.branco,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._userStatistics!.summary.averagesByType.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      color: VivaBemColors.branco.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    entry.value.toStringAsFixed(1),
                    style: TextStyle(
                      color: VivaBemColors.amareloDourado,
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

  Widget _buildWeeklyTrends() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VivaBemColors.azulMarinho.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendências Semanais',
            style: TextStyle(
              color: VivaBemColors.branco,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _userStatistics!.trends.trends.length,
              itemBuilder: (context, index) {
                final trend = _userStatistics!.trends.trends[index];
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: VivaBemColors.amareloDourado.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              trend.count.toString(),
                              style: TextStyle(
                                color: VivaBemColors.branco,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        trend.date.toString().split(' ')[0], // Show date
                        style: TextStyle(
                          color: VivaBemColors.branco.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionRates() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VivaBemColors.azulMarinho.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Taxas de Conclusão',
            style: TextStyle(
              color: VivaBemColors.branco,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder for completion rates - backend doesn't provide this data yet
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exemplo',
                  style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                Text(
                  '85.0%',
                  style: TextStyle(
                    color: VivaBemColors.verdeEsmeralda,
                    fontSize: 16,
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
}
