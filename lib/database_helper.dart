import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:progress_saver/usuario.dart';
import 'package:progress_saver/ejercicio.dart';

class DatabaseHelper {
  late Database _dbUsuarios;
  late Database _dbEjercicios;
  late Database _dbUsuarioEjercicio;

  // Inicializar base de datos de Usuarios
  Future<void> initializeUsuariosDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final directory = Directory.current;
    final dbUsuariosPath = join(directory.path, "base_de_datos", 'usuarios.db');
    _dbUsuarios = await databaseFactory.openDatabase(dbUsuariosPath);

    await _dbUsuarios.execute('''
      CREATE TABLE IF NOT EXISTS Usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        isadmin INTEGER DEFAULT 0,
        profile_image TEXT
      )
    ''');
  }

  // Insertar un usuario
  Future<int> insertUser(Usuario usuario) async {
    return await _dbUsuarios.insert('Usuarios', usuario.toMap());
  }

  // Obtener el ID de un usuario por su nombre
  Future<int?> getUserIdByUsername(String username) async {
    final result = await _dbUsuarios.query(
      'Usuarios',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
    );

    // Si el usuario existe, devolver su ID, si no, devolver null
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    return null; // Si no se encuentra el usuario
  }

  // Validar un usuario
  Future<Usuario?> validateUser(String username, String password) async {
    final result = await _dbUsuarios.query(
      'Usuarios',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? Usuario.fromMap(result.first) : null;
  }

  // Eliminar un usuario
  Future<int> deleteUser(String username) async {
    return await _dbUsuarios.delete('Usuarios', where: 'username = ?', whereArgs: [username]);
  }

  // Verificar si un usuario es admin
  Future<bool> isUserAdmin(String username) async {
    final result = await _dbUsuarios.query(
      'Usuarios',
      columns: ['isadmin'],
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty && result.first['isadmin'] == 1;
  }

  // Actualizar imagen de perfil de usuario
  Future<int> updateUserProfileImage(String username, String profileImagePath) async {
    return await _dbUsuarios.update(
      'Usuarios',
      {'profile_image': profileImagePath},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // Obtener imagen de perfil de usuario
  Future<String> getUserProfileImage(String username) async {
    final List<Map<String, dynamic>> result = await _dbUsuarios.rawQuery(
      'SELECT profile_image FROM Usuarios WHERE username = ?',
      [username],
    );

    if (result.isNotEmpty && result.first['profile_image'] != null && result.first['profile_image'].isNotEmpty) {
      return result.first['profile_image'];
    }
    return "No hay foto";
  }

  // Inicializar base de datos de Ejercicios
  Future<void> initializeEjerciciosDatabase() async {
    final directory = Directory.current;
    final dbEjerciciosPath = join(directory.path, "base_de_datos", 'ejercicios.db');
    _dbEjercicios = await databaseFactory.openDatabase(dbEjerciciosPath);

    await _dbEjercicios.execute('''
      CREATE TABLE IF NOT EXISTS Ejercicios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ejername TEXT UNIQUE,
        ejercice_image TEXT
      )
    ''');
  }

  // Insertar ejercicio
  Future<int> insertEjer(Ejercicio ejercicio) async {
    return await _dbEjercicios.insert('Ejercicios', ejercicio.toMap());
  }

  // Actualizar ejercicio
  Future<int> updateEjer(String ejernameOld, String ejernameNew, String ejerImagePath) async {
    return await _dbEjercicios.update(
      'Ejercicios',
      {'ejername': ejernameNew, 'ejercice_image': ejerImagePath},
      where: 'ejername = ?',
      whereArgs: [ejernameOld],
    );
  }

  // Obtener un ejercicio por su ID
Future<Map<String, dynamic>?> getExerciseById(int id) async {
  final result = await _dbEjercicios.query(
    'Ejercicios',
    where: 'id = ?',
    whereArgs: [id],
  );

  // Si el ejercicio existe, devolver los detalles, sino, devolver null
  if (result.isNotEmpty) {
    return result.first;  // Devuelve el primer (y único) registro encontrado
  }
  return null;  // Si no se encuentra el ejercicio
}


  // Eliminar ejercicio
  Future<int> deleteEjer(String ejername) async {
    return await _dbEjercicios.delete('Ejercicios', where: 'ejername = ?', whereArgs: [ejername]);
  }

  // Obtener todos los ejercicios
  Future<List<Map<String, dynamic>>> getAllExercises() async {
    return await _dbEjercicios.query('Ejercicios');
  }

  // Inicializar base de datos de UsuarioEjercicio
  Future<void> initializeUsuarioEjercicioDatabase() async {
    final directory = Directory.current;
    final dbUsuarioEjercicioPath = join(directory.path, "base_de_datos", 'usuario_ejercicio.db');
    _dbUsuarioEjercicio = await databaseFactory.openDatabase(dbUsuarioEjercicioPath);

    await _dbUsuarioEjercicio.execute('''
      CREATE TABLE IF NOT EXISTS UsuarioEjercicio (
        user_id INTEGER,
        ejer_id INTEGER,
        PRIMARY KEY (user_id, ejer_id),
        FOREIGN KEY (user_id) REFERENCES Usuarios(id) ON DELETE CASCADE,
        FOREIGN KEY (ejer_id) REFERENCES Ejercicios(id) ON DELETE CASCADE
      )
    ''');
  }

  // Asignar ejercicio a un usuario
  Future<int> assignExerciseToUser(int userId, int ejerId) async {
    return await _dbUsuarioEjercicio.insert('UsuarioEjercicio', {'user_id': userId, 'ejer_id': ejerId});
  }

  // Eliminar ejercicio asignado a un usuario
  Future<int> removeExerciseFromUser(int userId, int ejerId) async {
    return await _dbUsuarioEjercicio.delete(
      'UsuarioEjercicio',
      where: 'user_id = ? AND ejer_id = ?',
      whereArgs: [userId, ejerId],
    );
  }

  // Obtener ejercicios de un usuario
  Future<List<int>> getExercisesByUser(int userId) async {
    final result = await _dbUsuarioEjercicio.query(
      'UsuarioEjercicio',
      columns: ['ejer_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((row) => row['ejer_id'] as int).toList();
  }

  // Cerrar base de datos de Usuarios
  Future<void> closeUsuariosDatabase() async {
    await _dbUsuarios.close();
  }

  // Cerrar base de datos de Ejercicios
  Future<void> closeEjerciciosDatabase() async {
    await _dbEjercicios.close();
  }

  // Cerrar base de datos de UsuarioEjercicio
  Future<void> closeUsuarioEjercicioDatabase() async {
    await _dbUsuarioEjercicio.close();
  }
}
