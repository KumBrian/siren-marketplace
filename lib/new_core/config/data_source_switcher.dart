import 'package:flutter/material.dart';

import '../di/injection.dart';
import 'app_config.dart';

/// Widget for easily switching data sources in debug builds
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

        // Floating debug menu (only in debug mode)
        if (const bool.fromEnvironment('dart.vm.product') == false)
          Positioned(
            top: 50,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Data Source',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(height: 8),
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
    final isSelected = _currentMode == mode;

    return GestureDetector(
      onTap: () async {
        setState(() => _currentMode = mode);
        AppConfig.setMode(mode);

        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Switching to ${mode.name}...'),
              ],
            ),
          ),
        );

        // Reinitialize DI
        try {
          await DI().init();
          Navigator.of(context).pop(); // Close loading dialog

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Switched to ${mode.name} mode')),
          );
        } catch (e) {
          Navigator.of(context).pop(); // Close loading dialog

          // Show error
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      },
      child: Container(
        margin: EdgeInsets.only(top: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
