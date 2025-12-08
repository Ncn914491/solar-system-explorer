import 'package:flutter/material.dart';
import '../../../core/models/planet_model.dart';
import '../../../core/models/moon_model.dart';
import '../../../core/services/planet_data_service.dart';
import '../../../core/services/moon_data_service.dart';
import '../../ar_explorer/presentation/ar_planet_screen.dart';
import '../../moons/presentation/moon_detail_screen.dart';
import 'planet_nasa_gallery_screen.dart';

class PlanetDetailScreen extends StatefulWidget {
  final Planet? planet;
  final String? planetId;

  const PlanetDetailScreen({
    super.key,
    this.planet,
    this.planetId,
  }) : assert(planet != null || planetId != null,
            'Either planet or planetId must be provided');

  @override
  State<PlanetDetailScreen> createState() => _PlanetDetailScreenState();
}

class _PlanetDetailScreenState extends State<PlanetDetailScreen> {
  late Future<Planet?> _planetFuture;
  final PlanetDataService _dataService = PlanetDataService();
  final MoonDataService _moonDataService = MoonDataService();
  List<Moon> _moons = [];

  @override
  void initState() {
    super.initState();
    if (widget.planet != null) {
      _planetFuture = Future.value(widget.planet);
      _loadMoons(widget.planet!.id);
    } else {
      _planetFuture = _dataService.getPlanetById(widget.planetId!);
      _planetFuture.then((planet) {
        if (planet != null) {
          _loadMoons(planet.id);
        }
      });
    }
  }

  Future<void> _loadMoons(String planetId) async {
    final moons = await _moonDataService.getMoonsForPlanet(planetId);
    if (mounted) {
      setState(() {
        _moons = moons;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planet Details'),
      ),
      body: FutureBuilder<Planet?>(
        future: _planetFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Planet not found'));
          }

          final planet = snapshot.data!;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context, planet),
                    const SizedBox(height: 24),
                    _buildQuickStats(context, planet),
                    const SizedBox(height: 24),
                    _buildDescription(context, planet),
                    if (planet.atmosphere != null) ...[
                      const SizedBox(height: 24),
                      _buildSection(
                        context,
                        title: 'Atmosphere',
                        content: planet.atmosphere!,
                      ),
                    ],
                    if (_moons.isNotEmpty || planet.moonNames.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildMoonsSection(context, planet),
                    ],
                    if (planet.funFacts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildFunFacts(context, planet),
                    ],
                    const SizedBox(height: 32),
                    _buildFutureFeatures(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Planet planet) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          planet.name,
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          planet.shortDescription,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, Planet planet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatItem(label: 'Diameter', value: '${planet.diameterKm} km'),
                _StatItem(label: 'Mass', value: planet.massKg),
                _StatItem(
                    label: 'Distance from Sun',
                    value: '${planet.distanceFromSunKm} km'),
                _StatItem(
                    label: 'Orbital Period',
                    value: '${planet.orbitalPeriodDays} days'),
                _StatItem(
                    label: 'Rotation Period',
                    value: '${planet.rotationPeriodHours} hours'),
                _StatItem(label: 'Gravity', value: '${planet.gravityMs2} m/s²'),
                _StatItem(
                    label: 'Avg. Temp',
                    value: '${planet.averageTemperatureC}°C'),
                _StatItem(label: 'Moons', value: '${planet.numberOfMoons}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context, Planet planet) {
    return _buildSection(
      context,
      title: 'About ${planet.name}',
      content: planet.detailedDescription,
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required String content}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildMoonsSection(BuildContext context, Planet planet) {
    final theme = Theme.of(context);

    // Use loaded moons if available, otherwise use planet.moonNames
    final displayMoons = _moons.isNotEmpty
        ? _moons
        : planet.moonNames.map((name) => null).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.brightness_3, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Moons (${planet.numberOfMoons})',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (planet.numberOfMoons == 0)
            Text(
              '${planet.name} has no natural satellites.',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            )
          else ...[
            if (_moons.isNotEmpty)
              Text(
                'Tap on a moon to learn more:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              )
            else if (planet.moonNames.isNotEmpty)
              Text(
                'Major moons:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moons.isNotEmpty
                  ? _moons.map((moon) => _buildMoonChip(context, moon)).toList()
                  : planet.moonNames
                      .map((name) =>
                          _buildMoonNameChip(context, name, planet.id))
                      .toList(),
            ),
            if (planet.numberOfMoons >
                    (_moons.isEmpty
                        ? planet.moonNames.length
                        : _moons.length) &&
                planet.moonNames.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '...and ${planet.numberOfMoons - (planet.moonNames.length)} more',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoonChip(BuildContext context, Moon moon) {
    return ActionChip(
      avatar: const Icon(Icons.brightness_3, size: 16),
      label: Text(moon.name),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoonDetailScreen(moon: moon),
          ),
        );
      },
      backgroundColor:
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
    );
  }

  Widget _buildMoonNameChip(
      BuildContext context, String moonName, String planetId) {
    return ActionChip(
      avatar: const Icon(Icons.brightness_3, size: 16),
      label: Text(moonName),
      onPressed: () async {
        // Try to find moon by matching name
        final moons = await _moonDataService.getAllMoons();
        final moon = moons
            .where((m) =>
                m.name.toLowerCase().contains(moonName.toLowerCase()) ||
                moonName
                    .toLowerCase()
                    .contains(m.name.split(' ').first.toLowerCase()))
            .firstOrNull;

        if (moon != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MoonDetailScreen(moon: moon),
            ),
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Details for $moonName coming soon!')),
          );
        }
      },
      backgroundColor:
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
    );
  }

  Widget _buildFunFacts(BuildContext context, Planet planet) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fun Facts',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          ...planet.funFacts.map((fact) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: theme.colorScheme.primary)),
                    Expanded(
                      child: Text(
                        fact,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFutureFeatures(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlanetNasaGalleryScreen(
                  planetName: widget.planet?.name ?? 'Space',
                ),
              ),
            );
          },
          icon: const Icon(Icons.photo_library),
          label: const Text('View NASA Images'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArPlanetScreen(
                  planetName: widget.planet?.name ?? 'Planet',
                ),
              ),
            );
          },
          icon: const Icon(Icons.view_in_ar),
          label: const Text('View in AR'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
