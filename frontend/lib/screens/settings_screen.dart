// lib/screens/settings_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../models/user_profile.dart';
import '../screens/edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  String? _error;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getUserMe();
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final storage = const FlutterSecureStorage();
        final storedIdString = await storage.read(key: 'userId');
        final storedId =
            storedIdString != null ? int.tryParse(storedIdString) : null;

        setState(() {
          _userProfile = UserProfile.fromJson(
            data,
            fallbackId: storedId,
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Falha ao carregar perfil';
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

  Future<void> _handleLogout() async {
    try {
      final response = await _apiService.logoutUser();
      if (response.statusCode == 200 || response.statusCode == 204) {
        await _storage.delete(key: 'jwt_token');
        await _storage.delete(key: 'userId');

        if (!mounted) return;
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        _showError('Falha ao fazer logout');
      }
    } catch (e) {
      _showError('Erro ao fazer logout: $e');
    }
  }

  Future<void> _toggleConsent(bool value) async {
    if (_userProfile == null) return;

    final userIdString = await _storage.read(key: 'userId');
    if (userIdString == null) {
      _showError("Usuário não encontrado no dispositivo.");
      return;
    }

    if (userIdString == null ||
        userIdString.isEmpty ||
        userIdString == "null") {
      _showError("ID do usuário inválido.");
      return;
    }

    final userId = int.tryParse(userIdString);
    if (userId == null) {
      _showError("Falha ao converter user_id para número.");
      return;
    }

    setState(() {
      _userProfile = _userProfile!.copyWith(reportingConsent: value);
    });

    final body = {
      "dataSharing": value,
      "analytics": value,
      "notifications": false,
      "active": value,
      "caregiverEmail": _userProfile!.emailCaregiver,
    };

    try {
      final res =
          await _apiService.updateUserConsent(userId: userId, body: body);

      if (res.statusCode != 200) {
        debugPrint("STATUS CODE: ${res.statusCode}");
        debugPrint("RESPONSE BODY: ${res.body}");

        setState(() {
          _userProfile = _userProfile!.copyWith(reportingConsent: !value);
        });
        _showError("Falha ao atualizar consentimento");
      }
    } catch (e) {
      setState(() {
        _userProfile = _userProfile!.copyWith(reportingConsent: !value);
      });
      _showError("Erro: $e");
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

  void _navigateToEditProfile() async {
    if (_userProfile == null) return;

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: _userProfile!),
      ),
    );

    if (updated != null && updated is UserProfile) {
      setState(() {
        _userProfile = updated;
      });
    }
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
                'Configurações',
                style: TextStyle(
                  color: VivaBemColors.branco,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Personalize sua experiência',
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
                        : _buildSettingsView(),
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
            'Erro ao carregar configurações',
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
            onPressed: _fetchUserProfile,
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

  Widget _buildSettingsView() {
    return ListView(
      children: [
        _buildSettingsSection(
          title: 'Conta',
          items: [
            _buildSettingsItem(
              icon: FontAwesomeIcons.user,
              title: 'Editar Perfil',
              subtitle: 'Atualizar informações pessoais',
              onTap: _navigateToEditProfile,
            ),
            _buildConsentToggle(),
          ],
        ),
        const SizedBox(height: 20),
        _buildSettingsSection(
          title: 'Notificações',
          items: [
            _buildSettingsItem(
              icon: FontAwesomeIcons.bell,
              title: 'Lembretes',
              subtitle: 'Configurar notificações',
              onTap: () {
                _showError('Configurações de notificações em desenvolvimento');
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSettingsSection(
          title: 'Sobre',
          items: [
            _buildSettingsItem(
              icon: FontAwesomeIcons.circleInfo,
              title: 'Informações do App',
              subtitle: 'Versão 1.0.0',
              onTap: () {
                // TODO: Show app info dialog
                _showError('Informações do app em desenvolvimento');
              },
            ),
            _buildSettingsItem(
              icon: FontAwesomeIcons.rightFromBracket,
              title: 'Sair',
              subtitle: 'Desconectar da conta',
              onTap: _handleLogout,
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: VivaBemColors.amareloDourado,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: VivaBemColors.azulMarinho.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive ? VivaBemColors.vermelhoErro : VivaBemColors.branco;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FaIcon(
                icon,
                size: 20,
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
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: VivaBemColors.branco.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              FontAwesomeIcons.chartLine,
              size: 20,
              color: VivaBemColors.branco,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relatórios de Progresso',
                  style: TextStyle(
                    color: VivaBemColors.branco,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Permitir coleta de dados para relatórios',
                  style: TextStyle(
                    color: VivaBemColors.branco.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _userProfile?.reportingConsent ?? false,
            onChanged: _toggleConsent,
            activeColor: VivaBemColors.amareloDourado,
            activeTrackColor: VivaBemColors.amareloDourado.withOpacity(0.3),
            inactiveThumbColor: VivaBemColors.branco.withOpacity(0.7),
            inactiveTrackColor: VivaBemColors.azulMarinho.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
