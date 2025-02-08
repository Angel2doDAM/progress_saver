import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:progress_saver/model/usuario.dart';
import 'package:progress_saver/model/ejercicio.dart';

class DatabaseHelper {
  static late Database _database; /// Instancia de la base de datos

  /// Método que inicializa la base de datos
  /// 
  /// Configura el entorno SQLite
  /// Crea las tablas necesarias si no existen
  Future<void> initializeDatabase() async {
     // Inicializa sqflite para entorno FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Especifica la ruta para la base de datos
    final directory = Directory.current;
    final dbPath = join(directory.path, "base_de_datos", 'progress_saver.db');
    _database = await databaseFactory.openDatabase(dbPath);

    /// Crea las tablas si no existen
    /// 
    /// Usuarios
    /// Ejercicios
    /// UsuarioEjercicio
    await _database.execute(''' 
      CREATE TABLE IF NOT EXISTS Usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        isadmin INTEGER DEFAULT 0,
        profile_image TEXT,
        isInicied INTEGER DEFAULT 0
      )
    ''');

    await _database.execute(''' 
      CREATE TABLE IF NOT EXISTS Ejercicios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ejername TEXT UNIQUE,
        ejercice_image TEXT
      )
    ''');

    await _database.execute(''' 
      CREATE TABLE IF NOT EXISTS UsuarioEjercicio (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        ejer_id INTEGER,
        peso INTEGER,
        fecha TEXT,
        FOREIGN KEY (user_id) REFERENCES Usuarios(id) ON DELETE CASCADE,
        FOREIGN KEY (ejer_id) REFERENCES Ejercicios(id) ON DELETE CASCADE
      )
    ''');

  }

  /// Método que inserta un nuevo usuario en la base de datos
  Future<int> insertUser(Usuario usuario) async {
    return await _database.insert('Usuarios', usuario.toMap());
  }

  /// Método que obtiene el ID de un usuario dado su nombre de usuario
  Future<int?> getUserIdByUsername(String username) async {
    final result = await _database.query(
      'Usuarios',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isNotEmpty ? result.first['id'] as int : null;
  }

  /// Método que verifica si un usuario ya existe en la base de datos
  Future<bool> userExists(String username) async {
    final result = await _database.query(
      'Usuarios',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isNotEmpty;
  }

  /// Método que actualiza si un usuario esta iniciado o no
  Future<int> updateUserInitialization(String username, int isInicied) async {
    return await _database.update(
      'Usuarios',
      {'isInicied': isInicied},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  /// Método que resetea todos los usuarios a estado no inicializado
  Future<int> resetAllUsersInitialization() async {
    return await _database.update(
      'Usuarios',
      {'isInicied': 0},
    );
  }

  /// Método que marca un usuario como inicializado
  Future<int> setIsInicied(String username) async {
    return await _database.update(
      'Usuarios',
      {'isInicied': 1},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  /// Método que valida el usuario y contraseña
  /// 
  /// Devuelve el objeto Usuario si es válido
  Future<Usuario?> validateUser(String username, String password) async {
    final result = await _database.query(
      'Usuarios',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? Usuario.fromMap(result.first) : null;
  }

  /// Método que elimina un usuario por su nombre
  Future<int> deleteUser(String username) async {
    return await _database
        .delete('Usuarios', where: 'username = ?', whereArgs: [username]);
  }

  /// Método que obtiene el usuario iniciado
  Future<Usuario?> getUserWithIsInicied() async {
    final result = await _database.query(
      'Usuarios',
      where: 'isInicied = ?',
      whereArgs: [1],
      limit: 1,
    );

    return result.isNotEmpty ? Usuario.fromMap(result.first) : null;
  }

  /// Método que actualiza la imagen de perfil de un usuario
  Future<int> updateUserProfileImage(
      String username, String profileImagePath) async {
    return await _database.update(
      'Usuarios',
      {'profile_image': profileImagePath},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  /// Método que obtiene la imagen de perfil de un usuario
  Future<String> getUserProfileImage(String username) async {
    final List<Map<String, dynamic>> result = await _database.rawQuery(
      'SELECT profile_image FROM Usuarios WHERE username = ?',
      [username],
    );

    return result.isNotEmpty &&
            result.first['profile_image'] != null &&
            result.first['profile_image'].isNotEmpty
        ? result.first['profile_image']
        : "No hay foto";
  }

  /// Método que inserta un nuevo ejercicio
  Future<int> insertEjer(Ejercicio ejercicio) async {
    return await _database.insert('Ejercicios', ejercicio.toMap());
  }

  /// Método que obtiene un ejercicio por su nombre
  Future<Map<String, dynamic>?> getExerciseByName(String name) async {
    final result = await _database.query(
      'Ejercicios',
      where: 'ejername = ?',
      whereArgs: [name],
    );

    return result.isNotEmpty ? result.first : null;
  }

  /// Método que asigna un ejercicio a un usuario
  Future<int> assignExerciseToUser(
      int userId, int ejerId, int peso, DateTime dateTime) async {
    peso ??= 0;
    String fecha = DateTime.now().toString();
    Map<String, dynamic> data = {
      'user_id': userId,
      'ejer_id': ejerId,
      'peso': peso,
      'fecha': fecha,
    };

    return await _database.insert('UsuarioEjercicio', data);
  }

  /// Método que elimina un ejercicio asignado a un usuario
  Future<int> removeExerciseFromUser(int userId, int ejerId) async {
    return await _database.delete(
      'UsuarioEjercicio',
      where: 'user_id = ? AND ejer_id = ?',
      whereArgs: [userId, ejerId],
    );
  }

  /// Método que elimina todos los ejercicios asignados a un usuario
  Future<int> removeAllExercisesFromUser(int userId) async {
    return await _database.delete(
      'UsuarioEjercicio',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Método que obtiene los ejercicios y sus pesos más recientes asignados a un usuario
  Future<List<Map<String, dynamic>>> getExercisesWithWeightByUser(
      int userId) async {
    final result = await _database.rawQuery(''' 
    SELECT e.id, e.ejername, e.ejercice_image, ue.peso 
    FROM UsuarioEjercicio ue 
    JOIN Ejercicios e ON ue.ejer_id = e.id 
    WHERE ue.user_id = ? 
    AND ue.fecha = (
      SELECT MAX(fecha) 
      FROM UsuarioEjercicio 
      WHERE user_id = ue.user_id AND ejer_id = ue.ejer_id
    )
  ''', [userId]);

    return result;
  }

  /// Método que obtiene una lista de ejercicios que no han sido asignados a un usuario específico
  Future<List<Map<String, dynamic>>> getExercisesNotAssignedToUser(
      int userId) async {
    final result = await _database.rawQuery(''' 
      SELECT * FROM Ejercicios 
      WHERE id NOT IN (
        SELECT DISTINCT ejer_id FROM UsuarioEjercicio 
        WHERE user_id = ?
      )
    ''', [userId]);

    return result;
  }
}
