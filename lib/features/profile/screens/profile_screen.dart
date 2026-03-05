import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil / Sobre')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final packageInfo = snapshot.data!;
          // Using a simple shared preference or just standard timestamp for 'ultimo acesso'
          // Since we are mocking user data for now
          final lastAccess = DateTime.now();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 60,
                  child: Icon(Icons.person, size: 60),
                ),
                const SizedBox(height: 24),
                Text(
                  'Administrador',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Gestor de Campeonato F1',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 48),
                _buildInfoRow(
                  context,
                  Icons.info_outline,
                  'Versão do App',
                  packageInfo.version,
                ),
                const Divider(),
                _buildInfoRow(
                  context,
                  Icons.build,
                  'Build',
                  packageInfo.buildNumber,
                ),
                const Divider(),
                _buildInfoRow(
                  context,
                  Icons.access_time,
                  'Último Acesso',
                  '${lastAccess.day}/${lastAccess.month}/${lastAccess.year} ${lastAccess.hour}:${lastAccess.minute}',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
