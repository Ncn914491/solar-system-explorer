import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/apod_model.dart';
import '../../../core/services/nasa_api_service.dart';
import '../../../core/services/apod_cache_service.dart';

/// Main screen for Astronomy Picture of the Day
class ApodScreen extends StatefulWidget {
  const ApodScreen({super.key});

  @override
  State<ApodScreen> createState() => _ApodScreenState();
}

class _ApodScreenState extends State<ApodScreen> {
  final NasaApiService _apiService = NasaApiService();
  final ApodCacheService _cacheService = ApodCacheService();
  
  ApodModel? _apodData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _loadApod();
  }

  Future<void> _loadApod() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isOfflineMode = false;
    });

    try {
      // Try to fetch fresh APOD from NASA API
      final apod = await _apiService.fetchApod();
      
      if (mounted) {
        setState(() {
          _apodData = apod;
          _isLoading = false;
          _isOfflineMode = false;
        });
        
        // Cache the successful result
        await _cacheService.cacheApodData(apod);
      }
    } catch (e) {
      // Network request failed - try to load from cache
      final cachedApod = await _cacheService.getCachedApod();
      
      if (mounted) {
        if (cachedApod != null) {
          // We have cached data - show it with offline indicator
          setState(() {
            _apodData = cachedApod;
            _isLoading = false;
            _isOfflineMode = true;
          });
        } else {
          // No cache available - show error
          setState(() {
            _apodData = null;
            _isLoading = false;
            _errorMessage = e.toString();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NASA Picture of the Day'),
        actions: [
          if (_apodData != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadApod,
              tooltip: 'Refresh APOD',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const _LoadingView();
    } else if (_errorMessage != null && _apodData == null) {
      return _ErrorView(
        error: _errorMessage,
        onRetry: _loadApod,
      );
    } else if (_apodData != null) {
      return _ApodContent(
        apod: _apodData!,
        onRefresh: _loadApod,
        isOfflineMode: _isOfflineMode,
      );
    } else {
      return const SizedBox.shrink();
    }
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
  final bool isOfflineMode;

  const _ApodContent({
    required this.apod,
    required this.onRefresh,
    this.isOfflineMode = false,
  });

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
              // Offline mode indicator
              if (isOfflineMode)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Offline Mode: Showing last saved APOD',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.orange.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
  late bool _imageError;
  
  @override
  void initState() {
    super.initState();
    _imageError = false;
  }

  String _getImageUrl() {
    // On web, always use CORS proxy to avoid CORS issues
    if (kIsWeb && widget.apod.mediaType == 'image') {
      // Use AllOrigins CORS proxy which is more reliable
      return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(widget.apod.url)}';
    }
    return widget.apod.url;
  }

  @override
  Widget build(BuildContext context) {
    final isImage = widget.apod.mediaType == 'image';
    
    if (_imageError) {
      // Show error state with link to original image
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple.withValues(alpha: 0.2),
                Colors.indigo.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image, size: 64, color: Colors.white70),
              const SizedBox(height: 16),
              const Text(
                'Image Preview Unavailable',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.apod.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Try to open in new tab/browser
                  debugPrint('Open URL: ${widget.apod.url}');
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('View Original Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: isImage
          ? Image.network(
              _getImageUrl(),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 300,
                  color: Colors.black26,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Loading image...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('APOD Image load error: $error');
                // Set error state to show fallback UI
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_imageError) {
                    setState(() {
                      _imageError = true;
                    });
                  }
                });
                
                return Container(
                  height: 300,
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
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
