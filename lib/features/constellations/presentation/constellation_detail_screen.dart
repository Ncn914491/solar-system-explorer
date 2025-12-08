import 'package:flutter/material.dart';
import '../../../core/models/constellation_model.dart';
import '../../../core/models/nasa_image_model.dart';
import '../../../core/services/constellation_data_service.dart';
import '../../../core/services/nasa_image_service.dart';

class ConstellationDetailScreen extends StatefulWidget {
  final Constellation? constellation;
  final String? constellationId;

  const ConstellationDetailScreen({
    super.key,
    this.constellation,
    this.constellationId,
  }) : assert(constellation != null || constellationId != null,
            'Either constellation or constellationId must be provided');

  @override
  State<ConstellationDetailScreen> createState() =>
      _ConstellationDetailScreenState();
}

class _ConstellationDetailScreenState extends State<ConstellationDetailScreen> {
  Constellation? _constellation;
  bool _isLoading = true;
  String? _errorMessage;
  List<NasaImage> _images = [];
  bool _loadingImages = true;

  final NasaImageService _imageService = NasaImageService();

  @override
  void initState() {
    super.initState();
    _loadConstellation();
  }

  Future<void> _loadConstellation() async {
    if (widget.constellation != null) {
      setState(() {
        _constellation = widget.constellation;
        _isLoading = false;
      });
      _loadNasaImages(widget.constellation!);
    } else if (widget.constellationId != null) {
      try {
        final service = ConstellationDataService();
        final result =
            await service.getConstellationById(widget.constellationId!);
        if (mounted) {
          setState(() {
            _constellation = result;
            _isLoading = false;
            if (result == null) {
              _errorMessage = 'Constellation not found';
            } else {
              _loadNasaImages(result);
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load constellation details';
          });
        }
      }
    }
  }

  Future<void> _loadNasaImages(Constellation constellation) async {
    try {
      // Search for constellation images from NASA
      final searchQuery = '${constellation.name} constellation';
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

    if (_errorMessage != null || _constellation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(_errorMessage ?? 'Unknown error'),
        ),
      );
    }

    final c = _constellation!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(c.name),
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
                    child: _buildContent(c),
                  ),
                );
              }
              return _buildContent(c);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Constellation c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            color: Colors.white.withOpacity(0.1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            c.abbreviation,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      if (c.zodiac)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.purpleAccent),
                          ),
                          child: const Text(
                            'ZODIAC',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem('Hemisphere', c.hemisphere),
                      _buildInfoItem('Best Month', c.bestViewingMonths.first),
                      _buildInfoItem(
                          'Area', '${c.areaSqDeg?.round() ?? "?"} sq°'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // NASA Images Gallery
          if (_images.isNotEmpty) ...[
            Text(
              'NASA Images',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final image = _images[index];
                  return Padding(
                    padding: EdgeInsets.only(
                        right: index < _images.length - 1 ? 12 : 0),
                    child: GestureDetector(
                      onTap: () => _showFullImage(context, image),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          image.imageUrl,
                          width: 260,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 260,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.image_not_supported,
                                color: Colors.white54, size: 40),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 260,
                              color: Colors.grey.shade900,
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ] else if (_loadingImages) ...[
            const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 24),
          ],

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
            c.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Mythology
          Text(
            'Mythology',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.withOpacity(0.3)),
            ),
            child: Text(
              c.mythology,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stars Section
          Text(
            'Main Stars (${c.mainStars.length})',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${c.brightestStar} is the brightest star in ${c.name}.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 12),
          _buildStarsGrid(c),
          const SizedBox(height: 24),

          // Notable Objects
          if (c.notableObjects != null && c.notableObjects!.isNotEmpty) ...[
            Text(
              'Notable Deep-Sky Objects',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: c.notableObjects!.map((obj) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.blur_on,
                          color: Colors.tealAccent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          obj,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, NasaImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    image.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (image.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      image.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarsGrid(Constellation c) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: c.mainStars.map((star) {
        final isBrightest = star == c.brightestStar;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isBrightest
                ? LinearGradient(
                    colors: [
                      Colors.amber.withOpacity(0.4),
                      Colors.orange.withOpacity(0.3),
                    ],
                  )
                : null,
            color: isBrightest ? null : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isBrightest ? Colors.amber : Colors.white24,
              width: isBrightest ? 2 : 1,
            ),
            boxShadow: isBrightest
                ? [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: isBrightest ? Colors.amber : Colors.white54,
              ),
              const SizedBox(width: 6),
              Text(
                star,
                style: TextStyle(
                  color: isBrightest ? Colors.amber.shade100 : Colors.white,
                  fontWeight: isBrightest ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              if (isBrightest) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Brightest',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
