import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../widgets/header_clipper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../theme/app_colors.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dateController = TextEditingController();
  final _caregiverNameController = TextEditingController();
  final _caregiverEmailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
    _caregiverNameController.dispose();
    _caregiverEmailController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String baseUrl = dotenv.env['API_BASE_URL']!;
      final url = Uri.parse('$baseUrl/auth/register');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'birthDate': _dateController.text,
          'password': _passwordController.text,
          'caregiverName': _caregiverNameController.text,
          'caregiverEmail': _caregiverEmailController.text,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccess('Conta criada com sucesso! Por favor, faça o login.');
        if (mounted) Navigator.pop(context);
      } else {
        String errorMessage =
            "Ocorreu um erro ao criar a conta. Tente novamente.";
        if (response.body.isNotEmpty && response.body.trim().startsWith('{')) {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          } catch (e) {
            print("Erro ao decodificar o JSON de erro do servidor: $e");
          }
        }
        _showError(errorMessage);
      }
    } catch (e) {
      print("ERRO DETALHADO DE CONEXÃO: $e");
      _showError('Falha na conexão com o servidor. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), backgroundColor: VivaBemColors.vermelhoErro),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: VivaBemColors.verdeConfirmacao),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VivaBemColors.branco,
      body: SingleChildScrollView(
        child: Column(children: [_buildHeader(), _buildForm()]),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipPath(
      clipper: HeaderClipper(),
      child: Container(
        height: 250,
        color: VivaBemColors.cinzaEscuro,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon:
                      const Icon(Icons.arrow_back, color: VivaBemColors.branco),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/images/velinho_vermelho.png',
                  height: 150,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Criar nova conta',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: VivaBemColors.cinzaEscuro)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Já está registrado?'),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Login aqui.',
                      style: TextStyle(
                          color: VivaBemColors.cinzaEscuro,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildTextField(controller: _nameController, label: 'NOME'),
            const SizedBox(height: 20),
            _buildTextField(
                controller: _emailController,
                label: 'EMAIL',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _buildTextField(
                controller: _phoneController,
                label: 'TELEFONE',
                hint: '(XX) XXXXX-XXXX',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 20),
            _buildDateField(),
            const SizedBox(height: 30),
            const Text(
              'Informações do Cuidador (Opcional)',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: VivaBemColors.cinzaEscuro),
            ),
            const SizedBox(height: 15),
            _buildTextField(
                controller: _caregiverNameController,
                label: 'NOME DO CUIDADOR',
                isOptional: true),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _caregiverEmailController,
              label: 'EMAIL DO CUIDADOR',
              hint: 'email.cuidador@exemplo.com',
              keyboardType: TextInputType.emailAddress,
              isOptional: true,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: VivaBemColors.cinzaEscuro,
                foregroundColor: VivaBemColors.branco,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: VivaBemColors.branco, strokeWidth: 2))
                  : const Text('Continuar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: VivaBemColors.cinzaClaro,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (isOptional && (value == null || value.isEmpty)) {
          return null;
        }

        if (!isOptional && (value == null || value.isEmpty)) {
          return 'Por favor, preencha este campo';
        }

        if (keyboardType == TextInputType.emailAddress &&
            value != null &&
            value.isNotEmpty) {
          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
            return 'Por favor, insira um email válido';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SENHA', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '******',
            filled: true,
            fillColor: VivaBemColors.cinzaClaro,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            suffixIcon: IconButton(
              icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, digite uma senha';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DATA DE NASCIMENTO',
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'SELECIONAR',
            filled: true,
            fillColor: VivaBemColors.cinzaClaro,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now());
            if (pickedDate != null) {
              String formattedDate =
                  DateFormat('dd-MM-yyyy').format(pickedDate);
              setState(() {
                _dateController.text = formattedDate;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, selecione uma data';
            }
            return null;
          },
        ),
      ],
    );
  }
}
