import 'package:flutter/material.dart';
import 'package:progress_saver/super_usuario.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/main.dart';
import 'package:crypto/crypto.dart';
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fontSize = screenWidth * 0.08; // 8% del ancho de la pantalla
    double maxButtonHeight = 80.0;
    double maxFontSize = 20.0;
    double maxTittleSize = 60.0;

    return Scaffold(
      backgroundColor: fondoColor,
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.05),
            // Título
            Text(
              'Inicio de Sesión',
              style: TextStyle(
                fontSize: fontSize > maxTittleSize ? maxTittleSize : fontSize,
                fontFamily: 'KeaniaOne',
                color: azulito,
              ),
            ),
            SizedBox(height: screenHeight * 0.1),
            // TextField para introducir el nombre
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

                if (!nombreController.text.isEmpty && !contraController.text.isEmpty) {
                  // Inicializa la base de datos
                  await _dbHelper.initializeDatabase();

                  _dbHelper.updateUserProfileImage("Admin", "https://thumbs.dreamstime.com/b/gritos-cabreados-del-hombre-58919826.jpg");

                  // Obtén el nombre y la contraseña del formulario
                  final username = nombreController.text;
                  final password = encryptPassword(contraController.text); // Cifra la contraseña
                  final photo = await _dbHelper.getUserProfileImage(username);

                  try {
                    // Intentamos insertar el usuario en la base de datos
                    if(await _dbHelper.validateUser(username, password)){
                      // Muestra un mensaje de éxito
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Usuario registrado exitosamente'),
                      ));

                      if(await _dbHelper.isUserAdmin(username)){
                        SuperUsuario().iniciarSesion(username: username, isAdmin: true, profilePictureUrl: photo.toString());
                        print(photo);
                        print(SuperUsuario().getProfilePictureUrl());
                      } else {
                        SuperUsuario().iniciarSesion(username: username, profilePictureUrl: photo.toString());
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error: Usuario o contraseña erroneos'),
                    ));
                    }
                    
                  } catch (e) {
                    // Si hay un error (por ejemplo, el usuario ya existe), mostramos el mensaje correspondiente
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error: Algo salio mal'),
                    ));
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

