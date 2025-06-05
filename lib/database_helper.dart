import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'task_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            isCompleted INTEGER
          )
        ''');
      },
    );
  }


  // insert user new task
  Future<int> insertTask(String title) async {
    final dbClient = await db;
    return await dbClient.insert(
      'tasks',
      {'title': title, 'isCompleted': 0},
    );
  }


  //get all tasks to display
  Future<List<Map<String, dynamic>>> getTasks() async {
    final dbClient = await db;
    return await dbClient.query('tasks');
  }

 // update a task
    
  Future<int> updateTask(int id, int isCompleted) async {
    final dbClient = await db;
    return await dbClient.update(
      'tasks',
      {'isCompleted': isCompleted},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
//delete a tesk
  Future<int> deleteTask(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
