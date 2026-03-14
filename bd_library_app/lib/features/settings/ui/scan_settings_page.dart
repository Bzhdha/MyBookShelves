import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/scan_settings_store.dart';

/// Paramètres du scan ISBN : activation photo couverture/dos et intervalle de changement de rectangle.
class ScanSettingsPage extends StatelessWidget {
  const ScanSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ScanSettingsStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres scan ISBN'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Photo couverture et dos'),
            subtitle: const Text(
              'Après validation d\'un ISBN, proposer la prise de photo de la couverture puis du dos du livre.',
            ),
            value: store.photoCoverEnabled,
            onChanged: (v) => store.setPhotoCoverEnabled(v),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Intervalle de changement de rectangle'),
            subtitle: Text(
              '${store.rectangleIntervalSeconds} seconde(s)',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Slider(
              value: store.rectangleIntervalSeconds.toDouble(),
              min: ScanSettingsStore.minIntervalSeconds.toDouble(),
              max: ScanSettingsStore.maxIntervalSeconds.toDouble(),
              divisions: ScanSettingsStore.maxIntervalSeconds - ScanSettingsStore.minIntervalSeconds,
              label: '${store.rectangleIntervalSeconds} s',
              onChanged: (v) => store.setRectangleIntervalSeconds(v.toInt()),
            ),
          ),
        ],
      ),
    );
  }
}
