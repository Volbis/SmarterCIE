import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smartmeter_app/services/auth_services/auth_service.dart';
import 'package:smartmeter_app/services/user_data_manage/user_data_manage.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'services/api_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/auth.dart';

void main() async {
  // Assurez-vous que Flutter est initialisé
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("✅ Firebase initialisé avec succès");
  
  
  // 🎯 Initialiser Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );


  // Chargement des variables d'environnement
  try {
    await dotenv.load(fileName: "assets/config/.env");
    print("✅ Variables d'environnement chargées");
  } catch (e) {
    print("⚠️ Fichier .env non trouvé ou erreur de lecture: $e");
  }

  // Optimisation du rendu de l'application
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  
  // Préchargez les données essentielles si nécessaire
  // await _preloadData();
  
  // Lancement avec un splash screen
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Création différée du service API pour éviter le blocage initial
        ChangeNotifierProvider(
          create: (_) => ApiService(),
          lazy: true, // Ne crée le service que lorsqu'il est demandé
        ),

          //Le service Google Auth
        ChangeNotifierProvider(
          create: (_) => GoogleAuthService(),
          lazy: false,
        ),

        // Le service d'authentification principal
        ChangeNotifierProvider(
          create: (_) => UserService(),
          lazy: false, // Chargement immédiat pour éviter les problèmes de synchronisation
          ), 
      ],

      child: MaterialApp(
        title: 'SmartMeter CIE',
        debugShowCheckedModeBanner: false, // Supprime la bannière debug
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Optimisations pour un rendu plus rapide
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

// Écran de chargement pour améliorer l'UX pendant l'initialisation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Contrôleurs d'animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
    _navigateToAuth();
  }

  void _startAnimations() async {
    // Démarrer les animations en séquence
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _slideController.forward();
  }

  _navigateToAuth() async {
    await Future.delayed(const Duration(milliseconds: 4000));
    
    // Animation de sortie
    await _fadeController.reverse();
    
    // Navigation vers l'écran d'authentification
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AuthPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E7D32), // Vert foncé
              Color(0xFF4CAF50), // Vert principal
              Color(0xFF66BB6A), // Vert clair
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Section principale avec logo et titre
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo animé
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.power_settings_new,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Titre avec animation de slide
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              const Text(
                                'SmartMeter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'CIE',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 4.0,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: 80,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Section du bas avec loading et version
              Expanded(
                flex: 1,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Indicateur de chargement personnalisé
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Texte de chargement
                      Text(
                        'Initialisation...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Version info
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    

    _screens = [
      _buildLazyScreen((context) => const DashboardScreen()),
      _buildLazyScreen((context) => const ChatbotScreen()),
      _buildLazyScreen((context) => const SettingsScreen()),
    ];
  }

  // Construction différée des widgets d'écran
  Widget _buildLazyScreen(WidgetBuilder builder) {
    return Builder(builder: (context) => builder(context));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Nécessaire pour AutomaticKeepAliveClientMixin
    
    return Scaffold(
      // Utiliser IndexedStack pour préserver l'état des écrans
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Assistant IA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true; // Garder l'état des écrans en mémoire
}