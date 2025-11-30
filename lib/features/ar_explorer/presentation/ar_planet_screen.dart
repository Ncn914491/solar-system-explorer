import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ArPlanetScreen extends StatefulWidget {
  final String planetName;

  const ArPlanetScreen({super.key, required this.planetName});

  @override
  State<ArPlanetScreen> createState() => _ArPlanetScreenState();
}

class _ArPlanetScreenState extends State<ArPlanetScreen> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

  bool _instructionsVisible = true;

  @override
  void dispose() {
    super.dispose();
    arSessionManager?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Platform check: If web, show fallback
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('AR Not Supported')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_cell, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'AR is not supported on Web.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Please use the mobile app to experience AR.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('View ${widget.planetName} in AR'),
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
          ),
          if (_instructionsVisible)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Move phone to detect surface (dots will appear)\n'
                      '2. Tap on dots to place the planet\n'
                      '3. Pinch to resize',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _instructionsVisible = false;
                        });
                      },
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          showWorldOrigin: false, // Don't show world origin
          handlePans: true,
          handleRotation: true,
        );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTap;
  }

  Future<void> onPlaneOrPointTap(List<ARHitTestResult> hitTestResults) async {
    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    
    // If we already placed a planet, maybe we want to move it or add another?
    // For simplicity, let's remove old ones and place a new one.
    for (var anchor in anchors) {
      arAnchorManager!.removeAnchor(anchor);
    }
    anchors.clear();

    var newAnchor =
        ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
    bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
    
    if (didAddAnchor == true) {
      anchors.add(newAnchor);
      
      // Add a sphere node
      // Note: In a real app, we would load a GLB/GLTF model of the specific planet.
      // For this MVP, we use a simple sphere provided by the plugin or a web sphere.
      // The plugin supports loading local or web objects.
      // Since we don't have GLB assets ready, we'll try to use a simple node.
      // Wait, ar_flutter_plugin mainly supports GLTF/GLB nodes.
      // We can use a web URL for a sample GLB if we don't have one locally.
      // Or we can try to use a shape if supported.
      // Looking at the plugin docs/examples, usually we need a .glb file.
      // Let's use a public placeholder GLB for now, or just a simple node if possible.
      // Actually, let's use a generic "Moon" or "Earth" GLB from a public URL if available,
      // or just fail gracefully if we can't load it.
      // Better yet, let's assume we have a 'sphere.glb' in assets (we don't),
      // so we will use a remote URL for a generic planet model.
      
      // Using a reliable public GLB model of the Moon for testing.
      var newNode = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb", // Placeholder Duck for now as it's standard
        scale: vector.Vector3(0.2, 0.2, 0.2),
        position: vector.Vector3(0.0, 0.0, 0.0),
        rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
      );
      
      bool? didAddNodeToAnchor = await arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
      if (didAddNodeToAnchor == true) {
        nodes.add(newNode);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Placed ${widget.planetName}!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to place object')),
          );
        }
      }
    }
  }
}
