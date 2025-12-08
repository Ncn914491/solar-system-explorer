import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/models/nasa_image_model.dart';
import '../../../core/services/nasa_image_service.dart';

class PlanetNasaGalleryScreen extends StatefulWidget {
  final String planetName;

  const PlanetNasaGalleryScreen({super.key, required this.planetName});

  @override
  State<PlanetNasaGalleryScreen> createState() =>
      _PlanetNasaGalleryScreenState();
}

class _PlanetNasaGalleryScreenState extends State<PlanetNasaGalleryScreen> {
  final NasaImageService _imageService = NasaImageService();
  late Future<List<NasaImageModel>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    setState(() {
      _imagesFuture = _imageService.searchImages(widget.planetName);
    });
  }

  void _openImageDetail(BuildContext context, NasaImageModel image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _NasaImageDetailScreen(image: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.planetName} Gallery'),
      ),
      body: FutureBuilder<List<NasaImageModel>>(
        future: _imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load images',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadImages,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_not_supported,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No images found for ${widget.planetName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          final images = snapshot.data!;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return _GalleryTile(
                    image: image,
                    onTap: () => _openImageDetail(context, image),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final NasaImageModel image;
  final VoidCallback onTap;

  const _GalleryTile({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: CachedNetworkImageProvider(image.thumbnailUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.6, 1.0],
            ),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(8),
          child: Text(
            image.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _NasaImageDetailScreen extends StatefulWidget {
  final NasaImageModel image;

  const _NasaImageDetailScreen({required this.image});

  @override
  State<_NasaImageDetailScreen> createState() => _NasaImageDetailScreenState();
}

class _NasaImageDetailScreenState extends State<_NasaImageDetailScreen> {
  final NasaImageService _imageService = NasaImageService();
  late Future<String?> _fullImageFuture;

  @override
  void initState() {
    super.initState();
    // If we have a collection URL, try to fetch the original image
    if (widget.image.fullImageUrl != null) {
      _fullImageFuture =
          _imageService.getOriginalImageUrl(widget.image.fullImageUrl!);
    } else {
      _fullImageFuture = Future.value(widget.image.thumbnailUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Detail'),
      ),
      body: FutureBuilder<String?>(
        future: _fullImageFuture,
        builder: (context, snapshot) {
          final imageUrl = snapshot.data ?? widget.image.thumbnailUrl;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return const SizedBox(
                        height: 300,
                        child:
                            Center(child: Icon(Icons.broken_image, size: 64)),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.image.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (widget.image.dateCreated != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${widget.image.dateCreated.toString().split(' ')[0]}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        widget.image.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
