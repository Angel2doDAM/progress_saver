import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  late Database _db;

  Future<void> initializeDatabase() async {
    // Inicializa sqflite_common_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Obtén el directorio de documentos de la aplicación
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = join(directory.path, 'app_data.db');

    print('Database created at: $dbPath');

    // Abre la base de datos
    _db = await databaseFactory.openDatabase(dbPath);

    // Crea o actualiza la tabla de usuarios
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS Usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        isadmin INTEGER DEFAULT 0
      )
    ''');

    // Comprueba si es necesario realizar una migración para añadir la columna
    try {
      await _db.execute('ALTER TABLE Usuarios ADD COLUMN isadmin INTEGER DEFAULT 0');
    } catch (e) {
      // Ignorar el error si la columna ya existe
      print('Column "isadmin" already exists: $e');
    }
  }

  Future<int> insertUser(String username, String password, {bool isAdmin = true}) async {
    if (username=="Admin"){
      isAdmin=true;
    }
    return await _db.insert('Usuarios', {
      'username': username,
      'password': password,
      'isadmin': isAdmin ? 1 : 0, // Convierte bool a int para SQLite
    });
  }

  Future<int> deleteUser(String username) async {
    return await _db.delete(
      'Usuarios',
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<bool> validateUser(String username, String password) async {
    final List<Map<String, dynamic>> result = await _db.query(
      'Usuarios',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  Future<bool> isUserAdmin(String username) async {
    final List<Map<String, dynamic>> result = await _db.query(
      'Usuarios',
      columns: ['isadmin'],
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      return result.first['isadmin'] == 1; // Devuelve true si el usuario es administrador
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    return await _db.query('Usuarios');
  }

  void closeDatabase() async {
    await _db.close();
  }
}
