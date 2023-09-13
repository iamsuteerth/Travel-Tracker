import 'dart:io';
import 'package:favourite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

// This provider is made to listen to the list of place being modified which is a stateful widget

Future<Database> _getDatabase() async {
  final dbPath =
      await sql.getDatabasesPath(); // Path where we might create a database
  final createdDb = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_places (id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
    },
    version: 1,
  ); // Auto creation if DNE
  return createdDb;
}

class UserPlacesNotifer extends StateNotifier<List<Place>> {
  UserPlacesNotifer() : super(const []); // Has an initializer list
  // Pass an initial list to parent
  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query(
        'user_places'); // Returns list of maps (every row is a map entry)
    final places = data
        .map(
          (row) => Place(
            id: row['id'],
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
              latitude: row['lat'] as double,
              longitude: row['lng'] as double,
              address: row['address'] as String,
            ),
          ),
        )
        .toList();
    state = places;
  }

  void removePlace(Place placeToDelete) async {
    final db = await _getDatabase();
    final resp = await db
        .rawDelete('DELETE FROM user_places WHERE id = ?', [placeToDelete.id]);
    if (resp == 0) {
      return;
    }
    state.removeWhere((element) => placeToDelete.id == element.id);
    state = [...state];
  }

  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspath.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$filename');
    final newPlace =
        Place(title: title, image: copiedImage, location: location);
    final db = await _getDatabase();
    db.insert(
      'user_places',
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'lat': newPlace.location.latitude,
        'lng': newPlace.location.longitude,
        'address': newPlace.location.address,
      },
    );
    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifer, List<Place>>(
        (ref) => UserPlacesNotifer());
