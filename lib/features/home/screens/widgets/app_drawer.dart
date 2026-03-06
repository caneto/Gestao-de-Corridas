import 'package:flutter/material.dart';
import 'package:gestao_corridas/core/database/database_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestao_corridas/core/blocs/theme/theme_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Links Importantes (F1)'),
                  onTap: () {
                    // Example external link
                    _launchURL('https://www.formula1.com');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Dados do Usuário'),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    context.push('/profile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.save_alt),
                  title: const Text('Exportar Banco de Dados'),
                  onTap: () async {
                    Navigator.pop(context);
                    final path = await DatabaseHelper.instance.exportDatabase();
                    if (context.mounted) {
                      if (path != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('DB Exportado para: $path')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Falha ao exportar DB')),
                        );
                      }
                    }
                  },
                ),
                const Divider(),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return ListTile(
                      leading: Icon(
                        state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      ),
                      title: const Text('Seleção Fundo'),
                      trailing: Switch(
                        value: state.isDarkMode,
                        onChanged: (value) {
                          context.read<ThemeBloc>().add(ToggleTheme(value));
                        },
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configurações & Edição'),
                  onTap: () {
                    Navigator.pop(context);
                    // Feature toggles or additional settings here
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: const AssetImage('assets/f1.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: const Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          'Gestão de Corridas',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final packageInfo = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Versão: ${packageInfo.version} (${packageInfo.buildNumber})',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }
}
