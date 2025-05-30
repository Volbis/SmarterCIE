import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _alertThreshold = 1500;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Français';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _alertThreshold = prefs.getDouble('alert_threshold') ?? 1500;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'Français';
    });
  }

  _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('alert_threshold', _alertThreshold);
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setString('selected_language', _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Seuil d'alerte
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seuil d\'alerte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Recevoir une alerte si la consommation dépasse :'),
                  SizedBox(height: 16),
                  Slider(
                    value: _alertThreshold,
                    min: 500,
                    max: 3000,
                    divisions: 25,
                    label: '${_alertThreshold.toInt()} W',
                    onChanged: (value) {
                      setState(() {
                        _alertThreshold = value;
                      });
                      _saveSettings();
                    },
                  ),
                  Text('Seuil actuel : ${_alertThreshold.toInt()} W'),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Notifications
          Card(
            child: SwitchListTile(
              title: Text('Notifications'),
              subtitle: Text('Recevoir des alertes en temps réel'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings();
              },
            ),
          ),

          SizedBox(height: 16),

          // Langue
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Langue du chatbot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    items: ['Français', 'English', 'Nouchi'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Informations
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('À propos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('SmartMeter CIE Mini v1.0'),
                  Text('Développé par l\'équipe CIE'),
                  SizedBox(height: 8),
                  Text('Une solution intelligente pour surveiller votre consommation électrique en temps réel.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}