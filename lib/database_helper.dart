import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:progress_saver/usuario.dart';

class DatabaseHelper {
  late Database _db;

  Future<void> initializeDatabase() async {
    // Inicializa sqflite_common_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Obtén el directorio de documentos de la aplicación
    final directory = Directory.current;
    final dbPath = join(directory.path, "base_de_datos", 'app_data.db');

    print('Database created at: $dbPath');

    // Abre la base de datos
    _db = await databaseFactory.openDatabase(dbPath);

    // Crea o actualiza la tabla de usuarios
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS Usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        isadmin INTEGER DEFAULT 0,
        profile_image TEXT
      )
    ''');

    // Comprueba si es necesario realizar una migración para añadir las columnas
    try {
      await _db
          .execute('ALTER TABLE Usuarios ADD COLUMN isadmin INTEGER DEFAULT 0');
    } catch (e) {
      print('Column "isadmin" already exists: $e');
    }

    try {
      await _db.execute('ALTER TABLE Usuarios ADD COLUMN profile_image TEXT');
    } catch (e) {
      print('Column "profile_image" already exists: $e');
    }
  }

  Future<int> insertUser(Usuario usuario) async {
    return await _db.insert('Usuarios', usuario.toMap());
  }

  Future<Usuario?> validateUser(String username, String password) async {
    final List<Map<String, dynamic>> result = await _db.query(
      'Usuarios',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first); // Retorna un objeto Usuario
    }
    return null; // Usuario no encontrado
  }

  Future<int> deleteUser(String username) async {
    return await _db.delete(
      'Usuarios',
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<bool> isUserAdmin(String username) async {
    final List<Map<String, dynamic>> result = await _db.query(
      'Usuarios',
      columns: ['isadmin'],
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result==1) {
      return true;
    }
    return false;
  }

  Future<int> updateUserProfileImage(
      String username, String profileImagePath) async {
    return await _db.update(
      'Usuarios',
      {'profile_image': profileImagePath},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<String> getUserProfileImage(String username) async {
    try {
      final List<Map<String, dynamic>> result = await _db.rawQuery(
        'SELECT profile_image FROM Usuarios WHERE username = ?',
        [username],
      );

      if (result.isNotEmpty &&
          result.first['profile_image'] != null &&
          result.first['profile_image'].isNotEmpty) {
        return result.first['profile_image'];
      }
      return "No hay foto";
    } catch (e) {
      print("Database error: $e");
      return "Error al obtener la imagen";
    }
  }

  void closeDatabase() async {
    await _db.close();
  }
}
