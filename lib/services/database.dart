import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models.dart';

class SACDatabaseService {
  String path;

  SACDatabaseService._();

  static final SACDatabaseService db = SACDatabaseService._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await init();
    return _database;
  }

  init() async {
    String path = await getDatabasesPath();
    path = join(path, 'sacs.db');
    print("Entered path $path");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE SAC (sac_id INTEGER PRIMARY KEY, title TEXT, content TEXT, date TEXT, state TEXT, location TEXT, picture TEXT);');
      print('New table created at $path');
    });
  }

  //get list of all SAC
  Future<List<SACModel>> getSACFromDB() async {
    final db = await database;
    List<SACModel> sacsList = [];
    List<Map> maps = await db.query('SAC', columns: [
      'sac_id',
      'title',
      'content',
      'date',
      'state',
      'location',
      'picture',
    ]);
    if (maps.length > 0) {
      maps.forEach((map) {
        sacsList.add(SACModel.fromMap(map));
      });
    }
    return sacsList;
  }

  //when editing a sac
  updateSACInDB(SACModel updatedSAC) async {
    final db = await database;
    await db.update('SAC', updatedSAC.toMap(),
        where: 'sac_id = ?', whereArgs: [updatedSAC.id]);
    print('SAC updated: ${updatedSAC.title} ${updatedSAC.content}');
  }

  //when deleting a sac
  deleteSACInDB(SACModel sacToDelete) async {
    final db = await database;
    await db.delete('SAC', where: 'sac_id = ?', whereArgs: [sacToDelete.id]);
    print('SAC deleted');
  }

  //when creating a sac
  Future<SACModel> addSACInDB(SACModel newSAC) async {
    final db = await database;
    if (newSAC.title.trim().isEmpty) newSAC.title = 'Untitled SAC';
    int id = await db.transaction((transaction) {
      transaction.rawInsert(
          'INSERT into SAC(title, content, date, state, location, picture) VALUES ("${newSAC.title}", "${newSAC.content}", "${newSAC.date.toIso8601String()}", "${newSAC.state}","${newSAC.location}", "${newSAC.picture}");');
    });
    newSAC.id = id;
    print('SAC added: ${newSAC.title} ${newSAC.content}');
    return newSAC;
  }
}
