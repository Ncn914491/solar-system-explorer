import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/models/star_model.dart';
import '../../../core/services/star_data_service.dart';

class StarMapScreen extends StatefulWidget {
  const StarMapScreen({super.key});

  @override
  State<StarMapScreen> createState() => _StarMapScreenState();
}

class _StarMapScreenState extends State<StarMapScreen> {
  final StarDataService _dataService = StarDataService();
  late Future<List<Star>> _starsFuture;
  Star? _selectedStar;

  @override
  void initState() {
    super.initState();
    _starsFuture = _dataService.getStarsByMagnitude(5.0); // Limit to brighter stars for performance
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Star Map'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF000814),
              const Color(0xFF001D3D),
              Colors.black.withValues(alpha: 0.98),
            ],
          ),
        ),
        child: FutureBuilder<List<Star>>(
          future: _starsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading star catalog...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load stars\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _starsFuture = _dataService.getStarsByMagnitude(5.0);
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No stars found.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final stars = snapshot.data!;

            return Stack(
              children: [
                // Interactive star map
                InteractiveStarMap(
                  stars: stars,
                  onStarTapped: (star) {
                    setState(() {
                      _selectedStar = star;
                    });
                  },
                ),
                
                // Star details card (when a star is selected)
                if (_selectedStar != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: _StarDetailsCard(
                      star: _selectedStar!,
                      onClose: () {
                        setState(() {
                          _selectedStar = null;
                        });
                      },
                    ),
                  ),
                
                // Instructions overlay (top)
                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: _InstructionsOverlay(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Star Map Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(Icons.pan_tool, 'Drag to pan the sky'),
            _buildHelpItem(Icons.zoom_in, kIsWeb ? 'Scroll to zoom' : 'Pinch to zoom'),
            _buildHelpItem(Icons.touch_app, 'Tap a star for details'),
            _buildHelpItem(Icons.restart_alt, 'Double-tap to recenter'),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class InteractiveStarMap extends StatefulWidget {
  final List<Star> stars;
  final Function(Star) onStarTapped;

  const InteractiveStarMap({
    super.key,
    required this.stars,
    required this.onStarTapped,
  });

  @override
  State<InteractiveStarMap> createState() => _InteractiveStarMapState();
}

class _InteractiveStarMapState extends State<InteractiveStarMap> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _lastFocalPoint = details.focalPoint;
      },
      onScaleUpdate: (details) {
        setState(() {
          // Update scale
          _scale = (_scale * details.scale).clamp(0.5, 5.0);
          
          // Update offset for panning
          final delta = details.focalPoint - _lastFocalPoint;
          _offset += delta;
          _lastFocalPoint = details.focalPoint;
        });
      },
      onDoubleTap: () {
        // Recenter on double tap
        setState(() {
          _scale = 1.0;
          _offset = Offset.zero;
        });
      },
      onTapUp: (details) {
        // Detect tap on star
        final tapPosition = details.localPosition;
        _detectStarTap(tapPosition);
      },
      child: CustomPaint(
        painter: StarMapPainter(
          stars: widget.stars,
          scale: _scale,
          offset: _offset,
        ),
        size: Size.infinite,
      ),
    );
  }

  void _detectStarTap(Offset tapPosition) {
    final size = MediaQuery.of(context).size;
    
    // Find the closest star to tap position
    Star? closestStar;
    double minDistance = double.infinity;

    for (final star in widget.stars) {
      final starPos = _raDecToScreen(star.ra, star.dec, size);
      final transformedPos = (starPos * _scale) + _offset;
      
      final distance = (transformedPos - tapPosition).distance;
      
      if (distance < 30 && distance < minDistance) {
        minDistance = distance;
        closestStar = star;
      }
    }

    if (closestStar != null) {
      widget.onStarTapped(closestStar);
    }
  }

  Offset _raDecToScreen(double ra, double dec, Size size) {
    // Map RA (0-360) to X (0 to width)
    // Map Dec (-90 to 90) to Y (height to 0, inverted)
    final x = (ra / 360.0) * size.width;
    final y = ((90.0 - dec) / 180.0) * size.height;
    return Offset(x, y);
  }
}

class StarMapPainter extends CustomPainter {
  final List<Star> stars;
  final double scale;
  final Offset offset;

  StarMapPainter({
    required this.stars,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw each star
    for (final star in stars) {
      final position = _raDecToScreen(star.ra, star.dec, size);
      final transformedPosition = (position * scale) + offset;

      // Only draw stars within visible bounds (with margin)
      if (transformedPosition.dx < -50 ||
          transformedPosition.dx > size.width + 50 ||
          transformedPosition.dy < -50 ||
          transformedPosition.dy > size.height + 50) {
        continue;
      }

      _drawStar(canvas, transformedPosition, star);
    }
  }

  Offset _raDecToScreen(double ra, double dec, Size size) {
    final x = (ra / 360.0) * size.width;
    final y = ((90.0 - dec) / 180.0) * size.height;
    return Offset(x, y);
  }

  void _drawStar(Canvas canvas, Offset position, Star star) {
    // Calculate star size based on brightness (magnitude)
    final brightness = star.relativeBrightness;
    final baseRadius = 1.5;
    final radius = baseRadius + (brightness * 4.0 * scale);

    // Color based on spectral type
    final color = _getStarColor(star.spectralType);

    // Draw star glow (larger, semi-transparent)
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3 * brightness)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawCircle(position, radius * 2.5, glowPaint);

    // Draw star core
    final starPaint = Paint()
      ..color = color.withValues(alpha: 0.7 + (brightness * 0.3))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, radius, starPaint);

    // For very bright stars, add extra twinkle
    if (star.magnitude < 1.0) {
      final twinklePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, radius * 0.5, twinklePaint);
    }
  }

  Color _getStarColor(String? spectralType) {
    if (spectralType == null || spectralType.isEmpty) {
      return Colors.white;
    }

    final type = spectralType[0].toUpperCase();
    switch (type) {
      case 'O':
      case 'B':
        return const Color(0xFFAAD3FF); // Blue
      case 'A':
        return const Color(0xFFD5E3FF); // Blue-white
      case 'F':
        return const Color(0xFFFFF4EA); // White
      case 'G':
        return const Color(0xFFFFF6D5); // Yellow-white
      case 'K':
        return const Color(0xFFFFD2A1); // Orange
      case 'M':
        return const Color(0xFFFFB380); // Red
      default:
        return Colors.white;
    }
  }

  @override
  bool shouldRepaint(StarMapPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.offset != offset ||
        oldDelegate.stars != stars;
  }
}

class _StarDetailsCard extends StatelessWidget {
  final Star star;
  final VoidCallback onClose;

  const _StarDetailsCard({
    required this.star,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    star.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Magnitude', star.magnitude.toStringAsFixed(2)),
            if (star.spectralType != null)
              _buildDetailRow('Spectral Type', star.spectralType!),
            if (star.constellation != null)
              _buildDetailRow('Constellation', star.constellation!),
            if (star.distanceLightYears != null)
              _buildDetailRow(
                'Distance',
                '${star.distanceLightYears!.toStringAsFixed(1)} ly',
              ),
            _buildDetailRow(
              'Coordinates',
              'RA: ${star.ra.toStringAsFixed(2)}° Dec: ${star.dec.toStringAsFixed(2)}°',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionsOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            kIsWeb ? 'Drag to pan • Scroll to zoom • Click stars' : 'Pan • Pinch to zoom • Tap stars',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
