import 'package:flutter/material.dart';
import '../../../core/models/moon_model.dart';
import '../../../core/services/moon_data_service.dart';
import '../../../core/services/nasa_image_service.dart';
import '../../../core/models/nasa_image_model.dart';

class MoonDetailScreen extends StatefulWidget {
  final Moon? moon;
  final String? moonId;

  const MoonDetailScreen({
    super.key,
    this.moon,
    this.moonId,
  }) : assert(moon != null || moonId != null,
            'Either moon or moonId must be provided');

  @override
  State<MoonDetailScreen> createState() => _MoonDetailScreenState();
}

class _MoonDetailScreenState extends State<MoonDetailScreen> {
  Moon? _moon;
  bool _isLoading = true;
  String? _errorMessage;
  List<NasaImage> _images = [];
  bool _loadingImages = true;

  final NasaImageService _imageService = NasaImageService();

  @override
  void initState() {
    super.initState();
    _loadMoon();
  }

  Future<void> _loadMoon() async {
    if (widget.moon != null) {
      setState(() {
        _moon = widget.moon;
        _isLoading = false;
      });
      _loadNasaImages(widget.moon!);
    } else if (widget.moonId != null) {
      try {
        final service = MoonDataService();
        final result = await service.getMoonById(widget.moonId!);
        if (mounted) {
          setState(() {
            _moon = result;
            _isLoading = false;
            if (result == null) {
              _errorMessage = 'Moon not found';
            } else {
              _loadNasaImages(result);
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load moon details';
          });
        }
      }
    }
  }

  Future<void> _loadNasaImages(Moon moon) async {
    try {
      final searchQuery = moon.imageKeyword ?? moon.name;
      final images =
          await _imageService.searchImages(searchQuery, page: 1, pageSize: 5);
      if (mounted) {
        setState(() {
          _images = images;
          _loadingImages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingImages = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _moon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(_errorMessage ?? 'Unknown error'),
        ),
      );
    }

    final moon = _moon!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(moon.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _buildContent(moon),
                  ),
                );
              }
              return _buildContent(moon);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Moon moon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NASA Image Gallery
          if (_images.isNotEmpty) ...[
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final image = _images[index];
                  return Padding(
                    padding: EdgeInsets.only(
                        right: index < _images.length - 1 ? 12 : 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        image.imageUrl,
                        width: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 280,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.white54),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Images from NASA',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
          ] else if (_loadingImages) ...[
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 24),
          ],

          // Header Card with Icon
          Card(
            color: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Moon Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.grey.shade300,
                          Colors.grey.shade600,
                          Colors.grey.shade800,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.brightness_3,
                      size: 40,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    moon.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (moon.alternativeName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Also known as ${moon.alternativeName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (moon.discoveredBy != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Discovered by ${moon.discoveredBy}${moon.discoveryYear != null ? ' (${moon.discoveryYear})' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem('Diameter',
                          '${moon.diameterKm.toStringAsFixed(1)} km'),
                      _buildInfoItem('Distance',
                          '${_formatNumber(moon.distanceFromPlanetKm)} km'),
                      _buildInfoItem('Orbital Period',
                          '${moon.orbitalPeriodDays.toStringAsFixed(2)} days'),
                    ],
                  ),
                ],
              ),
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
            moon.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Fun Facts
          if (moon.funFacts.isNotEmpty) ...[
            Text(
              'Fun Facts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...moon.funFacts.map((fact) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.tealAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fact,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatNumber(double num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toStringAsFixed(0);
  }
}
