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

                  // Obtén el nombre y la contraseña del formulario
                  final username = nombreController.text;
                  final password = encryptPassword(contraController.text); // Cifra la contraseña

                  try {
                    // Intentamos insertar el usuario en la base de datos
                    Usuario? usuario = await _dbHelper.validateUser(username, password);
                    if(usuario!=null){
                      final photo = await _dbHelper.getUserProfileImage(username);
                      // Muestra un mensaje de éxito
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Sesion iniciada placenteramente'),
                      ));

                      context.read<UserProvider>().usuarioSup = usuario;
                      context.read<UserProvider>().guardarImagen(photo);

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

