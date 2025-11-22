import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Cycle Length'),
            subtitle: const Text('28 Days'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement cycle length setting
            },
          ),
          ListTile(
            title: const Text('Period Length'),
            subtitle: const Text('5 Days'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement period length setting
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Notifications'),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          const Divider(),
          const ListTile(
            title: Text('About'),
            subtitle: Text('Floral Flow v1.0.0'),
          ),
        ],
      ),
    );
  }
}
