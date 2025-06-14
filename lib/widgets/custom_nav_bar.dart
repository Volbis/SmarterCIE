import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65, // ✅ Réduit de 70 à 65px
      margin: const EdgeInsets.all(10), // ✅ Réduit de 12 à 10px
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // ✅ Réduit de 22 à 20px
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A65).withOpacity(0.15),
            blurRadius: 15, // ✅ Réduit de 18 à 15px
            offset: const Offset(0, 5), // ✅ Réduit de 6 à 5px
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6, // ✅ Réduit de 8 à 6px
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20), // ✅ Ajusté
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              index: 0,
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              icon: Icons.notification_important_rounded,
              label: 'Alertes',
              index: 1,
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              icon: Icons.auto_awesome_rounded,
              label: 'ChatBot',
              index: 2,
              isSelected: currentIndex == 2,
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              index: 3,
              isSelected: currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8), // ✅ Réduit de 10 à 8px
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 244, 132, 98), // Orange très soft
                      Color.fromARGB(255, 250, 114, 73), // Orange soft
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(16), // ✅ Réduit de 18 à 16px
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône avec animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(isSelected ? 5 : 4), 
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected 
                      ? Colors.white 
                      : const Color(0xFFFF8A65),
                  size: isSelected ? 22 : 20, 
                ),
              ),
              const SizedBox(height: 2), 
              // Label avec animation
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : const Color(0xFFBDBDBD),
                  fontSize: isSelected ? 9 : 8, // ✅ Réduit de 10:9 à 9:8px
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Version alternative avec des bulles flottantes
class FloatingBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF3E0), 
            Color(0xFFFFE0B2), 
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: const Color(0xFFFFAB91).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A65).withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFloatingItem(Icons.home_rounded, 0),
          _buildFloatingItem(Icons.bar_chart_rounded, 1),
          _buildFloatingItem(Icons.notifications_active_rounded, 2),
          _buildFloatingItem(Icons.account_circle_rounded, 3),
        ],
      ),
    );
  }

  Widget _buildFloatingItem(IconData icon, int index) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.elasticOut,
        width: isSelected ? 55 : 45,
        height: isSelected ? 55 : 45,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFFF8A65),
                    Color(0xFFFF7043),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.6),
                  ],
                ),
          borderRadius: BorderRadius.circular(27.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF8A65).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Icon(
          icon,
          color: isSelected 
              ? Colors.white 
              : const Color(0xFFFF8A65),
          size: isSelected ? 26 : 22,
        ),
      ),
    );
  }
}

// Version avec effet de vague (très originale)
class WaveBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const WaveBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Barre principale
        Container(
          height: 75,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8A65).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWaveItem(Icons.dashboard_customize_rounded, 'Home', 0),
              _buildWaveItem(Icons.insights_rounded, 'Stats', 1),
              _buildWaveItem(Icons.notifications_none_rounded, 'Alerts', 2),
              _buildWaveItem(Icons.person_outline_rounded, 'Profile', 3),
            ],
          ),
        ),
        // Indicateur de sélection (bulle flottante)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          left: 16 + (MediaQuery.of(context).size.width - 32) / 4 * currentIndex + 
                (MediaQuery.of(context).size.width - 32) / 8 - 25,
          top: -5,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFAB91),
                  Color(0xFFFF8A65),
                  Color(0xFFFF7043),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8A65).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.circle,
              color: Colors.white,
              size: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaveItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                color: isSelected 
                    ? const Color(0xFFFF8A65)
                    : const Color(0xFFBDBDBD),
                size: isSelected ? 26 : 22,
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected 
                    ? const Color(0xFFFF8A65)
                    : const Color(0xFFBDBDBD),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}