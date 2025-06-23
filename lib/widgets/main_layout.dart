import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sidebar_navigation.dart';
import '../providers/theme_provider.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final int currentIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    required this.currentIndex,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 768;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
            });
          },
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar - only show on desktop or when explicitly opened on mobile
          if (!isMobile || _isSidebarOpen)
            SidebarNavigation(
              selectedIndex: widget.currentIndex,
              onItemSelected: (index) {
                if (isMobile) {
                  setState(() {
                    _isSidebarOpen = false;
                  });
                }
              },
            ),
          // Main content
          Expanded(
            child: Stack(
              children: [
                widget.child,
                // Overlay for mobile when sidebar is open
                if (_isSidebarOpen && isMobile)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSidebarOpen = false;
                      });
                    },
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 