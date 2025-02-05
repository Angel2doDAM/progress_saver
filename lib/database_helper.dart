import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:progress_saver/usuario.dart';
import 'package:progress_saver/ejercicio.dart';

class DatabaseHelper {
  late Database _database;

  // Inicializar la base de datos única
  Future<void> initializeDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final directory = Directory.current;
    final dbPath = join(directory.path, "base_de_datos", 'progress_saver.db');
    _database = await databaseFactory.openDatabase(dbPath);

    // Crear tablas dentro de la misma base de datos
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
);

    ''');
  }

  // Insertar un usuario
  Future<int> insertUser(Usuario usuario) async {
    return await _database.insert('Usuarios', usuario.toMap());
  }

  // Obtener el ID de un usuario por su nombre
  Future<int?> getUserIdByUsername(String username) async {
    final result = await _database.query(
      'Usuarios',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isNotEmpty ? result.first['id'] as int : null;
  }

   // Devuelve true si encontró al menos un usuario con ese nombre
  Future<bool> userExists(String username) async {
  final result = await _database.query(
    'Usuarios',
    columns: ['id'],
    where: 'username = ?',
    whereArgs: [username],
  );

  return result.isNotEmpty;
  }

  // Método para actualizar el estado de inicialización de un usuario
  Future<int> updateUserInitialization(String username, int isInicied) async {
    return await _database.update(
      'Usuarios',
      {'isInicied': isInicied},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // Método para establecer isInicied en 0 para todos los usuarios
  Future<int> resetAllUsersInitialization() async {
    return await _database.update(
      'Usuarios',
      {'isInicied': 0},
    );
  }


  // Validar un usuario
  Future<Usuario?> validateUser(String username, String password) async {
    final result = await _database.query(
      'Usuarios',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? Usuario.fromMap(result.first) : null;
  }

  // Eliminar un usuario
  Future<int> deleteUser(String username) async {
    return await _database.delete('Usuarios', where: 'username = ?', whereArgs: [username]);
  }

  // Verificar si un usuario es admin
  Future<bool> isUserAdmin(String username) async {
    final result = await _database.query(
      'Usuarios',
      columns: ['isadmin'],
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty && result.first['isadmin'] == 1;
  }

  // Actualizar imagen de perfil de usuario
  Future<int> updateUserProfileImage(String username, String profileImagePath) async {
    return await _database.update(
      'Usuarios',
      {'profile_image': profileImagePath},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // Obtener imagen de perfil de usuario
  Future<String> getUserProfileImage(String username) async {
    final List<Map<String, dynamic>> result = await _database.rawQuery(
      'SELECT profile_image FROM Usuarios WHERE username = ?',
      [username],
    );

    return result.isNotEmpty && result.first['profile_image'] != null && result.first['profile_image'].isNotEmpty
        ? result.first['profile_image']
        : "No hay foto";
  }

  // Insertar ejercicio
  Future<int> insertEjer(Ejercicio ejercicio) async {
    return await _database.insert('Ejercicios', ejercicio.toMap());
  }

  Future<void> insertarEjerciciosDeEjemplo() async {
  List<Ejercicio> ejerciciosEjemplo = [
    Ejercicio(
      ejername: "Press de Banca", 
      ejercice_image: "https://static.strengthlevel.com/images/exercises/bench-press/bench-press-800.jpg",
    ),
    Ejercicio(
      ejername: "Sentadilla", 
      ejercice_image: "https://static.strengthlevel.com/images/exercises/squat/squat-800.jpg",
    ),
    Ejercicio(
      ejername: "Peso Muerto", 
      ejercice_image: "https://static.strengthlevel.com/images/exercises/sumo-deadlift/sumo-deadlift-800.jpg",
    ),
    Ejercicio(
      ejername: "Remo", 
      ejercice_image: "https://static.strengthlevel.com/images/exercises/machine-row/machine-row-800.jpg",
    ),
    Ejercicio(
      ejername: "Curl con Barra", 
      ejercice_image: "https://static.strengthlevel.com/images/exercises/barbell-curl/barbell-curl-800.jpg",
    ),
  ];

  for (var ejercicio in ejerciciosEjemplo) {
    await insertEjer(ejercicio);
  }

}


  // Actualizar ejercicio
  Future<int> updateEjer(String ejernameOld, String ejernameNew, String ejerImagePath) async {
    return await _database.update(
      'Ejercicios',
      {'ejername': ejernameNew, 'ejercice_image': ejerImagePath},
      where: 'ejername = ?',
      whereArgs: [ejernameOld],
    );
  }

  // Obtener un ejercicio por su ID
  Future<Map<String, dynamic>?> getExerciseById(int id) async {
    final result = await _database.query(
      'Ejercicios',
      where: 'id = ?',
      whereArgs: [id],
    );

    return result.isNotEmpty ? result.first : null;
  }

  // Eliminar ejercicio
  Future<int> deleteEjer(String ejername) async {
    return await _database.delete('Ejercicios', where: 'ejername = ?', whereArgs: [ejername]);
  }

  // Obtener todos los ejercicios
  Future<List<Map<String, dynamic>>> getAllExercises() async {
    return await _database.query('Ejercicios');
  }

  // Asignar ejercicio a un usuario
  Future<int> assignExerciseToUser(int userId, int ejerId) async {
    return await _database.insert('UsuarioEjercicio', {'user_id': userId, 'ejer_id': ejerId});
  }

  // Asignar ejercicio a un usuario con peso y fecha
  Future<int> assignExerciseToUserWithDetails(int userId, int ejerId, int peso) async {
    peso ??= 0;
    String fecha = DateTime.now().toString();
    Map<String, dynamic> data = {
      'user_id': userId,
      'ejer_id': ejerId,
      'peso': peso,
      'fecha': fecha,
    };

    // Insertar los datos en la tabla UsuarioEjercicio
    return await _database.insert('UsuarioEjercicio', data);
  }


  // Eliminar ejercicio asignado a un usuario
  Future<int> removeExerciseFromUser(int userId, int ejerId) async {
    return await _database.delete(
      'UsuarioEjercicio',
      where: 'user_id = ? AND ejer_id = ?',
      whereArgs: [userId, ejerId],
    );
  }

  // Obtener ejercicios de un usuario
  Future<List<int>> getExercisesByUser(int userId) async {
    final result = await _database.query(
      'UsuarioEjercicio',
      columns: ['ejer_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((row) => row['ejer_id'] as int).toList();
  }

  // Cerrar base de datos
  Future<void> closeDatabase() async {
    await _database.close();
  }

  Future<List<Map<String, dynamic>>> getExercisesWithWeightByUser(int userId) async {
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


}
