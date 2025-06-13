import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeter_app/services/user_data_manage/user_data_manage.dart';
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
    _loadDataAsync();
  }

  Future<void> _loadDataAsync() async {
    await Future.delayed(Duration.zero);
    if (_isFirstLoad && mounted) {
      _isFirstLoad = false;
      
      debugPrint('🔄 Début du chargement des données dashboard');
      
      final userService = Provider.of<UserService>(context, listen: false);
      debugPrint('👤 UserService actuel - UID: ${userService.userId}');
      debugPrint('⚡ Puissance actuelle avant fetch: ${userService.currentPower}');
      
      // Charger les données API et utilisateur
      await Future.wait([
        Provider.of<ApiService>(context, listen: false).fetchData(),
        userService.fetchUserData(),
      ]);
      
      // 🆕 Démarrer l'écoute en temps réel après le premier chargement
      userService.listenToUserData();
      userService.listenToAlertStatus(); 
          
      
      debugPrint('⚡ Puissance actuelle après fetch: ${userService.currentPower}');
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      Provider.of<ApiService>(context, listen: false).fetchData(),
      Provider.of<UserService>(context, listen: false).fetchUserData(), // 🆕 Refresh données utilisateur
    ]);
  }

  Future<void> markAlertAsRead() async {
    if (_userId == null) return;
    
    try {
      await _firestore.collection('users').doc(_userId).update({
        'alerte': false,
      });
      
      _hasAlert = false;
      notifyListeners();
      
      debugPrint('✅ Alerte marquée comme lue');
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour de l\'alerte: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer2<ApiService, UserService>( // 🆕 Consumer2 pour les deux services
        builder: (context, apiService, userService, child) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFF38b000),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header personnalisé avec nom dynamique
                SliverToBoxAdapter(
                  child: _buildHeader(apiService, userService), // 🆕 Passer userService
                ),
                // Contenu principal
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: (apiService.isLoading || userService.isLoading) && _isFirstLoad
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

  Widget _buildHeader(ApiService apiService, UserService userService) {
    // 🆕 Utiliser les valeurs depuis UserService (Firestore)
    // final currentPower = userService.isLoading ? 0.0 : userService.currentPower;
    
    final cout = userService.isLoading ? 0.0 : userService.cout;
    final todayEnergy = userService.isLoading ? 0.0 : userService.energie; // Utiliser energie depuis Firestore
    
    // Récupérer le nom utilisateur
    final userName = userService.displayName;
    final timeOfDay = _getTimeOfDay();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7FB069), Color(0xFF38b000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38b000).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom et notification
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeOfDay, // Salutation dynamique selon l'heure
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Gestion du loading et erreur pour le nom
                      userService.isLoading
                          ? const SizedBox(
                              width: 120,
                              height: 28,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              userName, //  Nom dynamique depuis Firestore
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                    // Afficher la bulle orange seulement si hasAlert est true
                    Consumer<UserService>(
                      builder: (context, userService, child) {
                        return userService.hasAlert
                            ? Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(218, 245, 93, 11),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromARGB(218, 245, 93, 11),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 7),

            // Statut et date
            Row(
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: child,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'En ligne',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Aujourd\'hui, ${DateTime.now().day} ${_getMonthName(DateTime.now().month)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Consommation actuelle (Données depuis Firestore)
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1200),
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${cout.toStringAsFixed(0)}', 
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      ' Fcfa',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${todayEnergy.toStringAsFixed(1)} kWh consommés aujourd\'hui', // 🆕 Energie depuis Firestore
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

    // Fonction helper pour la salutation selon l'heure
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Bonjour,';
    } else if (hour >= 12 && hour < 17) {
      return 'Bon après-midi,';
    } else if (hour >= 17 && hour < 21) {
      return 'Bonsoir,';
    } else {
      return 'Bonne nuit,';
    }
  }

  // Helper function pour le nom du mois
  String _getMonthName(int month) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return months[month - 1];
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFFF8A00)),
          SizedBox(height: 16),
          Text('Chargement des données...'),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(ApiService apiService) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConsumptionChart(apiService),
          const SizedBox(height: 25),
          _buildQuickStats(apiService),
          const SizedBox(height: 25),
          _buildAlertsSection(apiService),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildConsumptionChart(ApiService apiService) {
      return Consumer<UserService>(
        builder: (context, userService, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Consommation du jour',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: userService.yesterdayComparison < 0 ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            userService.yesterdayComparison < 0 ? Icons.trending_down : Icons.trending_up,
                            size: 14,
                            color: userService.yesterdayComparison < 0 ? Colors.green[600] : Colors.red[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            userService.yesterdayComparisonText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: userService.yesterdayComparison < 0 ? Colors.green[600] : Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                
                // Graphique circulaire avec progression dynamique
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutCubic,
                          tween: Tween<double>(begin: 0.0, end: userService.targetProgress.clamp(0.0, 1.0)),
                          builder: (context, value, child) {
                            return CustomPaint(
                              painter: CircularProgressPainter(
                                progress: value,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey[100]!,
                                progressColor: const Color(0xFFFF8A00),
                                secondaryColor: const Color(0xFFFF6B00),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Contenu central dynamique
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(begin: 0.0, end: userService.energie),
                            builder: (context, value, child) {
                              return Text(
                                '${value.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              );
                            },
                          ),
                          const Text(
                            'kWh',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${userService.targetProgressPercentage} de l\'objectif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.green[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

  Widget _buildQuickStats(ApiService apiService) {
      return Consumer<UserService>(
        builder: (context, userService, child) {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Économie',
                  userService.yesterdayComparisonText,
                  'vs hier',
                  userService.yesterdayComparison < 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  'Objectif',
                  userService.targetProgressPercentage,
                  'atteint',
                  Colors.orange,
                ),
              ),
            ],
          );
        },
      );
    }

  Widget _buildStatCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(ApiService apiService) {
      return Consumer<UserService>(
        builder: (context, userService, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Alertes & Conseils',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    'Tout voir',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              // Génération dynamique des alertes
              ...userService.alerts.map((alert) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getAlertBackgroundColor(alert['color']),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getAlertBorderColor(alert['color'])),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getAlertIconBackgroundColor(alert['color']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getAlertIcon(alert['icon']),
                        color: _getAlertIconColor(alert['color']),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert['title'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            alert['message'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          );
        },
      );
    }
    
  Color _getAlertBackgroundColor(String color) {
    switch (color) {
      case 'orange': return Colors.orange[50]!;
      case 'green': return Colors.green[50]!;
      case 'red': return Colors.red[50]!;
      default: return Colors.blue[50]!;
    }
  }

  Color _getAlertBorderColor(String color) {
    switch (color) {
      case 'orange': return Colors.orange[200]!;
      case 'green': return Colors.green[200]!;
      case 'red': return Colors.red[200]!;
      default: return Colors.blue[200]!;
    }
  }

  Color _getAlertIconBackgroundColor(String color) {
    switch (color) {
      case 'orange': return Colors.orange[100]!;
      case 'green': return Colors.green[100]!;
      case 'red': return Colors.red[100]!;
      default: return Colors.blue[100]!;
    }
  }

  Color _getAlertIconColor(String color) {
    switch (color) {
      case 'orange': return Colors.orange[600]!;
      case 'green': return Colors.green[600]!;
      case 'red': return Colors.red[600]!;
      default: return Colors.blue[600]!;
    }
  }

  IconData _getAlertIcon(String iconName) {
    switch (iconName) {
      case 'warning_amber_rounded': return Icons.warning_amber_rounded;
      case 'lightbulb_outline': return Icons.lightbulb_outline;
      default: return Icons.info_outline;
    }
  }

  @override
  bool get wantKeepAlive => true;
}

// Custom painter for circular progress
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final Color secondaryColor;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * 3.141592653589793,
        colors: [progressColor, secondaryColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    double sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}