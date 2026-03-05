import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'models/category_model.dart';
import 'models/driver_model.dart';
import 'models/race_model.dart';
import 'models/result_model.dart';
import 'models/team_model.dart';

class DatabaseHelper {
  static const _databaseName = "GestaoCorridas.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    // Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    // Teams Table
    await db.execute('''
      CREATE TABLE teams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        country TEXT NOT NULL,
        logo_path TEXT
      )
    ''');

    // Drivers Table
    await db.execute('''
      CREATE TABLE drivers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        number INTEGER NOT NULL,
        team_id INTEGER NOT NULL,
        nationality TEXT NOT NULL,
        points_total INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE
      )
    ''');

    // Races Table
    await db.execute('''
      CREATE TABLE races (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location_title TEXT NOT NULL,
        position_lat REAL NOT NULL,
        position_lng REAL NOT NULL,
        date TEXT NOT NULL,
        expected_distance REAL NOT NULL,
        completed_distance REAL NOT NULL,
        is_sprint INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Results Table
    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        race_id INTEGER NOT NULL,
        driver_id INTEGER NOT NULL,
        team_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        grid_position INTEGER NOT NULL,
        fastest_lap INTEGER NOT NULL DEFAULT 0,
        dnf INTEGER NOT NULL DEFAULT 0,
        points_awarded INTEGER NOT NULL,
        FOREIGN KEY (race_id) REFERENCES races (id) ON DELETE CASCADE,
        FOREIGN KEY (driver_id) REFERENCES drivers (id) ON DELETE CASCADE,
        FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE
      )
    ''');

    // Indexes for optimization
    await db.execute('CREATE INDEX idx_driver_team_id ON drivers(team_id);');
    await db.execute('CREATE INDEX idx_result_race_id ON results(race_id);');
    await db.execute(
      'CREATE INDEX idx_result_driver_id ON results(driver_id);',
    );
  }

  // ==== EXPORT DATABASE ====
  Future<String?> exportDatabase() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String dbPath = join(documentsDirectory.path, _databaseName);

      File dbFile = File(dbPath);
      if (await dbFile.exists()) {
        Directory? externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          String exportPath = join(externalDir.path, '$_databaseName.backup');
          await dbFile.copy(exportPath);
          return exportPath;
        }
      }
      return null;
    } catch (e) {
      // Error handled silently or to specialized log

      return null;
    }
  }

  // ==== CRUD Categories ====
  Future<int> insertCategory(CategoryModel category) async {
    Database db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<CategoryModel>> getCategories() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }

  Future<int> updateCategory(CategoryModel category) async {
    Database db = await instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    Database db = await instance.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ==== CRUD Teams ====
  Future<int> insertTeam(TeamModel team) async {
    Database db = await instance.database;
    return await db.insert('teams', team.toMap());
  }

  Future<List<TeamModel>> getTeams() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('teams');
    return List.generate(maps.length, (i) => TeamModel.fromMap(maps[i]));
  }

  Future<int> updateTeam(TeamModel team) async {
    Database db = await instance.database;
    return await db.update(
      'teams',
      team.toMap(),
      where: 'id = ?',
      whereArgs: [team.id],
    );
  }

  Future<int> deleteTeam(int id) async {
    Database db = await instance.database;
    return await db.delete('teams', where: 'id = ?', whereArgs: [id]);
  }

  // ==== CRUD Drivers ====
  Future<int> insertDriver(DriverModel driver) async {
    Database db = await instance.database;
    return await db.insert('drivers', driver.toMap());
  }

  Future<List<DriverModel>> getDrivers() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'drivers',
      orderBy: 'points_total DESC',
    );
    return List.generate(maps.length, (i) => DriverModel.fromMap(maps[i]));
  }

  Future<int> updateDriver(DriverModel driver) async {
    Database db = await instance.database;
    return await db.update(
      'drivers',
      driver.toMap(),
      where: 'id = ?',
      whereArgs: [driver.id],
    );
  }

  Future<int> deleteDriver(int id) async {
    Database db = await instance.database;
    return await db.delete('drivers', where: 'id = ?', whereArgs: [id]);
  }

  // ==== CRUD Races ====
  Future<int> insertRace(RaceModel race) async {
    Database db = await instance.database;
    return await db.insert('races', race.toMap());
  }

  Future<List<RaceModel>> getRaces() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'races',
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => RaceModel.fromMap(maps[i]));
  }

  Future<int> updateRace(RaceModel race) async {
    Database db = await instance.database;
    return await db.update(
      'races',
      race.toMap(),
      where: 'id = ?',
      whereArgs: [race.id],
    );
  }

  Future<int> deleteRace(int id) async {
    Database db = await instance.database;
    return await db.delete('races', where: 'id = ?', whereArgs: [id]);
  }

  // ==== CRUD Results ====
  Future<int> insertResult(ResultModel result) async {
    Database db = await instance.database;
    return await db.transaction((txn) async {
      int id = await txn.insert('results', result.toMap());

      // Update Driver Points
      await txn.rawUpdate(
        'UPDATE drivers SET points_total = points_total + ? WHERE id = ?',
        [result.pointsAwarded, result.driverId],
      );

      return id;
    });
  }

  Future<List<ResultModel>> getResultsForRace(int raceId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'results',
      where: 'race_id = ?',
      whereArgs: [raceId],
      orderBy: 'position ASC',
    );
    return List.generate(maps.length, (i) => ResultModel.fromMap(maps[i]));
  }

  Future<List<ResultModel>> getResultsForDriver(int driverId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'results',
      where: 'driver_id = ?',
      whereArgs: [driverId],
    );
    return List.generate(maps.length, (i) => ResultModel.fromMap(maps[i]));
  }

  Future<int> deleteResult(int id, int pointsAwarded, int driverId) async {
    Database db = await instance.database;
    return await db.transaction((txn) async {
      int count = await txn.delete('results', where: 'id = ?', whereArgs: [id]);

      // Revert Driver Points
      await txn.rawUpdate(
        'UPDATE drivers SET points_total = points_total - ? WHERE id = ?',
        [pointsAwarded, driverId],
      );

      return count;
    });
  }
}
