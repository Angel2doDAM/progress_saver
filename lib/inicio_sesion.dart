import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/main.dart';
import 'package:crypto/crypto.dart';
import 'package:progress_saver/usuario.dart';
import 'dart:convert';
import 'database_helper.dart';

class InicioSesion extends StatefulWidget {
  @override
  _InicioSesionState createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController contraController = TextEditingController();

  String encryptPassword(String password) {
    final salt = 'mi_salt_secreto';
    final passwordWithSalt = password + salt;
    final bytes = utf8.encode(passwordWithSalt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {

  _dbHelper.resetAllUsersInitialization();
    Usuario usuarionull = Usuario(
      username: "Anonimo",
      password: "",
      profile_image:
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png");
    context.read<UserProvider>().usuarioSup = usuarionull;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fontSize = screenWidth * 0.08;
    double maxFontSize = 20.0;
    double maxTittleSize = 60.0;

    return Scaffold(
      backgroundColor: fondoColor,
      appBar: AppBar(
        backgroundColor: azulito,
        title: Text('Inicio de Sesión'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.05),
            Text(
              'Inicio de Sesión',
              style: TextStyle(
                fontSize: fontSize > maxTittleSize ? maxTittleSize : fontSize,
                fontFamily: 'KeaniaOne',
                color: azulito,
              ),
            ),
            SizedBox(height: screenHeight * 0.1),
            Text("Introduzca su nombre de usuario:",
                style: TextStyle(
                  fontSize: screenWidth * 0.03 > maxFontSize
                      ? maxFontSize
                      : screenWidth * 0.03,
                )),
            const SizedBox(height: 8),
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                hintText: 'Nombre de usuario',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: laMancha),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: laMancha, width: 2.0),
                ),
                fillColor: azulito,
                filled: true,
              ),
            ),
            const SizedBox(height: 10),
            Text("Introduzca su contraseña:",
                style: TextStyle(
                  fontSize: screenWidth * 0.03 > maxFontSize
                      ? maxFontSize
                      : screenWidth * 0.03,
                )),
            const SizedBox(height: 8),
            TextField(
              controller: contraController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Contraseña',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                fillColor: azulito,
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (nombreController.text.isNotEmpty && contraController.text.isNotEmpty) {
                  await _dbHelper.initializeDatabase();

                  final username = nombreController.text;
                  final password = encryptPassword(contraController.text);

                  try {
                    Usuario? usuario = await _dbHelper.validateUser(username, password);
                    if (usuario != null) {
                      _dbHelper.updateUserInitialization(username, 1);
                      final photo = await _dbHelper.getUserProfileImage(username);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sesión iniciada correctamente')),
                      );

                      context.read<UserProvider>().usuarioSup = usuario;
                      context.read<UserProvider>().guardarImagen(photo);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: Usuario o contraseña incorrectos')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: Algo salió mal')),
                    );
                  }
                }
              },
              child: Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
