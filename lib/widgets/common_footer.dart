import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_notifier.dart';
import '../styles/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommonFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CommonFooter({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  void _showPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Theme(
              data: Theme.of(context),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // const Text("Settings",
                    //     style: TextStyle(
                    //         fontSize: 20,
                    //         fontWeight: FontWeight.bold,
                    //         color: AppColors.primaryColor)),
                    const SizedBox(height: 10),
                    const Text(
                      'Create Connection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(Icons.add_circle_outline,
                          color: Colors.blueAccent, size: 28),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(anim1),
          child: child,
        );
      },
    );
  }

  void _createConnection(context) {
    Navigator.pushNamed(context, '/createConnection');
  }

  void _showCreateConnectionPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 200,
            child: Center( // Center horizontally
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _createConnection(context);
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.add_circle_outline,
                            size: 36, color: Colors.blueAccent),
                        SizedBox(height: 12),
                        Text(
                          'Create Connection',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isSelected
        ? (isDark ? Colors.black87 : Colors.black87)
        : Colors.black87;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(height: 2),
              // Text(
              //   label,
              //   style: TextStyle(
              //     color: iconColor,
              //     fontSize: 18,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeItem(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.black87 : Colors.black87;

    return Expanded(
      child: InkWell(
        onTap: () => themeNotifier.toggleTheme(),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.brightness_6, color: iconColor),
              const SizedBox(height: 2),
              Text(
                'Theme',
                style: TextStyle(fontSize: 12, color: iconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildNavItem(
            context: context,
            icon: FontAwesomeIcons.house,
            label: '',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _buildNavItem(
            context: context,
            icon: FontAwesomeIcons.gear,
            label: '',
            isSelected: currentIndex == 1,
            onTap: () =>
                // onTap(0),
                // _showPopup(context),
            _showCreateConnectionPopup(context),
          ),
        ],
      ),
    );
  }
}
