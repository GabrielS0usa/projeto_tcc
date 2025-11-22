import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _caregiverNameController;
  late TextEditingController _caregiverEmailController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);

    _caregiverNameController =
        TextEditingController(text: widget.user.nameCaregiver ?? "");
    _caregiverEmailController =
        TextEditingController(text: widget.user.emailCaregiver ?? "");
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Verificar se o ID existe antes de tentar salvar
    if (widget.user.id == null) {
      _showError("Erro: Usuário sem ID. Faça login novamente.");
      return;
    }

    setState(() => _isSaving = true);

    final body = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "caregiverName": _caregiverNameController.text.trim().isEmpty
          ? null
          : _caregiverNameController.text.trim(),
      "caregiverEmail": _caregiverEmailController.text.trim().isEmpty
          ? null
          : _caregiverEmailController.text.trim(),
      "preferences": null 
    };

    try {
      final res = await _apiService.updateUserProfile(
        userId: widget.user.id!, // Agora é seguro usar o operador !
        data: body,
      );

      if (res.statusCode == 200) {
        final updatedUser = widget.user.copyWith(
          id: widget.user.id, // ← Mantém o ID original do usuário
          name: body["name"],
          email: body["email"],
          nameCaregiver: body["caregiverName"],
          emailCaregiver: body["caregiverEmail"],
        );

        if (!mounted) return;
        Navigator.pop(context, updatedUser);
      } else {
        _showError("Falha ao atualizar perfil");
      }
    } catch (e) {
      _showError("Erro ao salvar: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: VivaBemColors.vermelhoErro,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VivaBemColors.cinzaEscuro,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Editar Perfil",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Nome
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Nome"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Informe seu nome" : null,
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("E-mail"),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Informe seu e-mail";
                    if (!v.contains("@")) return "E-mail inválido";
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Título do bloco
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Informações do cuidador",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Nome cuidador
                TextFormField(
                  controller: _caregiverNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Nome do cuidador (opcional)"),
                ),
                const SizedBox(height: 20),

                // Email cuidador
                TextFormField(
                  controller: _caregiverEmailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("E-mail do cuidador (opcional)"),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && !v.contains("@")) {
                      return "E-mail inválido";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // Botão salvar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VivaBemColors.amareloDourado,
                      foregroundColor: VivaBemColors.azulMarinho,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Salvar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: VivaBemColors.amareloDourado),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}