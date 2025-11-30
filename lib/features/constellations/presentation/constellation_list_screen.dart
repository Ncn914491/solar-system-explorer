import 'package:flutter/material.dart';
import '../../../core/models/constellation_model.dart';
import '../../../core/services/constellation_data_service.dart';
import 'constellation_detail_screen.dart';

class ConstellationListScreen extends StatefulWidget {
  const ConstellationListScreen({super.key});

  @override
  State<ConstellationListScreen> createState() =>
      _ConstellationListScreenState();
}

class _ConstellationListScreenState extends State<ConstellationListScreen> {
  late Future<List<Constellation>> _constellationsFuture;
  final ConstellationDataService _dataService = ConstellationDataService();

  @override
  void initState() {
    super.initState();
    _constellationsFuture = _dataService.getAllConstellations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Constellations'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: Container(
          child: FutureBuilder<List<Constellation>>(
            future: _constellationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading constellations...',
                          style: TextStyle(color: Colors.white70)),
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
                        'Failed to load constellations.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _constellationsFuture =
                                _dataService.getAllConstellations();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No constellations found.',
                      style: TextStyle(color: Colors.white70)),
                );
              }

              final constellations = snapshot.data!;
              
              // Use LayoutBuilder to handle web/desktop constraints
              return LayoutBuilder(
                builder: (context, constraints) {
                  // On wide screens, constrain the width
                  if (constraints.maxWidth > 800) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: _buildList(constellations),
                      ),
                    );
                  }
                  return _buildList(constellations);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Constellation> constellations) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 16), // Top padding for AppBar
      itemCount: constellations.length,
      itemBuilder: (context, index) {
        final constellation = constellations[index];
        return Card(
          color: Colors.white.withOpacity(0.1),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConstellationDetailScreen(
                    constellation: constellation,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.indigoAccent.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(
                        constellation.abbreviation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              constellation.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (constellation.zodiac) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: Colors.purpleAccent.withOpacity(0.5)),
                                ),
                                child: const Text(
                                  'Zodiac',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${constellation.hemisphere} Hemisphere',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Best seen: ${constellation.bestViewingMonths.join(", ")}',
                          style: TextStyle(color: Colors.blueAccent.withOpacity(0.9), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white54, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
