import 'package:flutter/material.dart';
import '../../apod/presentation/apod_screen.dart';
import '../../planets/presentation/planet_list_screen.dart';
import '../../constellations/presentation/constellation_list_screen.dart';

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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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
            icon: Icon(Icons.star),
            label: 'Constellations',
          ),
        ],
      ),
    );
  }
}
