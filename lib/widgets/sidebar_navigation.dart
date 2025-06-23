import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? const LinearGradient(
            colors: [
              Color(0xFF2D224C),
              Color(0xFF3B2F5C),
              Color(0xFF1A1333),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : AppTheme.primaryGradient;
    final textColor = isDark ? Colors.white : Colors.white;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.white70;
    final selectedColor = isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.2);
    final borderColor = isDark ? Colors.white.withOpacity(0.18) : Colors.white.withOpacity(0.3);
    final dividerColor = isDark ? Colors.white24 : Colors.white24;
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: gradient,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, textColor, secondaryTextColor),
          const SizedBox(height: 20),
          Flexible(
            child: _buildNavigationItems(context, textColor, secondaryTextColor, selectedColor, borderColor),
          ),
          _buildFooter(context, textColor, secondaryTextColor, dividerColor),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.security,
              size: 40,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Fraud Detector',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AI Smart Monitoring Kit',
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context, Color textColor, Color secondaryTextColor, Color selectedColor, Color borderColor) {
    final items = [
      _NavigationItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        route: '/dashboard',
        index: 0,
      ),
      _NavigationItem(
        icon: Icons.receipt_long,
        title: 'Transactions',
        route: '/transactions',
        index: 1,
      ),
      _NavigationItem(
        icon: Icons.warning,
        title: 'Suspicious Transactions',
        route: '/suspicious-transactions',
        index: 2,
      ),
      _NavigationItem(
        icon: Icons.people,
        title: 'Users',
        route: '/users',
        index: 3,
      ),
      _NavigationItem(
        icon: Icons.person,
        title: 'Profile',
        route: '/profile',
        index: 4,
      ),
      _NavigationItem(
        icon: Icons.dns,
        title: 'Systems',
        route: '/systems',
        index: 5,
      ),
      _NavigationItem(
        icon: Icons.api,
        title: 'API',
        route: '/api',
        index: 6,
      ),
      _NavigationItem(
        icon: Icons.settings,
        title: 'Settings',
        route: '/settings',
        index: 7,
      ),
    ];
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        itemCount: items.length,
        separatorBuilder: (context, i) => const SizedBox(height: 8),
        itemBuilder: (context, i) => _buildNavigationItem(context, items[i], textColor, secondaryTextColor, selectedColor, borderColor),
      ),
    );
  }

  Widget _buildNavigationItem(BuildContext context, _NavigationItem item, Color textColor, Color secondaryTextColor, Color selectedColor, Color borderColor) {
    final isSelected = selectedIndex == item.index;
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onItemSelected(item.index);
            Navigator.pushNamed(context, item.route);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: borderColor)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? textColor : secondaryTextColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected ? textColor : secondaryTextColor,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (item.badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Color textColor, Color secondaryTextColor, Color dividerColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Divider(color: dividerColor),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.person,
                  color: textColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin User',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'admin@fraudbuster.com',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                foregroundColor: textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(Icons.logout, color: textColor),
              label: Text('Log Out', style: TextStyle(color: textColor)),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String title;
  final String route;
  final int index;
  final String? badge;

  _NavigationItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.index,
    this.badge,
  });
} 