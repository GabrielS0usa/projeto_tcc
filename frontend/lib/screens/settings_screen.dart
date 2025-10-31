// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
                child: ListView(
                  children: [
                    _buildSettingsSection(
                      title: 'Conta',
                      items: [
                        _buildSettingsItem(
                          icon: FontAwesomeIcons.user,
                          title: 'Perfil',
                          subtitle: 'Editar informações pessoais',
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: FontAwesomeIcons.lock,
                          title: 'Privacidade',
                          subtitle: 'Gerenciar privacidade e segurança',
                          onTap: () {},
                        ),
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
                          onTap: () {},
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
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: FontAwesomeIcons.rightFromBracket,
                          title: 'Sair',
                          subtitle: 'Desconectar da conta',
                          onTap: () {},
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
    final color = isDestructive ? VivaBemColors.vermelhoErro : VivaBemColors.branco;
    
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
}
