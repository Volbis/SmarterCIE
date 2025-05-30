import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/energy_chart.dart';
import '../widgets/alert_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApiService>(context, listen: false).fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartMeter CIE'),
        backgroundColor: Colors.green,
      ),
      body: Consumer<ApiService>(
        builder: (context, apiService, child) {
          if (apiService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => apiService.fetchData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cartes de stats principales
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Puissance actuelle',
                          '${apiService.getCurrentPower().toStringAsFixed(1)} W',
                          Icons.flash_on,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Énergie aujourd\'hui',
                          '${apiService.getTodayEnergy().toStringAsFixed(2)} kWh',
                          Icons.battery_charging_full,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Alerte si consommation élevée
                  if (apiService.getCurrentPower() > 1500)
                    const AlertCard(
                      message: 'Consommation élevée détectée !',
                      type: AlertType.warning,
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Graphique
                  const Text(
                    'Historique de consommation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: EnergyChart(data: apiService.readings),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Astuces énergie
                  _buildTipCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    final tips = [
      '💡 Éteignez les appareils en veille pour économiser jusqu\'à 10% d\'énergie',
      '🌡️ Baissez le chauffage de 1°C pour économiser 7% d\'énergie',
      '💻 Activez le mode économie d\'énergie sur vos appareils',
      '🔌 Débranchez les chargeurs non utilisés',
    ];
    
    final randomTip = tips[DateTime.now().millisecond % tips.length];
    
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Astuce du moment',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
            ),
            const SizedBox(height: 8),
            Text(randomTip),
          ],
        ),
      ),
    );
  }
}