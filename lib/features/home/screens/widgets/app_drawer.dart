import 'package:flutter/material.dart';
import 'package:gestao_corridas/core/database/database_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
        color: Theme.of(context).colorScheme.primary,
        image: DecorationImage(
          image: const NetworkImage(
            'https://media.formula1.com/image/upload/f_auto/q_auto/v1677244985/content/dam/fom-website/2018-redesign-assets/F1%20logo.png',
          ), // Just a placeholder style bg, or use local asset
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.4),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: const Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          'Gestão de Corridas',
          style: TextStyle(
            color: Colors.white,
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
