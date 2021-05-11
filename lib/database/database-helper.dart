
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:real_goalkeeper/models/overview.dart';
import 'package:real_goalkeeper/models/session.dart';
import 'package:path/path.dart';
import 'package:real_goalkeeper/models/workout.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper{

  static const _databaseName = 'GoalKeep.db';
  static const _databaseVersion = 1;

  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database _database;

  Future<Database> get database async{
    if(_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async{
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    print('db location: ' + dataDirectory.path);
    String dbPath = join(dataDirectory.path,_databaseName);
    return await openDatabase(dbPath, version:_databaseVersion, onCreate:_onCreateDB);
  }

_onCreateDB(Database db, int version) async {
    await db.execute(
        '''
      CREATE TABLE Session(
        ${Session.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Session.colName} TEXT
        )
  
        ''');
  }

  void createPR(String wkName) async{
    if (wkName != null) {
      Database db = await database;
      await db.execute(
          '''
      CREATE TABLE $wkName(
        ${Workout.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Workout.colName} TEXT,
        ${Workout.colSet} TEXT,
        ${Workout.colWeight} TEXT,
        ${Workout.colRep} TEXT,
        ${Workout.colDate} TEXT
        )
        ''');
    }
  }

  void createWorkout(String wkName) async {
    if (wkName != null) {
      Database db = await database;
      await db.execute(
          '''
      CREATE TABLE $wkName(
        ${Workout.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Workout.colName} TEXT,
        ${Workout.colSet} TEXT,
        ${Workout.colWeight} TEXT,
        ${Workout.colRep} TEXT,
        ${Workout.colDate} TEXT
        )
        ''');
    }
  }

  void createOverviewTable() async{
    Database db = await database;
    await db.execute(
        '''
    CREATE TABLE Overview(
      ${Overview.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Overview.colSession} TEXT,
      ${Overview.colWorkout} TEXT
      )
      ''');
  }

  Future<int> insertSession(Session session) async{
    Database db = await database;
    return await db.insert('Session', session.toMap());
  }

  Future<int> insertWorkout(String wkName, Workout workout) async {
    Database db = await database;
    return await db.insert(wkName, workout.toMap());
  }

  Future<int> insertOverview(Overview overview) async {
    Database db = await database;
    return await db.insert('Overview', overview.toMap());
  }

  Future<int> updateSession(Session session) async{
    Database db = await database;
    return await db.update('Session', session.toMap(),
        where: '${Workout.colId} = ?', whereArgs: [session.id]);
  }

  Future<int> updateWorkout(String wkName, Workout workout) async{
    Database db = await database;
    return await db.update(wkName, workout.toMap(),
        where: '${Workout.colId} = ?', whereArgs: [workout.id]);
  }

  Future<List<String>> getAllWorkouts() async{
    Database db = await database;
    List<String> tableNamesReal;
    var tableNames = (await db
        .query('sqlite_master', where: 'type = ?', whereArgs: ['table']))
        .map((row) => row['name'] as String)
        .toList(growable: false);
    return tableNames;
  }

  Future<int> deleteSession(int id)async{
    Database db = await database;
    return await db.delete('Session',
        where: '${Session.colId} = ?', whereArgs: [id]);
  }

  Future<int> deleteOverview(int id)async{
    Database db = await database;
    return await db.delete('Overview',
        where: '${Overview.colId} = ?', whereArgs: [id]);
  }

  Future<void> altDeleteSession(String session)async{
    Database db = await database;
    await db.execute('DELETE FROM Session WHERE ${Session.colName} = $session;');
  }

  Future<void> altDeleteOverview(String session) async {
    Database db = await database;
    List<Map> dSessions = await db.query('Overview');
    List<Overview> s = dSessions.map((e) => Overview.fromMap(e)).toList();
    for (int i = 0; i < s.length; i++){
      if(s[i].session == session) {
        await db.execute('DROP TABLE ${s[i].workout}');
      }
    }
    await db.execute('DELETE FROM ${Overview.colTbl} WHERE ${Overview.colSession} = "$session"');
  }

  Future<int> deleteWorkout(String wkName, int id)async{
    Database db = await database;
    return await db.delete(wkName,
        where: '${Workout.colId} = ?', whereArgs: [id]);
  }

  Future<List<Session>> fetchSession() async{
    Database db = await database;
    List<Map> sessions = await db.query('Session');
    return sessions.length == 0
        ?[]
        :sessions.map((e) => Session.fromMap(e)).toList();
  }

  Future<List<Overview>> fetchOverview() async{
    Database db = await database;
    List<Map> overviews = await db.query(Overview.colTbl);
    return overviews.length == 0
        ?[]
        :overviews.map((e) => Overview.fromMap(e)).toList();
  }

  Future<List<Workout>> fetchWorkout(String wkName) async{
    Database db = await database;
    List<Map> wks = await db.query(wkName);
    return wks.length == 0
        ?[]
        :wks.map((e) => Workout.fromMap(e)).toList();
  }

  Future<void> deleteAllSession() async{
    Database db = await database;
    await db.execute('DROP TABLE IF EXISTS Session');
  }

  Future<void> deleteAllWorkouts(String wkName) async{
    Database db = await database;
    List<Map> dSessions = await db.query('Overview');
    List<Overview> s = dSessions.map((e) => Overview.fromMap(e)).toList();
    for (int i = 0; i < s.length; i++){
      if(s[i].workout == wkName) {
        await db.execute('DELETE FROM Overview WHERE workout = "$wkName"');
      }
    }
    await db.execute('DROP TABLE IF EXISTS $wkName');
  }

}