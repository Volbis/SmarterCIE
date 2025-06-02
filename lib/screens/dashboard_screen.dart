import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/energy_chart.dart';
import '../widgets/alert_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  bool _isFirstLoad = true;
  
  @override
  void initState() {
    super.initState();
    // Chargement différé pour ne pas bloquer l'UI
    _loadDataAsync();
  }

  Future<void> _loadDataAsync() async {
    // Laisser l'UI se construire d'abord
    await Future.delayed(Duration.zero);
    if (_isFirstLoad && mounted) {
      _isFirstLoad = false;
      await Provider.of<ApiService>(context, listen: false).fetchData();
    }
  }

  Future<void> _refreshData() async {
    await Provider.of<ApiService>(context, listen: false).fetchData();
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Nécessaire pour AutomaticKeepAliveClientMixin
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartMeter CIE'),
        backgroundColor: Colors.green,
      ),
      body: Consumer<ApiService>(
        builder: (context, apiService, child) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: apiService.isLoading && _isFirstLoad
                      ? _buildLoadingView()
                      : _buildDashboardContent(apiService),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des données...'),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(ApiService apiService) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats principales - avec pré-chargement des valeurs
          _buildStatCards(apiService),
          
          const SizedBox(height: 20),
          
          // Alerte conditionnelle - rendue uniquement si nécessaire
          _buildConditionalAlert(apiService),
          
          const SizedBox(height: 20),
          
          // Graphique - chargement optimisé
          _buildEnergyChart(apiService),
          
          const SizedBox(height: 20),
          
          // Astuces - prégénéré pour performance
          _buildTipCard(),
        ],
      ),
    );
  }

  Widget _buildStatCards(ApiService apiService) {
    // Cache les valeurs pour éviter les recalculs
    final currentPower = apiService.isLoading ? 0.0 : apiService.getCurrentPower();
    final todayEnergy = apiService.isLoading ? 0.0 : apiService.getTodayEnergy();
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Puissance actuelle',
            '${currentPower.toStringAsFixed(1)} W',
            Icons.flash_on,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Énergie aujourd\'hui',
            '${todayEnergy.toStringAsFixed(2)} kWh',
            Icons.battery_charging_full,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionalAlert(ApiService apiService) {
    // Éviter le calcul redondant
    final currentPower = apiService.isLoading ? 0.0 : apiService.getCurrentPower();
    
    return currentPower > 1500
        ? const AlertCard(
            message: 'Consommation élevée détectée !',
            type: AlertType.warning,
          )
        : const SizedBox.shrink(); // Widget vide si pas d'alerte
  }

  Widget _buildEnergyChart(ApiService apiService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historique de consommation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          // Éviter de recréer le graphique si les données sont vides
          child: apiService.readings.isEmpty
              ? const Center(child: Text('Aucune donnée disponible'))
              : EnergyChart(data: apiService.readings),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    // Utiliser const où possible
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
                    overflow: TextOverflow.ellipsis,
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
    
    // Utiliser un indice fixe pour éviter des calculs à chaque rebuild
    final tipIndex = (DateTime.now().hour + DateTime.now().minute) % tips.length;
    final randomTip = tips[tipIndex];
    
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
  
  @override
  bool get wantKeepAlive => true; 
}