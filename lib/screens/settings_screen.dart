import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cycle_service.dart';
import '../theme/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int? _manualCycleLength;
  int? _manualPeriodDuration;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _manualCycleLength = prefs.getInt('manual_cycle_length');
      _manualPeriodDuration = prefs.getInt('manual_period_duration');
      _isLoading = false;
    });
  }

  Future<void> _setManualCycleLength(int? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove('manual_cycle_length');
    } else {
      await prefs.setInt('manual_cycle_length', value);
    }
    setState(() {
      _manualCycleLength = value;
    });
  }

  Future<void> _setManualPeriodDuration(int? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove('manual_period_duration');
    } else {
      await prefs.setInt('manual_period_duration', value);
    }
    setState(() {
      _manualPeriodDuration = value;
    });
  }

  void _showCycleLengthDialog() {
    final controller = TextEditingController(text: _manualCycleLength?.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Cycle Length'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the average number of days in your cycle:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Days (10-60)',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _setManualCycleLength(null);
                Navigator.pop(context);
              },
              child: const Text('Use Automatic'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final intValue = int.tryParse(controller.text);
              if (intValue != null && intValue >= 10 && intValue <= 60) {
                _setManualCycleLength(intValue);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a value between 10 and 60')),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPeriodDurationDialog() {
    final controller = TextEditingController(text: _manualPeriodDuration?.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Period Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the average number of days your period lasts:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Days (1-14)',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _setManualPeriodDuration(null);
                Navigator.pop(context);
              },
              child: const Text('Use Automatic'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final intValue = int.tryParse(controller.text);
              if (intValue != null && intValue >= 1 && intValue <= 14) {
                _setManualPeriodDuration(intValue);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a value between 1 and 14')),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final cycleService = Provider.of<CycleService>(context);
    final calculatedCycleLength = cycleService.averageCycleLength;
    final calculatedPeriodDuration = cycleService.averagePeriodDuration;

    final displayCycleLength = _manualCycleLength ?? calculatedCycleLength;
    final displayPeriodDuration = _manualPeriodDuration ?? calculatedPeriodDuration;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Cycle Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ListTile(
            title: const Text('Cycle Length'),
            subtitle: Text(
              '$displayCycleLength Days ${_manualCycleLength == null ? "(Auto)" : "(Manual)"}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showCycleLengthDialog,
          ),
          ListTile(
            title: const Text('Period Duration'),
            subtitle: Text(
              '$displayPeriodDuration Days ${_manualPeriodDuration == null ? "(Auto)" : "(Manual)"}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showPeriodDurationDialog,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const ListTile(
            title: Text('Floral Flow'),
            subtitle: Text('Period & Qada Fasting Tracker\nVersion 1.0.0'),
          ),
        ],
      ),
    );
  }
}
