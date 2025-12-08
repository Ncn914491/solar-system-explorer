import 'package:flutter/material.dart';
import '../../../core/models/space_objects_model.dart';
import '../../../core/services/space_objects_service.dart';

class EncyclopediaScreen extends StatefulWidget {
  final int initialTabIndex;
  const EncyclopediaScreen({super.key, this.initialTabIndex = 0});

  @override
  State<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends State<EncyclopediaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SpaceObjectsService _service = SpaceObjectsService();

  final List<_CategoryData> _categories = [
    _CategoryData('Asteroids', Icons.radio_button_unchecked, const Color(0xFF8B7355)),
    _CategoryData('Comets', Icons.star_outline, const Color(0xFF87CEEB)),
    _CategoryData('Black Holes', Icons.lens, const Color(0xFF4A0E4E)),
    _CategoryData('Meteors', Icons.grain, const Color(0xFFFF6B35)),
    _CategoryData('Stars', Icons.sunny, const Color(0xFFFFD700)),
    _CategoryData('Deep Sky', Icons.blur_on, const Color(0xFFFF69B4)),
    _CategoryData('Exotic', Icons.science, const Color(0xFF00FA9A)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Space Encyclopedia'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          tabs: _categories.map((c) => Tab(
            icon: Icon(c.icon, color: c.color),
            text: c.name,
          )).toList(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
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
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _AsteroidsTab(service: _service),
              _CometsTab(service: _service),
              _BlackHolesTab(service: _service),
              _MeteorShowersTab(service: _service),
              _StarsTab(service: _service),
              _DeepSkyTab(service: _service),
              _ExoticObjectsTab(service: _service),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  _CategoryData(this.name, this.icon, this.color);
}

// ... EXISTING TABS ...
// To save context, I will include all tabs but optimized for keeping file size reasonable if possible,
// but since I'm overwriting, I need to include EVERYTHING.

// Asteroids Tab
class _AsteroidsTab extends StatelessWidget {
  final SpaceObjectsService service;
  const _AsteroidsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Asteroid>>(
      future: service.getAllAsteroids(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No asteroids found', style: TextStyle(color: Colors.white70)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final asteroid = snapshot.data![index];
            return _SpaceObjectCard(
              name: asteroid.name,
              subtitle: '${asteroid.type} • ${asteroid.diameterKm} km',
              description: asteroid.description,
              color: const Color(0xFF8B7355),
              icon: Icons.radio_button_unchecked,
              onTap: () => _showDetail(context, asteroid.name, const Color(0xFF8B7355), Icons.radio_button_unchecked, asteroid.description, {
                'Type': asteroid.type,
                'Diameter': '${asteroid.diameterKm} km',
                'Orbit': asteroid.orbitType,
                'Period': '${asteroid.orbitalPeriodYears} years',
                'Distance': '${asteroid.distanceFromSunAU} AU',
              }, asteroid.funFacts),
            );
          },
        );
      },
    );
  }
}

// Comets Tab
class _CometsTab extends StatelessWidget {
  final SpaceObjectsService service;
  const _CometsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Comet>>(
      future: service.getAllComets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No comets found', style: TextStyle(color: Colors.white70)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final comet = snapshot.data![index];
            return _SpaceObjectCard(
              name: comet.name,
              subtitle: '${comet.officialName} • ${comet.orbitalPeriodYears} years',
              description: comet.description,
              color: const Color(0xFF87CEEB),
              icon: Icons.star_outline,
              onTap: () => _showDetail(context, comet.name, const Color(0xFF87CEEB), Icons.star_outline, comet.description, {
                'Official Name': comet.officialName,
                'Type': comet.type,
                'Nucleus': '${comet.nucleusDiameterKm} km',
                'Period': '${comet.orbitalPeriodYears} years',
                'Perihelion': '${comet.perihelionAU} AU',
              }, comet.funFacts),
            );
          },
        );
      },
    );
  }
}

// Black Holes Tab
class _BlackHolesTab extends StatelessWidget {
  final SpaceObjectsService service;
  const _BlackHolesTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BlackHole>>(
      future: service.getAllBlackHoles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No black holes found', style: TextStyle(color: Colors.white70)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final bh = snapshot.data![index];
            return _SpaceObjectCard(
              name: bh.name,
              subtitle: '${bh.type} • ${bh.location}',
              description: bh.description,
              color: const Color(0xFF4A0E4E),
              icon: Icons.lens,
              onTap: () => _showDetail(context, bh.name, const Color(0xFF4A0E4E), Icons.lens, bh.description, {
                'Type': bh.type,
                'Mass': '${bh.massInSolarMasses} Suns',
                'Distance': '${bh.distanceLightYears} ly',
                'Location': bh.location,
              }, bh.funFacts),
            );
          },
        );
      },
    );
  }
}

// Meteor Showers Tab
class _MeteorShowersTab extends StatelessWidget {
  final SpaceObjectsService service;
  const _MeteorShowersTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MeteorShower>>(
      future: service.getAllMeteorShowers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No meteor showers found', style: TextStyle(color: Colors.white70)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final shower = snapshot.data![index];
            return _SpaceObjectCard(
              name: shower.name,
              subtitle: '${shower.peakDate} • ZHR: ${shower.zenithalHourlyRate}',
              description: shower.description,
              color: const Color(0xFFFF6B35),
              icon: Icons.grain,
              onTap: () => _showDetail(context, shower.name, const Color(0xFFFF6B35), Icons.grain, shower.description, {
                'Peak Date': shower.peakDate,
                'Activity': '${shower.activeStart} - ${shower.activeEnd}',
                'ZHR': '${shower.zenithalHourlyRate}/hr',
                'Parent': shower.parentBody,
                'Radiant': shower.radiantConstellation,
              }, shower.funFacts),
            );
          },
        );
      },
    );
  }
}

// Stars Tab
class _StarsTab extends StatelessWidget {
  final SpaceObjectsService service;
  const _StarsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Star>>(
      future: service.getAllStars(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No stars found', style: TextStyle(color: Colors.white70)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final star = snapshot.data![index];
            return _SpaceObjectCard(
              name: star.name,
              subtitle: '${star.type} • ${star.constellation}',
              description: star.description,
              color: const Color(0xFFFFD700),
              icon: Icons.sunny,
              onTap: () => _showDetail(context, star.name, const Color(0xFFFFD700), Icons.sunny, star.description, {
                'Type': star.type,
                'Constellation': star.constellation,
                'Distance': star.distance,
                'Mass': star.mass,
                'Radius': star.radius,
              }, star.funFacts),
            );
          },
        );
      },
    );
  }
}

// Deep Sky Tab
class _DeepSkyTab extends StatelessWidget {
  final SpaceObjectsService service;
  const _DeepSkyTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DeepSkyObject>>(
      future: service.getAllDeepSkyObjects(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No deep sky objects found', style: TextStyle(color: Colors.white70)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final obj = snapshot.data![index];
            return _SpaceObjectCard(
              name: obj.name,
              subtitle: '${obj.type} • ${obj.constellation}',
              description: obj.description,
              color: const Color(0xFFFF69B4),
              icon: Icons.blur_on,
              onTap: () => _showDetail(context, obj.name, const Color(0xFFFF69B4), Icons.blur_on, obj.description, {
                'Type': obj.type,
                'Constellation': obj.constellation,
                'Distance': obj.distance,
              }, obj.funFacts),
            );
          },
        );
      },
    );
  }
}

// Exotic Objects Tab
class _ExoticObjectsTab extends StatelessWidget {
  final SpaceObjectsService service;
  const _ExoticObjectsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExoticObject>>(
      future: service.getAllExoticObjects(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No exotic objects found', style: TextStyle(color: Colors.white70)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final obj = snapshot.data![index];
            return _SpaceObjectCard(
              name: obj.name,
              subtitle: obj.type,
              description: obj.description,
              color: const Color(0xFF00FA9A),
              icon: Icons.science,
              onTap: () => _showDetail(context, obj.name, const Color(0xFF00FA9A), Icons.science, obj.description, {
                'Type': obj.type,
                'Mass': obj.mass,
                'Distance': obj.distance,
              }, obj.funFacts),
            );
          },
        );
      },
    );
  }
}

// Helper to show detail screen
void _showDetail(BuildContext context, String name, Color color, IconData icon, String description, Map<String, String> properties, List<String> funFacts) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _ObjectDetailScreen(
        name: name,
        color: color,
        icon: icon,
        description: description,
        properties: properties,
        funFacts: funFacts,
      ),
    ),
  );
}

// Reusable Card Widget
class _SpaceObjectCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String description;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _SpaceObjectCard({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.08),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}

// Object Detail Screen
class _ObjectDetailScreen extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;
  final String description;
  final Map<String, String> properties;
  final List<String> funFacts;

  const _ObjectDetailScreen({
    required this.name,
    required this.color,
    required this.icon,
    required this.description,
    required this.properties,
    required this.funFacts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.2),
              const Color(0xFF0A0E27),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.3),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: 50),
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  'About',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Properties
                Text(
                  'Properties',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: properties.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 140,
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Fun Facts
                if (funFacts.isNotEmpty) ...[
                  Text(
                    'Fun Facts',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...funFacts.map((fact) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fact,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
