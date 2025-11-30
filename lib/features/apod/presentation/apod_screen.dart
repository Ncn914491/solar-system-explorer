import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/apod_model.dart';
import '../../../core/services/nasa_api_service.dart';

/// Main screen for Astronomy Picture of the Day
class ApodScreen extends StatefulWidget {
  const ApodScreen({super.key});

  @override
  State<ApodScreen> createState() => _ApodScreenState();
}

class _ApodScreenState extends State<ApodScreen> {
  final NasaApiService _apiService = NasaApiService();
  late Future<ApodModel> _apodFuture;

  @override
  void initState() {
    super.initState();
    _loadApod();
  }

  void _loadApod() {
    setState(() {
      _apodFuture = _apiService.fetchApod();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NASA Picture of the Day'),
      ),
      body: FutureBuilder<ApodModel>(
        future: _apodFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          } else if (snapshot.hasError) {
            return _ErrorView(
              error: snapshot.error,
              onRetry: _loadApod,
            );
          } else if (snapshot.hasData) {
            return _ApodContent(
              apod: snapshot.data!,
              onRefresh: _loadApod,
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

/// Widget to display when loading
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Fetching the cosmos...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display when an error occurs
class _ErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load APOD',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceAll('Exception: ', ''),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display the APOD content
class _ApodContent extends StatelessWidget {
  final ApodModel apod;
  final VoidCallback onRefresh;

  const _ApodContent({required this.apod, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat.yMMMMd().format(apod.date);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                apod.title,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Date
              Text(
                formattedDate,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Media (Image or Placeholder)
              _MediaCard(apod: apod),
              
              const SizedBox(height: 24),

              // Explanation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explanation',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      apod.explanation,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                    if (apod.copyright != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Copyright: ${apod.copyright}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Reload Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload APOD'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to handle image vs video display
class _MediaCard extends StatefulWidget {
  final ApodModel apod;

  const _MediaCard({required this.apod});

  @override
  State<_MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<_MediaCard> {
  bool _useProxy = false;

  @override
  Widget build(BuildContext context) {
    final isImage = widget.apod.mediaType == 'image';
    
    // Determine which URL to use
    String imageUrl = widget.apod.url;
    
    // On web, use proxy if needed
    if (kIsWeb && isImage && _useProxy) {
      imageUrl = 'https://corsproxy.io/?${Uri.encodeComponent(widget.apod.url)}';
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: isImage
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 300,
                  color: Colors.black26,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Image load error: $error');
                // If we haven't tried the proxy yet and we're on web, retry with proxy
                if (kIsWeb && !_useProxy && isImage) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _useProxy = true;
                      });
                    }
                  });
                }
                
                return Container(
                  height: 200,
                  color: Colors.black26,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          _useProxy ? 'Failed to load image' : 'Loading...',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (_useProxy)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Error: $error',
                              style: const TextStyle(color: Colors.red, fontSize: 10),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Container(
              height: 250,
              color: Colors.black26,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'This APOD is a video',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Open in browser to view: ${widget.apod.title}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}
