import 'package:flutter/material.dart';

import '../di/injector.dart';
import 'app_config.dart';
import 'package:siren_marketplace/core/widgets/error_dialog.dart';

class DataSourceSwitcher extends StatefulWidget {
  final Widget child;

  const DataSourceSwitcher({Key? key, required this.child}) : super(key: key);

  @override
  State<DataSourceSwitcher> createState() => _DataSourceSwitcherState();
}

class _DataSourceSwitcherState extends State<DataSourceSwitcher> {
  DataSourceMode _currentMode = AppConfig.mode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (const bool.fromEnvironment('dart.vm.product') == false)
          Positioned(
            top: 50,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Data Source',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _buildModeButton(DataSourceMode.demo, '📦 Demo'),
                  _buildModeButton(DataSourceMode.local, '💾 Local'),
                  _buildModeButton(DataSourceMode.api, '🌐 API'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModeButton(DataSourceMode mode, String label) {
    final bool isSelected = _currentMode == mode;

    return GestureDetector(
      onTap: () async {
        if (isSelected) return;

        setState(() => _currentMode = mode);
        AppConfig.setMode(mode);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text('Switching to ${mode.name}...'),
              ],
            ),
          ),
        );

        try {
          await initDependencies(); // ← THIS IS NOW CORRECT
          if (context.mounted) Navigator.of(context).pop();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Switched to ${mode.name} mode')),
            );
          }
        } catch (e) {
          if (context.mounted) Navigator.of(context).pop();
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) =>
                  ErrorDialog(title: "Error", message: 'Error: $e'),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
