import 'package:flutter/material.dart';
import 'package:progress_saver/super_usuario.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/main.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'database_helper.dart';

class RegistroUser extends StatefulWidget {
  @override
  _RegistroUserState createState() => _RegistroUserState();
}

class _RegistroUserState extends State<RegistroUser> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController contraController = TextEditingController();

  String alertaNombre = "";
  String alertaContra = "";

  // Función de validación
  void validarCampos() {
    setState(() {
      // Validar Nombre
      final nombre = nombreController.text;
      if (nombre.isEmpty) {
        alertaNombre = "El nombre no puede estar vacío";
      } else if (!RegExp(r'^[A-ZÁÉÍÓÚÑ][A-Za-záéíóúñ0-9]*$').hasMatch(nombre)) {
        alertaNombre =
            "El nombre debe comenzar con mayúscula y puede contener números, pero no símbolos.";
      } else {
        alertaNombre = ""; // Nombre válido
      }

      // Validar Contraseña
      final contra = contraController.text;
      if (contra.isEmpty) {
        alertaContra = "La contraseña no puede estar vacía";
      } else if (contra.length < 8) {
        alertaContra = "La contraseña debe tener al menos 8 caracteres";
      } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).*$')
          .hasMatch(contra)) {
        alertaContra =
            "La contraseña debe tener al menos 1 mayúscula, 1 minúscula, 1 número, y 1 símbolo especial";
      } else {
        alertaContra = ""; // Contraseña válida
      }
    });
  }

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
        title: Text('Registro de usuario'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.05),
            // Título
            Text(
              'Registro de usuario',
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                alertaNombre,
                style: TextStyle(color: errorColor),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                alertaContra,
                style: TextStyle(color: errorColor),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                validarCampos();

                if (alertaNombre.isEmpty && alertaContra.isEmpty) {
                  // Inicializa la base de datos
                  await _dbHelper.initializeDatabase();

                  // Obtén el nombre y la contraseña del formulario
                  final username = nombreController.text;
                  final password = encryptPassword(contraController.text); // Cifra la contraseña

                  try {
                    // Intentamos insertar el usuario en la base de datos
                    await _dbHelper.insertUser(username, password);

                    // Muestra un mensaje de éxito
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Usuario registrado exitosamente'),
                    ));

                      SuperUsuario().iniciarSesion(username: username);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                    
                  } catch (e) {
                    // Si hay un error (por ejemplo, el usuario ya existe), mostramos el mensaje correspondiente
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error: El usuario ya existe'),
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

