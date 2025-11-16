import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:projeto/services/api_service.dart';
import '../theme/app_colors.dart';
import '../models/cognitive_activity.dart';

import 'dart:convert';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({Key? key}) : super(key: key);

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  bool _isLoading = false;
  List<MovieActivity> _movies = [];

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);

    try {
      final http.Response response = await _apiService.getMovieActivities();

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        setState(() {
          _movies =
              responseData.map((json) => MovieActivity.fromJson(json)).toList();
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
    final movieTitleController = TextEditingController();
    final genreController = TextEditingController();
    final reviewController = TextEditingController();
    int selectedRating = 3;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: VivaBemColors.cinzaEscuro,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Adicionar Filme',
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
                  controller: movieTitleController,
                  label: 'Título do Filme',
                  icon: FontAwesomeIcons.film,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: genreController,
                  label: 'Gênero (opcional)',
                  icon: Icons.category,
                ),
                const SizedBox(height: 20),
                Text(
                  'Avaliação',
                  style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() => selectedRating = starValue);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          starValue <= selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: ActiveMindPalete.amareloDestaque,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: reviewController,
                  label: 'Sua opinião (opcional)',
                  icon: Icons.rate_review,
                  maxLines: 4,
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
                if (movieTitleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, insira o título do filme'),
                      backgroundColor: VivaBemColors.vermelhoErro,
                    ),
                  );
                  return;
                }

                final Map<String, dynamic> data = {
                  'movieTitle': movieTitleController.text,
                  'genre': genreController.text.isEmpty
                      ? null
                      : genreController.text,
                  'rating': selectedRating,
                  'watchDate': DateTime.now().toIso8601String(),
                  'review': reviewController.text.isEmpty
                      ? null
                      : reviewController.text,
                };

                setState(() => _isLoading = true);

                final response = await _apiService.createMovieActivity(data);

                if (response.statusCode == 201 || response.statusCode == 200) {
                  Navigator.pop(context);
                  _loadMovies(); 

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Filme salvo no servidor! 🎬'),
                      backgroundColor: ActiveMindPalete.verdeProgresso,
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  _showErrorSnackBar('Erro ao salvar filme no servidor.');
                }

                setState(() => _isLoading = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ActiveMindPalete.rosaFilmes,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Adicionar',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: VivaBemColors.branco, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: VivaBemColors.branco.withOpacity(0.7),
          fontSize: 16,
        ),
        prefixIcon: Icon(icon, color: ActiveMindPalete.rosaFilmes),
        filled: true,
        fillColor: VivaBemColors.branco.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ActiveMindPalete.rosaFilmes.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ActiveMindPalete.rosaFilmes.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ActiveMindPalete.rosaFilmes,
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final averageRating = _movies.isEmpty
        ? 0.0
        : _movies.fold<int>(0, (sum, m) => sum + m.rating) / _movies.length;

    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      appBar: AppBar(
        title: const Text(
          'Meu Diário de Filmes',
          style: TextStyle(
            color: VivaBemColors.branco,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: ActiveMindPalete.rosaFilmes,
        iconTheme: const IconThemeData(color: VivaBemColors.branco),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: ActiveMindPalete.rosaFilmes,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadMovies,
              color: ActiveMindPalete.rosaFilmes,
              child: Column(
                children: [
                  if (_movies.isNotEmpty)
                    _buildStatsHeader(_movies.length, averageRating),
                  Expanded(
                    child: _movies.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _movies.length,
                            itemBuilder: (context, index) {
                              return _buildMovieCard(_movies[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: ActiveMindPalete.rosaFilmes,
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Adicionar Filme',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatsHeader(int movieCount, double averageRating) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ActiveMindPalete.rosaFilmes.withOpacity(0.3),
            ActiveMindPalete.roxoLeitura.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ActiveMindPalete.rosaFilmes.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: FontAwesomeIcons.film,
            value: '$movieCount',
            label: 'Filmes Assistidos',
          ),
          Container(
            width: 2,
            height: 40,
            color: VivaBemColors.branco.withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Icons.star,
            value: averageRating.toStringAsFixed(1),
            label: 'Avaliação Média',
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
          textAlign: TextAlign.center,
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
              FontAwesomeIcons.film,
              size: 80,
              color: ActiveMindPalete.rosaFilmes.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum filme registrado',
              style: TextStyle(
                color: VivaBemColors.branco,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Comece seu diário de cinema!\nRegistre os filmes que você assistiu.',
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

  Widget _buildMovieCard(MovieActivity movie) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ActiveMindPalete.rosaFilmes.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ActiveMindPalete.rosaFilmes.withOpacity(0.5),
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
                  color: ActiveMindPalete.rosaFilmes.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.film,
                  color: ActiveMindPalete.rosaFilmes,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.movieTitle,
                      style: const TextStyle(
                        color: VivaBemColors.branco,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (movie.genre != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              ActiveMindPalete.azulPrincipal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                ActiveMindPalete.azulPrincipal.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          movie.genre!,
                          style: TextStyle(
                            color: VivaBemColors.branco.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Avaliação: ',
                style: TextStyle(
                  color: VivaBemColors.branco.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              ...List.generate(5, (index) {
                return Icon(
                  index < movie.rating ? Icons.star : Icons.star_border,
                  color: ActiveMindPalete.amareloDestaque,
                  size: 24,
                );
              }),
              const Spacer(),
              Icon(
                Icons.calendar_today,
                color: ActiveMindPalete.amareloDestaque,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd/MM/yyyy').format(movie.watchDate),
                style: TextStyle(
                  color: VivaBemColors.branco.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (movie.review != null && movie.review!.isNotEmpty) ...[
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
                    Icons.rate_review,
                    color: ActiveMindPalete.amareloDestaque,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      movie.review!,
                      style: TextStyle(
                        color: VivaBemColors.branco.withOpacity(0.8),
                        fontSize: 16,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
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
