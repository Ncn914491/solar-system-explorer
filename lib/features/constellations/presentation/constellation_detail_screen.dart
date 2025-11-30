import 'package:flutter/material.dart';
import '../../../core/models/constellation_model.dart';
import '../../../core/services/constellation_data_service.dart';

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
        child: Container(
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
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
                      _buildInfoItem('Area', '${c.areaSqDeg?.round() ?? "?"} sq°'),
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

          // Stars
          Text(
            'Main Stars',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: c.mainStars.map((star) {
              final isBrightest = star == c.brightestStar;
              return Chip(
                label: Text(star),
                backgroundColor: isBrightest
                    ? Colors.amber.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                side: BorderSide(
                  color: isBrightest ? Colors.amber : Colors.white24,
                ),
                labelStyle: TextStyle(
                  color: isBrightest ? Colors.amberAccent : Colors.white,
                  fontWeight: isBrightest ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Notable Objects
          if (c.notableObjects != null && c.notableObjects!.isNotEmpty) ...[
            Text(
              'Notable Objects',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: c.notableObjects!.map((obj) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.blur_on, color: Colors.tealAccent, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        obj,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Future Features Placeholders
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          _buildFutureFeatureButton(
            icon: Icons.map,
            label: 'View in Sky Map',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Star Map coming soon!')),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFutureFeatureButton(
            icon: Icons.view_in_ar,
            label: 'AR Sky Overlay',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AR Overlay coming soon!')),
              );
            },
          ),
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

  Widget _buildFutureFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
