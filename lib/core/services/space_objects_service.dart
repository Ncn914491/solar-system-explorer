import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/space_objects_model.dart';
// Note: We avoid dart:io to ensure web compatibility

/// Service for loading space objects data (asteroids, comets, black holes, meteor showers, exotic, deep sky, stars)
class SpaceObjectsService {
  static final SpaceObjectsService _instance = SpaceObjectsService._internal();
  factory SpaceObjectsService() => _instance;
  SpaceObjectsService._internal();

  List<Asteroid>? _cachedAsteroids;
  List<Comet>? _cachedComets;
  List<BlackHole>? _cachedBlackHoles;
  List<MeteorShower>? _cachedMeteorShowers;
  List<ExoticObject>? _cachedExoticObjects;
  List<DeepSkyObject>? _cachedDeepSkyObjects;
  List<Star>? _cachedStars;

  // Asteroids
  Future<List<Asteroid>> getAllAsteroids() async {
    if (_cachedAsteroids != null) return _cachedAsteroids!;
    try {
      final jsonString = await rootBundle.loadString('assets/data/asteroids.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedAsteroids = jsonList.map((json) => Asteroid.fromJson(json)).toList();
      return _cachedAsteroids!;
    } catch (e) {
      print('Error loading asteroids: $e');
      return [];
    }
  }

  // Comets
  Future<List<Comet>> getAllComets() async {
    if (_cachedComets != null) return _cachedComets!;
    try {
      final jsonString = await rootBundle.loadString('assets/data/comets.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedComets = jsonList.map((json) => Comet.fromJson(json)).toList();
      return _cachedComets!;
    } catch (e) {
      print('Error loading comets: $e');
      return [];
    }
  }

  // Black Holes
  Future<List<BlackHole>> getAllBlackHoles() async {
    if (_cachedBlackHoles != null) return _cachedBlackHoles!;
    try {
      final jsonString = await rootBundle.loadString('assets/data/black_holes.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedBlackHoles = jsonList.map((json) => BlackHole.fromJson(json)).toList();
      return _cachedBlackHoles!;
    } catch (e) {
      print('Error loading black holes: $e');
      return [];
    }
  }

  // Meteor Showers
  Future<List<MeteorShower>> getAllMeteorShowers() async {
    if (_cachedMeteorShowers != null) return _cachedMeteorShowers!;
    try {
      final jsonString = await rootBundle.loadString('assets/data/meteor_showers.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedMeteorShowers = jsonList.map((json) => MeteorShower.fromJson(json)).toList();
      return _cachedMeteorShowers!;
    } catch (e) {
      print('Error loading meteor showers: $e');
      return [];
    }
  }

  // Exotic Objects (Wormholes, White Holes, etc.)
  Future<List<ExoticObject>> getAllExoticObjects() async {
    if (_cachedExoticObjects != null) return _cachedExoticObjects!;
    try {
      final jsonString = await rootBundle.loadString('assets/data/exotic_objects.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedExoticObjects = jsonList.map((json) => ExoticObject.fromJson(json)).toList();
      return _cachedExoticObjects!;
    } catch (e) {
      print('Error loading exotic objects: $e');
      return [];
    }
  }

  // Deep Sky Objects (Nebulae, Galaxies)
  Future<List<DeepSkyObject>> getAllDeepSkyObjects() async {
    if (_cachedDeepSkyObjects != null) return _cachedDeepSkyObjects!;
    try {
      final jsonString = await rootBundle.loadString('assets/data/deep_sky.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedDeepSkyObjects = jsonList.map((json) => DeepSkyObject.fromJson(json)).toList();
      return _cachedDeepSkyObjects!;
    } catch (e) {
      print('Error loading deep sky objects: $e');
      return [];
    }
  }

  // Stars
  Future<List<Star>> getAllStars() async {
    if (_cachedStars != null) return _cachedStars!;
    try {
      final jsonString = await rootBundle.loadString('assets/data/stars.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedStars = jsonList.map((json) => Star.fromJson(json)).toList();
      return _cachedStars!;
    } catch (e) {
      print('Error loading stars: $e');
      return [];
    }
  }

  void clearCache() {
    _cachedAsteroids = null;
    _cachedComets = null;
    _cachedBlackHoles = null;
    _cachedMeteorShowers = null;
    _cachedExoticObjects = null;
    _cachedDeepSkyObjects = null;
    _cachedStars = null;
  }
}
