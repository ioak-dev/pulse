import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_notifier.dart';

class CommonFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CommonFooter({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isSelected ? (isDark ? Colors.white : Colors.black87) : Colors.grey;

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
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeItem(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black87;

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
    return BottomAppBar(
      child: Row(
        children: [
          _buildNavItem(
            context: context,
            icon: Icons.home,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.settings,
            label: 'Settings',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _buildThemeItem(context),
        ],
      ),
    );
  }
}
