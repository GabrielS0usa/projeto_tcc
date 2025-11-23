import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../models/cognitive_activity.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class ReadingLogScreen extends StatefulWidget {
  const ReadingLogScreen({Key? key}) : super(key: key);

  @override
  State<ReadingLogScreen> createState() => _ReadingLogScreenState();
}

class _ReadingLogScreenState extends State<ReadingLogScreen> {
  bool _isLoading = false;
  List<ReadingActivity> _readings = [];

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.getReadingActivities();

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _readings =
              data.map((json) => ReadingActivity.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar leituras');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar leituras: $e'),
            backgroundColor: VivaBemColors.vermelhoErro,
          ),
        );
      }
    }
  }

  Future<void> _saveReading({
    required ReadingActivity? reading,
    required TextEditingController titleController,
    required TextEditingController authorController,
    required TextEditingController totalPagesController,
    required TextEditingController currentPageController,
    required TextEditingController notesController,
  }) async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o título do livro'),
          backgroundColor: VivaBemColors.vermelhoErro,
        ),
      );
      return;
    }

    final isEditing = reading != null;
    final apiService = ApiService();

    final data = {
      'bookTitle': titleController.text,
      'author': authorController.text.isEmpty ? null : authorController.text,
      'totalPages': int.tryParse(totalPagesController.text) ?? 0,
      'currentPage': int.tryParse(currentPageController.text) ?? 0,
      'notes': notesController.text.isEmpty ? null : notesController.text,
      'startDate': (reading?.startDate ?? DateTime.now()).toIso8601String(),
      'completionDate': reading?.completionDate?.toIso8601String(),
      'isCompleted': reading?.isCompleted ?? false,
    };

    try {
      final response = isEditing
          ? await apiService.updateReadingActivity(int.parse(reading.id!), data)
          : await apiService.createReadingActivity(data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        await _loadReadings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing ? 'Leitura atualizada!' : 'Livro adicionado!',
              ),
              backgroundColor: ActiveMindPalete.verdeProgresso,
            ),
          );
        }
      } else {
        throw Exception('Falha ao salvar leitura');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar leitura: $e'),
            backgroundColor: VivaBemColors.vermelhoErro,
          ),
        );
      }
    }
  }

  void _showAddEditDialog({ReadingActivity? reading}) {
    final isEditing = reading != null;
    final titleController =
        TextEditingController(text: reading?.bookTitle ?? '');
    final authorController = TextEditingController(text: reading?.author ?? '');
    final totalPagesController = TextEditingController(
      text: reading?.totalPages.toString() ?? '',
    );
    final currentPageController = TextEditingController(
      text: reading?.currentPage.toString() ?? '',
    );
    final notesController = TextEditingController(text: reading?.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VivaBemColors.cinzaEscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing ? 'Atualizar Leitura' : 'Adicionar Livro',
          style: const TextStyle(
            color: VivaBemColors.branco,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: titleController,
                label: 'Título do Livro',
                icon: Icons.book,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: authorController,
                label: 'Autor',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: totalPagesController,
                      label: 'Total de Páginas',
                      icon: Icons.pages,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: currentPageController,
                      label: 'Página Atual',
                      icon: Icons.bookmark,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
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
            onPressed: () => _saveReading(
              reading: reading,
              titleController: titleController,
              authorController: authorController,
              totalPagesController: totalPagesController,
              currentPageController: currentPageController,
              notesController: notesController,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ActiveMindPalete.roxoLeitura,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isEditing ? 'Atualizar' : 'Adicionar',
              style: const TextStyle(
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
        prefixIcon: Icon(icon, color: ActiveMindPalete.roxoLeitura),
        filled: true,
        fillColor: VivaBemColors.branco.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: ActiveMindPalete.roxoLeitura.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: ActiveMindPalete.roxoLeitura.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: ActiveMindPalete.roxoLeitura, width: 2),
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
          'Minha Leitura',
          style: TextStyle(
            color: VivaBemColors.branco,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: ActiveMindPalete.roxoLeitura,
        iconTheme: const IconThemeData(color: VivaBemColors.branco),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: ActiveMindPalete.roxoLeitura,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadReadings,
              color: ActiveMindPalete.roxoLeitura,
              child: _readings.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _readings.length,
                      itemBuilder: (context, index) {
                        return _buildReadingCard(_readings[index]);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: ActiveMindPalete.roxoLeitura,
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Adicionar Livro',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
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
              FontAwesomeIcons.bookOpen,
              size: 80,
              color: ActiveMindPalete.roxoLeitura.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum livro registrado',
              style: TextStyle(
                color: VivaBemColors.branco,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Comece sua jornada literária!\nToque no botão abaixo para adicionar seu primeiro livro.',
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

  Widget _buildReadingCard(ReadingActivity reading) {
    final progress = reading.progressPercentage;

    return GestureDetector(
      onTap: () => _showAddEditDialog(reading: reading),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ActiveMindPalete.roxoLeitura.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ActiveMindPalete.roxoLeitura.withOpacity(0.5),
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
                    color: ActiveMindPalete.roxoLeitura.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.book,
                    color: ActiveMindPalete.roxoLeitura,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reading.bookTitle,
                        style: const TextStyle(
                          color: VivaBemColors.branco,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (reading.author != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          reading.author!,
                          style: TextStyle(
                            color: VivaBemColors.branco.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (reading.isCompleted)
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
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progresso',
                      style: TextStyle(
                        color: VivaBemColors.branco.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${reading.currentPage} / ${reading.totalPages} páginas',
                      style: const TextStyle(
                        color: ActiveMindPalete.amareloDestaque,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 12,
                    backgroundColor: VivaBemColors.branco.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      reading.isCompleted
                          ? ActiveMindPalete.verdeProgresso
                          : ActiveMindPalete.roxoLeitura,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${progress.toStringAsFixed(0)}% concluído',
                  style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (reading.notes != null && reading.notes!.isNotEmpty) ...[
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
                        reading.notes!,
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
            const SizedBox(height: 12),
            Text(
              'Iniciado em ${DateFormat('dd/MM/yyyy').format(reading.startDate)}',
              style: TextStyle(
                color: VivaBemColors.branco.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
