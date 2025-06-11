import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartmeter_app/main.dart';
import 'package:smartmeter_app/services/auth_services/auth_service.dart';

import 'package:smartmeter_app/screens/form_infos.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}


class _AuthPageState extends State<AuthPage>
    with TickerProviderStateMixin {
  bool isSignUp = true;
  bool isPasswordVisible = false;
  bool isLoading = false;
  bool rememberMe = false;
  bool _emailLinkSent = false; // Nouveau état pour le lien e-mail
  String currentLanguage = 'fr';

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  Map<String, dynamic> get translations => {
    'fr': {
      'signUp': 'Inscription',
      'signIn': 'Connexion',
      'subtitle': 'Gérez intelligemment votre consommation électrique en Côte d\'Ivoire',
      'name': 'Nom',
      'emailPhone': 'Email/Numéro de téléphone',
      'password': 'Mot de passe',
      'createAccount': 'Créer un compte',
      'haveAccount': 'Vous avez déjà un compte ?',
      'remember': 'Se souvenir de moi',
      'forgotPassword': 'Mot de passe oublié ?',
      'noAccount': 'Vous n\'avez pas de compte ?',
      'or': 'ou',
      'terms': 'J\'accepte les Conditions d\'utilisation et la Politique de confidentialité',
      'facebook': 'Facebook',
      'google': 'Google',
      'emailLink': 'Connexion par e-mail',
      'emailLinkSent': 'Lien envoyé ! Vérifiez votre e-mail.',
    },
    'en': {
      'signUp': 'Sign Up',
      'signIn': 'Sign In',
      'subtitle': 'Intelligently manage your electricity consumption in Côte d\'Ivoire',
      'name': 'Name',
      'emailPhone': 'Email/Phone Number',
      'password': 'Password',
      'createAccount': 'Create Account',
      'haveAccount': 'Do you have account?',
      'remember': 'Remember me',
      'forgotPassword': 'Forgot Password?',
      'noAccount': 'Don\'t have an account?',
      'or': 'or',
      'terms': 'I\'m agree to The Terms of Service and Privacy Policy',
      'facebook': 'Facebook',
      'google': 'Google',
      'emailLink': 'Email Link Login',
      'emailLinkSent': 'Link sent! Check your email.',
    }
  };

  String t(String key) => translations[currentLanguage][key] ?? key;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content 
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                            MediaQuery.of(context).padding.top - 40,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40), 
                      _buildLogoSection(),
                      const SizedBox(height: 30), 
                      _buildAuthTabs(),
                      const SizedBox(height: 25), 
                      _buildSocialSection(),
                      const SizedBox(height: 15), 
                      _buildDivider(),
                      const SizedBox(height: 15), 

                    // 🧪 BOUTON TEMPORAIRE POUR TESTER LE FORMULAIRE
                      _buildTestFormButton()
                      
                      ,
                      const SizedBox(height: 20),
                      _buildForm(),
                      const SizedBox(height: 20), 
                      _buildPrimaryButton(),
                      const SizedBox(height: 15),
                      // Nouvelle section pour connexion par lien e-mail
                      if (!isSignUp && !_emailLinkSent) _buildEmailLinkButton(),
                      if (!isSignUp && _emailLinkSent) _buildEmailLinkSentMessage(),
                      const SizedBox(height: 15),
                      _buildSwitchAuth(),
                      const SizedBox(height: 20), 
          
                    ],
                  ),
                ),
              ),
            ),
            // Overlay pour les erreurs et loading depuis le service
            Consumer<GoogleAuthService>(
              builder: (context, authService, child) {
                if (authService.isLoading && !isLoading) {
                  return Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
    

// 🧪 MÉTHODE TEMPORAIRE POUR TESTER LE FORMULAIRE
Widget _buildTestFormButton() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        // Séparateur visuel
        Container(
          height: 1,
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(vertical: 10),
        ),
        
        // Titre de debug
        const Text(
          '🧪 Mode Debug',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
   
        const SizedBox(height: 10),
        
        // Bouton de test
        ElevatedButton.icon(
          onPressed: _navigateToTestForm,
          icon: const Icon(
            Icons.science_outlined,
            color: Colors.white,
            size: 20,
          ),
          label: const Text(
            'Tester le formulaire d\'infos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        
        // Info supplémentaire
        const SizedBox(height: 8),
        const Text(
          'Bouton temporaire - À supprimer plus tard',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ),
  );
}

// 🧪 MÉTHODE POUR NAVIGUER VERS LE FORMULAIRE DE TEST
void _navigateToTestForm() {
  HapticFeedback.lightImpact();
  
  // Navigation directe vers le formulaire sans authentification
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const UserProfileSetupScreen(
        isNewUser: true, // Simuler un nouvel utilisateur
      ),
    ),
  );
  
  // Message informatif
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('🧪 Mode test : Navigation vers le formulaire'),
      backgroundColor: Colors.purple,
      duration: Duration(seconds: 2),
    ),
  );
}




/*
  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E5E9), width: 1.5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            currentLanguage = currentLanguage == 'fr' ? 'en' : 'fr';
          });
        },
        child: Text(
          currentLanguage == 'fr' ? '🇫🇷 FR' : '🇬🇧 EN',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
*/
  


  Widget _buildLogoSection() {
    return Container(
      width: double.infinity,
      height: 235, 
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/login_img.png'),
          fit: BoxFit.cover, // L'image couvre tout l'arrière-plan
          opacity: 0.3, // Transparence pour que le texte reste lisible
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isSignUp ? t('signUp') : t('signIn'),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t('subtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthTabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _switchTab(false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: !isSignUp ? const Color(0xFFFF8A00) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                t('signIn'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  // CORRECTION ICI : logique inversée
                  color: !isSignUp ? const Color(0xFFFF8A00) : const Color(0xFF666666),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => _switchTab(true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSignUp ? const Color(0xFFFF8A00) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                t('signUp'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSignUp ? const Color(0xFFFF8A00) : const Color(0xFF666666),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
    
  Widget _buildSocialSection() {
    return Row(
      children: [
/*
        Expanded(
          child: _buildSocialButton(
            'facebook', 
            'assets/images/facebook.png', 
            t('facebook')
          )
        ),
*/
        const SizedBox(width: 15),
        Expanded(
          child: _buildSocialButton(
            'google', 
            'assets/images/google.png', 
            t('google')
          )
        ),
      ],
    );
  }

  Widget _buildSocialButton(String provider, String iconPath, String label) {
    return GestureDetector(
      onTap: () => _socialLogin(provider),
      child: Container(
        height: 50,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE1E5E9), width: 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image au lieu d'emoji
            Image.asset(
              iconPath,
              width: 60,
              height:60,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: provider == 'facebook' 
                    ? const Color(0xFF1877F2) 
                    : const Color(0xFF4285F4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE1E5E9))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            t('or'),
            style: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE1E5E9))),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        if (isSignUp) ...[
          _buildTextField(
            controller: nameController,
            focusNode: nameFocus,
            hintText: t('name'),
            nextFocusNode: emailFocus,
          ),
          const SizedBox(height: 14),
        ],
        _buildTextField(
          controller: emailController,
          focusNode: emailFocus,
          hintText: t('emailPhone'),
          nextFocusNode: passwordFocus,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: passwordController,
          focusNode: passwordFocus,
          hintText: t('password'),
          isPassword: true,
        ),
        const SizedBox(height: 14),
        if (!isSignUp) _buildRememberMe(),

        // Affichage des erreurs du service
        Consumer<GoogleAuthService>(
          builder: (context, authService, child) {
            if (authService.errorMessage != null) {
              return Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  authService.errorMessage!,
                  style: TextStyle(color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    FocusNode? nextFocusNode,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focusNode.hasFocus 
            ? const Color(0xFFFF8A00) 
            : const Color(0xFFE1E5E9),
          width: 1.5,
        ),
        boxShadow: focusNode.hasFocus ? [
          BoxShadow(
            color: const Color(0xFFFF8A00).withOpacity(0.1),
            blurRadius: 0,
            spreadRadius: 3,
          ),
        ] : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && !isPasswordVisible,
        onSubmitted: (_) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF999999)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF999999),
            ),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ) : null,
        ),
      ),
    );
  }

/*
  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: agreeToTerms,
          activeColor: const Color(0xFFFF8A00),
          onChanged: (value) {
            setState(() {
              agreeToTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                agreeToTerms = !agreeToTerms;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                t('terms'),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
*/
  
  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: rememberMe,
          activeColor: const Color(0xFFFF8A00),
          onChanged: (value) {
            setState(() {
              rememberMe = value ?? false;
            });
          },
        ),
        Text(
          t('remember'),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8A00), Color(0xFFFF6B00)],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8A00).withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                isSignUp ? t('createAccount') : t('signIn'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
        ),
      ),
    );
  }

  
  // Nouveau bouton pour connexion par lien e-mail
  Widget _buildEmailLinkButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _sendEmailLink,
        icon: const Icon(Icons.email_outlined),
        label: Text(t('emailLink')),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF8A00),
          side: const BorderSide(color: Color(0xFFFF8A00)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Message de confirmation d'envoi du lien
  Widget _buildEmailLinkSentMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t('emailLinkSent'),
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }

/*
  Widget _buildForgotPassword() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          // Handle forgot password
        },
        child: Text(
          t('forgotPassword'),
          style: const TextStyle(
            color: Color(0xFFFF8A00),
            fontSize: 15,
          ),
        ),
      ),
    );
  }
*/
  Widget _buildSwitchAuth() {
    return Center( // AJOUTÉ Center
      child: GestureDetector(
        onTap: () => _switchTab(!isSignUp),
        child: RichText(
          textAlign: TextAlign.center, // AJOUTÉ
          text: TextSpan(
            text: isSignUp ? t('haveAccount') : t('noAccount'),
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 15,
            ),
            children: [
              TextSpan(
                text: ' ${isSignUp ? t('signIn') : t('signUp')}',
                style: const TextStyle(
                  color: Color(0xFFFF8A00),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _switchTab(bool signUp) {
    setState(() {
      isSignUp = signUp;
      _emailLinkSent = false; // Reset du statut du lien e-mail
    });
    // Reset form
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    rememberMe = false;
  }

  Future<void> _socialLogin(String provider) async {
    if (provider == 'google') {
      await _handleGoogleSignIn();
    } else {
      // Facebook login à implémenter plus tard
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connexion via $provider - À implémenter'),
          backgroundColor: const Color(0xFFFF8A00),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
      try {
        // Afficher un indicateur de chargement
        setState(() {
          isLoading = true;
        });

        final googleAuthService = Provider.of<GoogleAuthService>(context, listen: false);
        final userCredential = await googleAuthService.signInWithGoogle();

        if (userCredential != null) {

          final user = userCredential.user!;
          
          // Vérifier si c'est un nouvel utilisateur ou si le profil n'est pas complet
          final isNewUser = await googleAuthService.isNewUser(user.uid);
          
          if (isNewUser) {
            // Créer un profil minimal si c'est vraiment nouveau
            if (userCredential.additionalUserInfo?.isNewUser ?? false) {
              await googleAuthService.createMinimalProfile(
                user.uid,
                user.displayName ?? 'Utilisateur',
                user.email!,
              );
            }
          }
          // Connexion réussie
          HapticFeedback.mediumImpact();
          
          if (isNewUser) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => UserProfileSetupScreen(
                  isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
                ),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const MainScreen(),
              ),
            );
          }

          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connexion Google réussie !'),
              backgroundColor: Color(0xFF38b000),
            ),
          );
        }
      } catch (e) {
        // Gestion des erreurs
        print('Erreur Google Sign-In: $e');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // Arrêter l'indicateur de chargement
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }


  // Nouvelle méthode pour envoyer le lien e-mail
  Future<void> _sendEmailLink() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre adresse e-mail'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authService = Provider.of<GoogleAuthService>(context, listen: false);
    final success = await authService.sendSignInLinkToEmail(emailController.text.trim());

    if (success && mounted) {
      setState(() => _emailLinkSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lien d\'authentification envoyé ! Vérifiez votre boîte e-mail.'),
          backgroundColor: Color(0xFF38b000),
        ),
      );
    }
  }


  // Méthode modifiée pour gérer l'inscription et la connexion
  void _handleSubmit() async {
    // Validation des champs
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs requis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isSignUp && nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre nom'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final authService = Provider.of<GoogleAuthService>(context, listen: false);

try {
    dynamic result;
    bool isNewUser = false;
      
      if (isSignUp) {
        // Inscription - toujours un nouvel utilisateur
        result = await authService.signUpWithEmailPassword(
          emailController.text.trim(),
          passwordController.text,
          nameController.text.trim(),
        );
        
        if (result != null) {
          // Créer un profil minimal
          await authService.createMinimalProfile(
            result.user!.uid,
            nameController.text.trim(),
            emailController.text.trim(),
          );
          isNewUser = true;
        }
      } else {
        // Connexion - vérifier si le profil est complet
        result = await authService.signInWithEmailPassword(
          emailController.text.trim(),
          passwordController.text,
        );
        
        if (result != null) {
          isNewUser = await authService.isNewUser(result.user!.uid);
        }
      }

      if (result != null && mounted) {
            HapticFeedback.mediumImpact();
            
            // Navigation conditionnelle
            if (isNewUser) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => UserProfileSetupScreen(isNewUser: isSignUp),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const MainScreen(),
                ),
              );
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isSignUp 
                    ? 'Compte créé avec succès !' 
                    : 'Connexion réussie !',
                ),
                backgroundColor: const Color(0xFF38b000),
              ),
            );
         }
        } catch (e) {
          print('Erreur authentification: $e');
        } finally {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
     }
   }