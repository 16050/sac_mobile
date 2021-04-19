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
    path = join(path, 'sac_mobile.db');
    print("Entered path $path");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE Offender (offender_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);');
      await db.execute(
          'CREATE TABLE User (user_id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, password TEXT);');
      await db.execute('INSERT into User(email, password) VALUES ("", "");');
      await db.execute(
          'CREATE TABLE SAC (sac_id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, date TEXT, state TEXT, location TEXT, offender_id INTEGER, offender TEXT);');
      await db.execute(
          'CREATE TABLE SAC_type (sac_type_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price INT);');
      await db
          .execute('INSERT into SAC_type(name, price) VALUES ("type1", "10");');
      await db
          .execute('INSERT into SAC_type(name, price) VALUES ("type2", "20");');
      await db.execute(
          'CREATE TABLE Picture (picture_id INTEGER PRIMARY KEY AUTOINCREMENT, base64code TEXT, sac_id INTEGER);');
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
      'offender_id',
      'offender'
    ]);
    if (maps.length > 0) {
      maps.forEach((map) {
        sacsList.add(SACModel.fromMap(map));
      });
    }
    return sacsList;
  }

  Future<List<SACModel>> getNotSendedSAC() async {
    final db = await database;
    List<SACModel> sacsList = [];
    List<Map> maps = await db.query('SAC', columns: [
      'sac_id',
      'title',
      'content',
      'date',
      'state',
      'location',
      'offender_id',
      'offender'
    ]);
    if (maps.length > 0) {
      maps.forEach((map) {
        if (map['state'] == 'Pas encore envoyé') {
          sacsList.add(SACModel.fromMap(map));
        }
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
    SACModel sac;
    if (newSAC.title.trim().isEmpty) newSAC.title = 'Untitled SAC';
    int id = await db.transaction((transaction) {
      transaction.rawInsert(
          'INSERT into SAC(title, content, date, state, location, offender_id, offender) VALUES ("${newSAC.title}", "${newSAC.content}", "${newSAC.date.toIso8601String()}", "${newSAC.state}","${newSAC.location}", ${newSAC.offender.id}, "${newSAC.offender.name}");');
    });
    List<Map> maps = await db.query('SAC', columns: [
      'sac_id',
      'title',
      'content',
      'date',
      'state',
      'location',
      'offender_id',
      'offender'
    ]);
    maps.forEach((map) {
      if (map['content'] == newSAC.content &&
          map['date'] == newSAC.date.toIso8601String()) {
        newSAC = SACModel.fromMap(map);
        print('SAC added: ${newSAC.id}');
        sac = newSAC;
        //sac.id = newSAC.id;
      }
    });
    return sac;
  }

  Future<SACModel> addSAC(SACModel newSAC) async {
    final db = await database;
    if (newSAC.title.trim().isEmpty) newSAC.title = 'Untitled SAC';
    int id = await db.transaction((transaction) {
      transaction.rawInsert(
          'INSERT into SAC(title, content, date, state, location, offender_id, offender) VALUES ("${newSAC.title}", "${newSAC.content}", "${newSAC.date.toIso8601String()}", "${newSAC.state}","${newSAC.location}", ${newSAC.offender.id}, "${newSAC.offender.name}");');
    });
    newSAC.id = id;
    print('SAC added: ${newSAC.id} ${newSAC.content}');
    return newSAC;
  }

  //picture
  /*
  addPictureInDB(String base64code, int sac_id) async {
    final db = await database;
    int id = await db.transaction((transaction) {
      transaction.rawInsert(
          'INSERT into Picture(base64code, sac_id) VALUES ("${base64code}", "${sac_id}");');
    });
    print('SAC added: ${sac_id}');
  }*/

  //pictures
  addPicturesInDB(List<String> base64code, int sac_id) async {
    final db = await database;
    base64code.forEach((element) async {
      int id = await db.transaction((transaction) {
        transaction.rawInsert(
            'INSERT into Picture(base64code, sac_id) VALUES ("${element}", "${sac_id}");');
      });
    });
    print('Picures added: ${sac_id}');
  }

  Future<List<String>> getPictures(SACModel sac) async {
    final db = await database;
    List<String> pictureList = [];
    List<Map> maps = await db.query('Picture', columns: [
      'picture_id',
      'base64code',
      'sac_id',
    ]);
    if (maps.length > 0) {
      maps.forEach((map) {
        if (map['sac_id'] == sac.id) {
          pictureList.add(map['base64code']);
        }
      });
    }
    return pictureList;
  }

  //Type
  Future<List<TypeModel>> getTypesFromDB() async {
    final db = await database;
    List<TypeModel> typesList = [];
    List<Map> maps = await db.query('Type', columns: [
      'type_id',
      'name',
      'price',
    ]);
    if (maps.length > 0) {
      maps.forEach((map) {
        typesList.add(TypeModel.fromMap(map));
      });
    }
    return typesList;
  }

  //Offender
  Future<OffenderModel> addOffenderInDB(OffenderModel newOffender) async {
    final db = await database;
    OffenderModel offender;
    int id = await db.transaction((transaction) {
      transaction.rawInsert(
          'INSERT into Offender(name) VALUES ("${newOffender.name}");');
    });
    List<Map> maps = await db.query('Offender', columns: [
      'offender_id',
      'name',
    ]);
    maps.forEach((map) {
      if (map['name'] == newOffender.name) {
        newOffender = OffenderModel.fromMap(map);
        print('Offender added: ${newOffender.id}');
        offender = newOffender;
      }
    });
    return offender;
  }

  Future<OffenderModel> existingOffender(String name) async {
    final db = await database;
    OffenderModel offender = new OffenderModel(1, '');
    List<Map> maps = await db.query('Offender', columns: [
      'offender_id',
      'name',
    ]);
    if (maps.length > 0) {
      for (Map map in maps) {
        if (map['name'] == name) {
          offender = OffenderModel.fromMap(map);
          print('Offender exist in DB');
          return offender;
        } else {
          offender.name = name;
        }
      }
    }
    offender.name = name;
    return addOffenderInDB(offender);
  }

  Future<List<SACModel>> getOffenderSAC(OffenderModel offender) async {
    final db = await database;
    List<SACModel> sacList = [];
    List<Map> maps = await db.query('SAC', columns: [
      'sac_id',
      'title',
      'content',
      'date',
      'state',
      'location',
      'offender_id',
      'offender'
    ]);
    if (maps.length > 0) {
      maps.forEach((map) {
        if (map['offender'] == offender.name) {
          sacList.add(SACModel.fromMap(map));
        }
      });
    }
    offender.sacList = sacList;
    return offender.sacList;
  }

  //User
  Future<bool> userConnexion(String email, String password) async {
    bool connexion = false;
    final db = await database;
    List<Map> maps = await db.query('User', columns: [
      'user_id',
      'email',
      'password',
    ]);
    if (maps.length > 0) {
      for (Map map in maps) {
        if (map['email'] == email) {
          if (map['password'] == password) {
            connexion = true;
          }
        }
      }
    }
    return connexion;
  }

  Future<UserModel> getUser(String email, String password) async {
    final db = await database;
    List<Map> maps = await db.query('User', columns: [
      'user_id',
      'email',
      'password',
    ]);
    if (maps.length > 0) {
      maps.forEach((map) {
        if (map['email'] == email) {
          if (map['password'] == password) {
            return map;
          }
        }
      });
    }
  }

  Future<UserModel> addUserInDB(String email, String password) async {
    final db = await database;
    int id = await db.transaction((transaction) {
      transaction.rawInsert(
          'INSERT into User(email, password) VALUES ("${email}","${password}");');
    });
    List<Map> maps = await db.query('User', columns: [
      'user_id',
      'email',
      'password',
    ]);
    maps.forEach((map) {
      if (map['email'] == email) {
        UserModel newUser = UserModel.fromMap(map);
        print('User added: ${newUser.id}');
        return newUser;
      }
    });
  }
}
