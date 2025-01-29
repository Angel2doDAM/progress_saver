import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/main.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'database_helper.dart';

class Ajustes extends StatefulWidget {
  @override
  _AjustesState createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController contraController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  // Función para cifrar la contraseña de forma segura con SHA-256 y salt
  String encryptPassword(String password) {
    // Salt aleatorio
    final salt = 'mi_salt_secreto'; 

    // Combina el salt con la contraseña
    final passwordWithSalt = password + salt;

    // Aplicamos SHA-256
    final bytes = utf8.encode(passwordWithSalt); // Convierte la cadena a bytes
    final digest = sha256.convert(bytes); // Obtiene el hash SHA-256

    return digest.toString(); // Devuelve el hash como una cadena hexadecimal
  }

  void _showCustomAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Foto de perfil"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Elija la imagen para su usuario:"),
              SizedBox(height: 10),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Pega URL aquí",
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _dbHelper.initializeDatabase();
                String inputText = _textController.text;
                //context.read<UserProvider>().usuarioSup.setImagen(inputText);
                context.read<UserProvider>().guardarImagen(inputText);
                _dbHelper.updateUserProfileImage(context.read<UserProvider>().usuarioSup.getNombre(), inputText);
                Navigator.of(context).pop();
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: fondoColor,
      appBar: AppBar(
        backgroundColor: azulito,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => _showCustomAlert(context),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  context.read<UserProvider>().usuarioSup.getImagen() ??
                      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                ),
                radius: 20,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Ajustes',
              style: TextStyle(color: laMancha),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          ],
        ),
      ),
    );
  }
}

