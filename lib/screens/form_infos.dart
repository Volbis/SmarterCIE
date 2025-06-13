import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeter_app/models/user_profile.dart';
import '../services/auth_services/auth_service.dart';
import '../services/firestore_service.dart'; 
import '../main.dart';

class UserProfileSetupScreen extends StatefulWidget {
  final bool isNewUser;
  
  const UserProfileSetupScreen({
    Key? key,
    this.isNewUser = true,
  }) : super(key: key);

  @override
  State<UserProfileSetupScreen> createState() => _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState extends State<UserProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers pour les champs
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _otherConsumptionController = TextEditingController();
  final TextEditingController _meterNumberController = TextEditingController(); // 🆕 NOUVEAU
  final TextEditingController _customBillController = TextEditingController(); // 🆕 NOUVEAU

  // Variables pour les sélections
  String _selectedHouseholdSize = '';
  String _selectedConsumption = '';
  String _selectedProvider = '';
  String _selectedTariff = '';
  String _selectedBillRange = ''; 
  List<String> _selectedAppliances = [];

  // Options prédéfinies
  final List<String> _householdSizes = ['1-2 personnes', '3-4 personnes', '5+ personnes'];
  final List<String> _consumptionRanges = [
    'Moins de 100 kWh/mois',
    '100-200 kWh/mois',
    '200-400 kWh/mois',
    '400+ kWh/mois',
    'Je ne sais pas'
  ];
  
  // 🆕 NOUVEAU - Options pour facture mensuelle
  final List<String> _billRanges = [
    'Moins de 10 000 FCFA',
    '10 000 - 25 000 FCFA',
    '25 000 - 50 000 FCFA',
    '50 000 - 100 000 FCFA',
    '100 000 - 200 000 FCFA',
    'Plus de 200 000 FCFA',
    'Montant personnalisé'
  ];
  
  final List<String> _providers = ['CIE', 'Autre'];
  final List<String> _tariffs = ['Tarif social', 'Tarif normal', 'Tarif industriel'];
  final List<String> _applianceOptions = [
    'Réfrigérateur', 'Climatiseur', 'Machine à laver', 'Télévision',
    'Ordinateur', 'Micro-onde', 'Fer à repasser', 'Ventilateur'
  ];



  // NOUVEAU - Fonction pour calculer le seuil de consommation
  String _calculateConsumptionThreshold(String billRange, String? customAmount) {
    // Si montant personnalisé, l'utiliser directement
    if (billRange == 'Montant personnalisé' && customAmount != null && customAmount.isNotEmpty) {
      try {
        double amount = double.parse(customAmount);
        return amount.toStringAsFixed(0);
      } catch (e) {
        print('❌ Erreur parsing montant personnalisé: $e');
        return '0';
      }
    }
    
    // Calculer la moyenne pour les intervalles prédéfinis
    switch (billRange) {
      case 'Moins de 10 000 FCFA':
        return '5000'; // Moyenne entre 0 et 10 000
      
      case '10 000 - 25 000 FCFA':
        return '17500'; // Moyenne entre 10 000 et 25 000
      
      case '25 000 - 50 000 FCFA':
        return '37500'; // Moyenne entre 25 000 et 50 000
      
      case '50 000 - 100 000 FCFA':
        return '75000'; // Moyenne entre 50 000 et 100 000
      
      case '100 000 - 200 000 FCFA':
        return '150000'; // Moyenne entre 100 000 et 200 000
      
      case 'Plus de 200 000 FCFA':
        return '250000'; // Estimation conservatrice (200k + 50k de marge)
      
      default:
        return '0'; // Valeur par défaut si aucune sélection
    }
  }


  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _otherConsumptionController.dispose();
    _meterNumberController.dispose(); // 🆕 NOUVEAU
    _customBillController.dispose(); // 🆕 NOUVEAU
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(), // Informations de base + numéro compteur
                  _buildStep2(), // Consommation + facture mensuelle
                  _buildStep3(), // Fournisseur et tarif
                  _buildStep4(), // Appareils électriques
                ],
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.all(20),
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 129, 193, 99), Color.fromARGB(255, 81, 198, 27)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 70, 210, 6).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section profil simplifiée
          Row(
            children: [
              // Avatar simple
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Informations utilisateur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration profil',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Personnalisation énergétique',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Indicateur simple
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Description minimaliste
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Colors.white.withOpacity(0.9),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Quelques questions pour optimiser votre expérience',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
} 

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentStep 
                  ? const Color(0xFF38b000) 
                  : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 🆕 ÉTAPE 1 MODIFIÉE - Ajout du numéro de compteur
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations personnelles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _phoneController,
            label: 'Numéro de téléphone',
            hint: '+225 XX XX XX XX XX',
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _addressController,
            label: 'Adresse',
            hint: 'Votre adresse',
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          
          // 🆕 NOUVEAU - Numéro de compteur
          _buildTextField(
            controller: _meterNumberController,
            label: 'Numéro de compteur électrique',
            hint: 'Ex: 123456789012',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Taille du foyer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          
          ..._householdSizes.map((size) => _buildRadioOption(
            size,
            _selectedHouseholdSize,
            (value) => setState(() => _selectedHouseholdSize = value!),
          )),
        ],
      ),
    );
  }

  // 🆕 ÉTAPE 2 MODIFIÉE - Ajout de la facture mensuelle
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consommation électrique',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cela nous aide à mieux estimer vos économies potentielles',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          
          // Consommation en kWh
          const Text(
            'Consommation mensuelle (kWh)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          
          ..._consumptionRanges.map((range) => _buildRadioOption(
            range,
            _selectedConsumption,
            (value) => setState(() => _selectedConsumption = value!),
          )),
          
          if (_selectedConsumption == 'Je ne sais pas') ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _otherConsumptionController,
              label: 'Consommation approximative (kWh)',
              hint: 'Ex: 350',
              keyboardType: TextInputType.number,
            ),
          ],
          
          const SizedBox(height: 30),
          
          // 🆕 NOUVEAU - Facture mensuelle
          const Text(
            'Facture mensuelle (FCFA)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quel est le montant habituel de votre facture d\'électricité ?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 12),
          
          ..._billRanges.map((range) => _buildRadioOption(
            range,
            _selectedBillRange,
            (value) => setState(() => _selectedBillRange = value!),
          )),
          
          if (_selectedBillRange == 'Montant personnalisé') ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _customBillController,
              label: 'Montant mensuel (FCFA)',
              hint: 'Ex: 45000',
              keyboardType: TextInputType.number,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fournisseur d\'électricité',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Votre fournisseur',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          
          ..._providers.map((provider) => _buildRadioOption(
            provider,
            _selectedProvider,
            (value) => setState(() => _selectedProvider = value!),
          )),
          
          const SizedBox(height: 24),
          
          const Text(
            'Type de tarif',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          
          ..._tariffs.map((tariff) => _buildRadioOption(
            tariff,
            _selectedTariff,
            (value) => setState(() => _selectedTariff = value!),
          )),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appareils électriques',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sélectionnez les appareils que vous utilisez régulièrement',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _applianceOptions.length,
              itemBuilder: (context, index) {
                final appliance = _applianceOptions[index];
                final isSelected = _selectedAppliances.contains(appliance);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedAppliances.remove(appliance);
                      } else {
                        _selectedAppliances.add(appliance);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF8A00) : Colors.white,
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFF8A00) : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        appliance,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 MÉTHODE MODIFIÉE - Support pour TextInputType
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType, // 🆕 NOUVEAU
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE1E5E9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF8A00)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String value, String groupValue, ValueChanged<String?> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: groupValue == value ? const Color(0xFFFF8A00).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: groupValue == value ? const Color(0xFFFF8A00) : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFFFF8A00),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: groupValue == value ? const Color(0xFFFF8A00) : const Color(0xFF333333),
                  fontWeight: groupValue == value ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFFF8A00)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  
                  'Précédent',
                  style: TextStyle(color: Color(0xFFFF8A00), fontSize: 16),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _isLoading ? null : (_currentStep == 3 ? _submitProfile : _nextStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A00),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    _currentStep == 3 ? 'Terminer' : 'Suivant',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 🆕 VALIDATION MODIFIÉE
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_selectedHouseholdSize.isEmpty) {
          _showErrorSnackBar('Veuillez sélectionner la taille de votre foyer');
          return false;
        }
        if (_meterNumberController.text.trim().isEmpty) {
          _showErrorSnackBar('Veuillez saisir votre numéro de compteur');
          return false;
        }
        break;
      case 1:
        if (_selectedConsumption.isEmpty) {
          _showErrorSnackBar('Veuillez sélectionner votre consommation');
          return false;
        }
        if (_selectedBillRange.isEmpty) {
          _showErrorSnackBar('Veuillez sélectionner votre fourchette de facture mensuelle');
          return false;
        }
        if (_selectedBillRange == 'Montant personnalisé' && _customBillController.text.trim().isEmpty) {
          _showErrorSnackBar('Veuillez saisir le montant de votre facture');
          return false;
        }
        break;
      case 2:
        if (_selectedProvider.isEmpty || _selectedTariff.isEmpty) {
          _showErrorSnackBar('Veuillez sélectionner votre fournisseur et tarif');
          return false;
        }
        break;
    }
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // 🆕 SOUMISSION MODIFIÉE avec nouveaux champs
  Future<void> _submitProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<GoogleAuthService>(context, listen: false);
      final user = authService.currentUser;
      
      print('🧪 DEBUG: Début soumission profil');
      print('🧪 DEBUG: Utilisateur: ${user?.uid}');
      
      if (user != null) {
        // Calcul de la facture finale avec vérification
        String finalBillAmount = '';
        if (_selectedBillRange == 'Montant personnalisé') {
          finalBillAmount = _customBillController.text.trim();
        } else if (_selectedBillRange.isNotEmpty) {
          finalBillAmount = _selectedBillRange;
        }
        // NOUVEAU - Calcul du seuil de consommation
        String calculatedThreshold = _calculateConsumptionThreshold(
          _selectedBillRange,
          _selectedBillRange == 'Montant personnalisé' ? _customBillController.text.trim() : null,
        );
        
        print('🧪 DEBUG: Facture sélectionnée: $_selectedBillRange');
        print('🧪 DEBUG: Montant personnalisé: ${_customBillController.text}');
        print('🧪 DEBUG: Seuil calculé: $calculatedThreshold');
        
        final profile = UserProfile(
          uid: user.uid!,
          name: user.displayName ?? '',
          email: user.email ?? '',
          phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
          meterNumber: _meterNumberController.text.trim(),
          monthlyBill: finalBillAmount.isNotEmpty ? finalBillAmount : 'Pas renseigné',
          seuille_conso: calculatedThreshold, 
          householdSize: _selectedHouseholdSize,
          averageConsumption: _selectedConsumption == 'Je ne sais pas' 
            ? _otherConsumptionController.text.trim() 
            : _selectedConsumption,
          electricityProvider: _selectedProvider,
          tariffPlan: _selectedTariff,
          appliances: _selectedAppliances,
          profileCompleted: true,
          createdAt: DateTime.now(),
        );

        print('🧪 DEBUG: Profil créé: ${profile.toString()}');
        print('🧪 DEBUG: Numéro compteur: ${profile.meterNumber}');
        print('🧪 DEBUG: Facture mensuelle: ${profile.monthlyBill}');
        print('🧪 DEBUG: Seuil consommation: ${profile.seuille_conso}'); // 🆕 NOUVEAU
        
        await FirestoreService.saveUserProfile(profile);
        
        print('🧪 DEBUG: Profil sauvegardé avec succès');
        
        if (mounted) {
          final testConnection = await FirestoreService.testConnection();
          print('🧪 DEBUG: Test connexion après sauvegarde: $testConnection');
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil complété avec succès !'),
              backgroundColor: Color(0xFF38b000),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Utilisateur non connecté');
      }
    } catch (e, stackTrace) {
      print('❌ ERREUR lors de la sauvegarde: $e');
      print('❌ STACK TRACE: $stackTrace');
      
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la sauvegarde du profil: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

}