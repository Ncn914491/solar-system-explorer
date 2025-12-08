import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/update_checker_service.dart';
import '../../apod/presentation/apod_screen.dart';
import '../../planets/presentation/planet_list_screen.dart';
import '../../constellations/presentation/constellation_list_screen.dart';
import '../../solar_system/presentation/simple_solar_system_screen.dart';
import '../../encyclopedia/presentation/encyclopedia_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ApodScreen(),
    const PlanetListScreen(),
    const ConstellationListScreen(),
    const SimpleSolarSystemScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    final updateService = UpdateCheckerService();
    final updateInfo = await updateService.checkForUpdates();

    if (updateInfo != null && mounted) {
      _showUpdateDialog(updateInfo);
    }
  }

  void _showUpdateDialog(Map<String, dynamic> updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Update Available: v${updateInfo['latestVersion']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('A new version is available!'),
              const SizedBox(height: 8),
              Text('Current: v${updateInfo['currentVersion']}'),
              Text('Latest: v${updateInfo['latestVersion']}'),
              const SizedBox(height: 16),
              const Text('Release Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(updateInfo['releaseNotes'] ?? 'No notes provided.',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUpdateUrl(updateInfo['downloadUrl']);
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUpdateUrl(String? url) async {
    if (url != null) {
      final uri = Uri.parse(url);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      drawer: _buildDrawer(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.photo),
            label: 'APOD',
          ),
          NavigationDestination(
            icon: Icon(Icons.public),
            label: 'Planets',
          ),
          NavigationDestination(
            icon: Icon(Icons.stars),
            label: 'Constellations',
          ),
          NavigationDestination(
            icon: Icon(Icons.solar_power),
            label: 'Solar System',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0E27),
              const Color(0xFF1A1A2E),
              Colors.black.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade900,
                    Colors.indigo.shade900,
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.rocket_launch, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Solar System Explorer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your Space Encyclopedia',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerSection('Main Features'),
            _buildDrawerItem(Icons.photo, 'Picture of the Day', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            }),
            _buildDrawerItem(Icons.public, 'Planets & Moons', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 1);
            }),
            _buildDrawerItem(Icons.stars, 'Constellations', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 2);
            }),
            _buildDrawerItem(Icons.solar_power, 'Solar System View', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            }),
            const Divider(color: Colors.white24),
            _buildDrawerSection('Space Encyclopedia'),
            _buildDrawerItem(
                Icons.radio_button_unchecked, 'Asteroids & Dwarf Planets', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EncyclopediaScreen()),
              );
            }, subtitle: 'Ceres, Vesta, Bennu & more'),
            _buildDrawerItem(Icons.star_outline, 'Comets', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EncyclopediaScreen(initialTabIndex: 1)),
              );
            }, subtitle: 'Halley, NEOWISE & more'),
            _buildDrawerItem(Icons.lens, 'Black Holes', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EncyclopediaScreen(initialTabIndex: 2)),
              );
            }, subtitle: 'Sagittarius A*, M87* & more'),
            _buildDrawerItem(Icons.grain, 'Meteor Showers', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EncyclopediaScreen(initialTabIndex: 3)),
              );
            }, subtitle: 'Perseids, Geminids & more'),
            _buildDrawerItem(Icons.sunny, 'Stars', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EncyclopediaScreen(initialTabIndex: 4)),
              );
            }, subtitle: 'Sun, Betelgeuse, UY Scuti'),
            _buildDrawerItem(Icons.blur_on, 'Deep Sky Objects', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EncyclopediaScreen(initialTabIndex: 5)),
              );
            }, subtitle: 'Nebulae, Galaxies & Clusters'),
            _buildDrawerItem(Icons.science, 'Exotic / Theoretical', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EncyclopediaScreen(initialTabIndex: 6)),
              );
            }, subtitle: 'Wormholes, White Holes, Neutron Stars'),
            const Divider(color: Colors.white24),
            _buildDrawerItem(Icons.info_outline, 'About', () {
              Navigator.pop(context);
              _showAboutDialog();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap,
      {String? subtitle}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12))
          : null,
      onTap: onTap,
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Solar System Explorer',
      applicationVersion: '1.0.0',
      applicationIcon:
          const Icon(Icons.rocket_launch, size: 48, color: Colors.deepPurple),
      children: [
        const Text('Your comprehensive guide to the cosmos.'),
        const SizedBox(height: 8),
        const Text(
            'Features NASA\'s Astronomy Picture of the Day, detailed planet and moon information, constellation guides, and a space encyclopedia.'),
      ],
    );
  }
}
