import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An improved interactive visualization of the Solar System
/// Features 3D-like perspective with better planet graphics
class SimpleSolarSystemScreen extends StatefulWidget {
  const SimpleSolarSystemScreen({super.key});

  @override
  State<SimpleSolarSystemScreen> createState() =>
      _SimpleSolarSystemScreenState();
}

class _SimpleSolarSystemScreenState extends State<SimpleSolarSystemScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _rotationController;
  String? _selectedPlanet;
  double _zoomLevel = 1.0;
  double _viewAngle =
      0.3; // Tilt for 3D perspective (0 = top-down, 1 = edge-on)

  final List<PlanetData> _planets = [
    PlanetData(
      name: 'Mercury',
      colors: [
        const Color(0xFFB8B8B8),
        const Color(0xFF8C8C8C),
        const Color(0xFF5A5A5A)
      ],
      orbitRadius: 0.10,
      size: 8,
      orbitalPeriod: 88,
      description: 'Smallest planet, closest to the Sun',
      rotationSpeed: 1.0,
    ),
    PlanetData(
      name: 'Venus',
      colors: [
        const Color(0xFFF5E6C8),
        const Color(0xFFE6C87A),
        const Color(0xFFD4A84A)
      ],
      orbitRadius: 0.16,
      size: 14,
      orbitalPeriod: 225,
      description: 'Hottest planet with thick atmosphere',
      rotationSpeed: -0.5, // Retrograde rotation
    ),
    PlanetData(
      name: 'Earth',
      colors: [
        const Color(0xFF87CEEB),
        const Color(0xFF4A90D9),
        const Color(0xFF2E5A8B)
      ],
      orbitRadius: 0.24,
      size: 15,
      orbitalPeriod: 365,
      description: 'Our home - the Blue Marble',
      rotationSpeed: 1.0,
      hasMoon: true,
    ),
    PlanetData(
      name: 'Mars',
      colors: [
        const Color(0xFFE8A07A),
        const Color(0xFFD9534F),
        const Color(0xFFB03A30)
      ],
      orbitRadius: 0.32,
      size: 10,
      orbitalPeriod: 687,
      description: 'The Red Planet with largest volcano',
      rotationSpeed: 1.0,
    ),
    PlanetData(
      name: 'Jupiter',
      colors: [
        const Color(0xFFF5DEB3),
        const Color(0xFFD4A373),
        const Color(0xFFB8860B)
      ],
      orbitRadius: 0.46,
      size: 40,
      orbitalPeriod: 4333,
      description: 'Largest planet with Great Red Spot',
      rotationSpeed: 2.5,
      hasBands: true,
    ),
    PlanetData(
      name: 'Saturn',
      colors: [
        const Color(0xFFF5E6C8),
        const Color(0xFFF0D58C),
        const Color(0xFFD4A84A)
      ],
      orbitRadius: 0.60,
      size: 34,
      orbitalPeriod: 10759,
      description: 'Famous for its beautiful rings',
      rotationSpeed: 2.3,
      hasRings: true,
    ),
    PlanetData(
      name: 'Uranus',
      colors: [
        const Color(0xFFAFEEEE),
        const Color(0xFF7EC8E3),
        const Color(0xFF5DADE2)
      ],
      orbitRadius: 0.74,
      size: 22,
      orbitalPeriod: 30687,
      description: 'Ice giant tilted on its side',
      rotationSpeed: -1.4, // Retrograde
      hasRings: true,
      ringOpacity: 0.3,
    ),
    PlanetData(
      name: 'Neptune',
      colors: [
        const Color(0xFF6495ED),
        const Color(0xFF4169E1),
        const Color(0xFF0000CD)
      ],
      orbitRadius: 0.88,
      size: 21,
      orbitalPeriod: 60190,
      description: 'Windiest planet, deep blue color',
      rotationSpeed: 1.5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Solar System'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF0D0D1A),
              Color(0xFF000005),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background stars with depth
            CustomPaint(
              size: Size.infinite,
              painter:
                  DeepStarfieldPainter(animationValue: _orbitController.value),
            ),

            // Solar System View
            Center(
              child: GestureDetector(
                onScaleUpdate: (details) {
                  setState(() {
                    _zoomLevel = (_zoomLevel * details.scale).clamp(0.5, 2.5);
                  });
                },
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _viewAngle =
                        (_viewAngle + details.delta.dy * 0.003).clamp(0.1, 0.7);
                  });
                },
                child: AnimatedBuilder(
                  animation:
                      Listenable.merge([_orbitController, _rotationController]),
                  builder: (context, child) {
                    return CustomPaint(
                      size: MediaQuery.of(context).size,
                      painter: SolarSystemPainter(
                        planets: _planets,
                        animationValue: _orbitController.value,
                        rotationValue: _rotationController.value,
                        zoomLevel: _zoomLevel,
                        viewAngle: _viewAngle,
                        selectedPlanet: _selectedPlanet,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Touch detector for planets
            Center(
              child: AnimatedBuilder(
                animation: _orbitController,
                builder: (context, child) {
                  return GestureDetector(
                    onTapUp: (details) {
                      _handleTap(
                          details.localPosition, MediaQuery.of(context).size);
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  );
                },
              ),
            ),

            // Planet Info Card
            if (_selectedPlanet != null)
              Positioned(
                bottom: 100,
                left: 16,
                right: 16,
                child: _buildPlanetInfoCard(),
              ),

            // Controls
            Positioned(
              right: 16,
              bottom: _selectedPlanet != null ? 280 : 100,
              child: Column(
                children: [
                  // View angle control
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.threed_rotation,
                            color: Colors.white54, size: 20),
                        RotatedBox(
                          quarterTurns: 3,
                          child: SizedBox(
                            width: 80,
                            child: Slider(
                              value: _viewAngle,
                              min: 0.1,
                              max: 0.7,
                              onChanged: (value) {
                                setState(() {
                                  _viewAngle = value;
                                });
                              },
                              activeColor: Colors.white54,
                              inactiveColor: Colors.white24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    onPressed: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel * 1.2).clamp(0.5, 2.5);
                      });
                    },
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    onPressed: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel / 1.2).clamp(0.5, 2.5);
                      });
                    },
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Legend
            Positioned(
              top: 100,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, color: Colors.white54, size: 16),
                        SizedBox(width: 6),
                        Text('Tap planet',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.swipe_vertical,
                            color: Colors.white54, size: 16),
                        SizedBox(width: 6),
                        Text('Drag to tilt',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pinch, color: Colors.white54, size: 16),
                        SizedBox(width: 6),
                        Text('Pinch to zoom',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset tapPosition, Size screenSize) {
    final center = Offset(screenSize.width / 2, screenSize.height / 2);
    final maxRadius =
        math.min(screenSize.width, screenSize.height) * 0.42 * _zoomLevel;

    for (final planet in _planets) {
      final angle =
          _orbitController.value * 2 * math.pi * (365 / planet.orbitalPeriod);
      final orbitRadius = maxRadius * planet.orbitRadius;

      // Apply perspective
      final x = orbitRadius * math.cos(angle);
      final y = orbitRadius * math.sin(angle) * _viewAngle;

      final planetCenter = Offset(
        center.dx + x,
        center.dy + y,
      );

      final distance = (tapPosition - planetCenter).distance;
      if (distance < planet.size * _zoomLevel + 20) {
        setState(() {
          _selectedPlanet = _selectedPlanet == planet.name ? null : planet.name;
        });
        return;
      }
    }

    if (_selectedPlanet != null) {
      setState(() {
        _selectedPlanet = null;
      });
    }
  }

  Widget _buildPlanetInfoCard() {
    final planet = _planets.firstWhere((p) => p.name == _selectedPlanet);

    return Card(
      color: Colors.black.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: planet.colors[1].withOpacity(0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Planet sphere preview
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.3),
                      colors: planet.colors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: planet.colors[1].withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planet.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: planet.colors[0],
                        ),
                      ),
                      Text(
                        planet.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () {
                    setState(() {
                      _selectedPlanet = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Orbit Period', '${planet.orbitalPeriod} days'),
                _buildStatItem(
                    'Position', '${_planets.indexOf(planet) + 1} from Sun'),
                if (planet.hasRings) _buildStatItem('Rings', 'Yes'),
                if (planet.hasMoon) _buildStatItem('Moon', 'Yes'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                      context, '/planet/${planet.name.toLowerCase()}');
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('View Full Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: planet.colors[1].withOpacity(0.3),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Solar System Explorer',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'An interactive 3D view of our solar system with realistic orbital periods.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            _buildHelpItem(Icons.touch_app, 'Tap a planet for details'),
            _buildHelpItem(Icons.pinch, 'Pinch or use buttons to zoom'),
            _buildHelpItem(
                Icons.swipe_vertical, 'Drag vertically to change view angle'),
            _buildHelpItem(
                Icons.animation, 'Orbits animate in real-time ratio'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

class PlanetData {
  final String name;
  final List<Color> colors;
  final double orbitRadius;
  final double size;
  final int orbitalPeriod;
  final String description;
  final double rotationSpeed;
  final bool hasRings;
  final bool hasMoon;
  final bool hasBands;
  final double ringOpacity;

  PlanetData({
    required this.name,
    required this.colors,
    required this.orbitRadius,
    required this.size,
    required this.orbitalPeriod,
    required this.description,
    required this.rotationSpeed,
    this.hasRings = false,
    this.hasMoon = false,
    this.hasBands = false,
    this.ringOpacity = 0.6,
  });
}

class SolarSystemPainter extends CustomPainter {
  final List<PlanetData> planets;
  final double animationValue;
  final double rotationValue;
  final double zoomLevel;
  final double viewAngle;
  final String? selectedPlanet;

  SolarSystemPainter({
    required this.planets,
    required this.animationValue,
    required this.rotationValue,
    required this.zoomLevel,
    required this.viewAngle,
    this.selectedPlanet,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.42 * zoomLevel;

    // Draw the Sun with corona effect
    _drawSun(canvas, center);

    // Sort planets by Y position for proper depth ordering
    final sortedPlanets = List<MapEntry<PlanetData, double>>.generate(
      planets.length,
      (i) {
        final planet = planets[i];
        final angle =
            animationValue * 2 * math.pi * (365 / planet.orbitalPeriod);
        final y = math.sin(angle);
        return MapEntry(planet, y);
      },
    )..sort((a, b) => a.value.compareTo(b.value));

    // Draw orbits first
    for (final planet in planets) {
      final orbitRadius = maxRadius * planet.orbitRadius;
      _drawOrbit(canvas, center, orbitRadius);
    }

    // Draw planets in depth order
    for (final entry in sortedPlanets) {
      final planet = entry.key;
      final orbitRadius = maxRadius * planet.orbitRadius;
      final angle = animationValue * 2 * math.pi * (365 / planet.orbitalPeriod);

      final x = orbitRadius * math.cos(angle);
      final y = orbitRadius * math.sin(angle) * viewAngle;
      final planetCenter = Offset(center.dx + x, center.dy + y);

      // Size varies slightly with depth for 3D effect
      final depthScale = 0.9 + (math.sin(angle) + 1) * 0.05;
      final planetRadius = (planet.size * zoomLevel * depthScale) / 2;

      _drawPlanet(canvas, planet, planetCenter, planetRadius, angle);
    }
  }

  void _drawSun(Canvas canvas, Offset center) {
    // Corona layers
    for (int i = 5; i > 0; i--) {
      final coronaPaint = Paint()
        ..color = Colors.orange.withOpacity(0.1 / i)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 * i * zoomLevel);
      canvas.drawCircle(
          center, 30 * zoomLevel + i * 8 * zoomLevel, coronaPaint);
    }

    // Sun gradient
    final sunPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Colors.yellow.shade100,
          Colors.yellow,
          Colors.orange,
          Colors.deepOrange,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 30 * zoomLevel));

    canvas.drawCircle(center, 30 * zoomLevel, sunPaint);

    // Sun surface texture
    final random = math.Random(42);
    final texturePaint = Paint()..color = Colors.orange.withOpacity(0.3);
    for (int i = 0; i < 8; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final r = random.nextDouble() * 20 * zoomLevel;
      final spotCenter =
          center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      canvas.drawCircle(spotCenter, 3 * zoomLevel, texturePaint);
    }
  }

  void _drawOrbit(Canvas canvas, Offset center, double radius) {
    final orbitPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw ellipse for 3D perspective
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius * 2 * viewAngle,
      ),
      orbitPaint,
    );
  }

  void _drawPlanet(Canvas canvas, PlanetData planet, Offset center,
      double radius, double orbitAngle) {
    // Selection glow
    if (planet.name == selectedPlanet) {
      final glowPaint = Paint()
        ..color = planet.colors[1].withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(center, radius * 1.5, glowPaint);
    }

    // Draw rings behind planet (for Saturn/Uranus)
    if (planet.hasRings && math.sin(orbitAngle) > 0) {
      _drawRings(canvas, planet, center, radius);
    }

    // Planet sphere with lighting
    final planetPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 1.0,
        colors: planet.colors,
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, planetPaint);

    // Jupiter bands
    if (planet.hasBands) {
      _drawJupiterBands(canvas, center, radius);
    }

    // Specular highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      center + Offset(-radius * 0.3, -radius * 0.3),
      radius * 0.25,
      highlightPaint,
    );

    // Draw rings in front of planet
    if (planet.hasRings && math.sin(orbitAngle) <= 0) {
      _drawRings(canvas, planet, center, radius);
    }

    // Earth's moon
    if (planet.hasMoon) {
      final moonAngle =
          animationValue * 2 * math.pi * 13; // Moon orbits ~13 times per year
      final moonDistance = radius * 2;
      final moonCenter = center +
          Offset(
            math.cos(moonAngle) * moonDistance,
            math.sin(moonAngle) * moonDistance * 0.5,
          );

      final moonPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade500,
            Colors.grey.shade700
          ],
        ).createShader(
            Rect.fromCircle(center: moonCenter, radius: radius * 0.25));

      canvas.drawCircle(moonCenter, radius * 0.25, moonPaint);
    }
  }

  void _drawRings(
      Canvas canvas, PlanetData planet, Offset center, double radius) {
    for (int i = 0; i < 3; i++) {
      final ringRadius = radius * (1.6 + i * 0.3);
      final ringPaint = Paint()
        ..color = planet.colors[0].withOpacity(planet.ringOpacity - i * 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * zoomLevel - i;

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: ringRadius * 2,
          height: ringRadius * 0.4,
        ),
        ringPaint,
      );
    }
  }

  void _drawJupiterBands(Canvas canvas, Offset center, double radius) {
    final bandPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final bandColors = [
      Colors.orange.shade700.withOpacity(0.3),
      Colors.brown.shade400.withOpacity(0.3),
      Colors.orange.shade600.withOpacity(0.3),
    ];

    for (int i = 0; i < 3; i++) {
      bandPaint.color = bandColors[i % bandColors.length];
      final yOffset = (i - 1) * radius * 0.35;
      canvas.drawArc(
        Rect.fromCenter(
          center: center + Offset(0, yOffset),
          width: radius * 1.8,
          height: radius * 0.3,
        ),
        0,
        math.pi,
        false,
        bandPaint,
      );
    }

    // Great Red Spot
    final spotPaint = Paint()..color = Colors.red.shade700.withOpacity(0.6);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(radius * 0.3, radius * 0.2),
        width: radius * 0.4,
        height: radius * 0.25,
      ),
      spotPaint,
    );
  }

  @override
  bool shouldRepaint(SolarSystemPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.rotationValue != rotationValue ||
        oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.viewAngle != viewAngle ||
        oldDelegate.selectedPlanet != selectedPlanet;
  }
}

class DeepStarfieldPainter extends CustomPainter {
  final double animationValue;
  final _random = math.Random(42);

  DeepStarfieldPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Far stars (small, dim)
    for (int i = 0; i < 200; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final radius = _random.nextDouble() * 0.8 + 0.3;
      final opacity = _random.nextDouble() * 0.4 + 0.1;

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Medium stars
    for (int i = 0; i < 50; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final radius = _random.nextDouble() * 1.2 + 0.8;
      final twinkle = (math.sin(animationValue * 2 * math.pi * 3 + i) + 1) / 2;
      final opacity = 0.3 + twinkle * 0.4;

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Bright stars with glow
    for (int i = 0; i < 15; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final twinkle =
          (math.sin(animationValue * 2 * math.pi * 2 + i * 0.5) + 1) / 2;

      // Glow
      paint.color = Colors.white.withOpacity(0.1 + twinkle * 0.1);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), 4, paint);

      // Core
      paint.color = Colors.white.withOpacity(0.6 + twinkle * 0.4);
      paint.maskFilter = null;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(DeepStarfieldPainter oldDelegate) => true;
}
