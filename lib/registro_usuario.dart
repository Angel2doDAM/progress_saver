import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/main.dart';
import 'package:crypto/crypto.dart';
import 'package:progress_saver/usuario.dart';
import 'dart:convert';
import 'database_helper.dart';

class RegistroUsuario extends StatefulWidget {
  @override
  _RegistroUsuarioState createState() => _RegistroUsuarioState();
}

class _RegistroUsuarioState extends State<RegistroUsuario> {
  
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController contraController = TextEditingController();

  String alertaNombre = "";
  String alertaContra = "";

  bool esAdmin = false;

  bool validarCampos() {
    setState(() {
      final nombre = nombreController.text;
      if (nombre.isEmpty) {
        alertaNombre = "El nombre no puede estar vacío";
      } else if (!RegExp(r'^[A-ZÁÉÍÓÚÑ][a-záéíóúñ0-9]*$').hasMatch(nombre)) {
        alertaNombre =
            "El nombre debe comenzar con mayúscula y solo contener letras y números";
      } else {
        alertaNombre = "";
      }

      final contra = contraController.text;
      if (contra.isEmpty) {
        alertaContra = "La contraseña no puede estar vacía";
      } else if (contra.length < 8) {
        alertaContra = "La contraseña debe tener al menos 8 caracteres";
      } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).*$')
          .hasMatch(contra)) {
        alertaContra =
            "La contraseña debe tener al menos 1 mayúscula, minúscula, número y símbolo especial";
      } else {
        alertaContra = "";
      }
    });

    return alertaNombre.isEmpty && alertaContra.isEmpty;
  }

  String encryptPassword(String password) {
    final salt = 'mi_salt_secreto';
    final passwordWithSalt = password + salt;
    final bytes = utf8.encode(passwordWithSalt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fontSize = screenWidth * 0.08;
    double maxFontSize = 20.0;
    double maxTittleSize = 60.0;

    return Scaffold(
      backgroundColor: fondoColor,
      appBar: AppBar(
        backgroundColor: azulito,
        title: Text('Registro de Usuario'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.05),
            Text(
              'Registro de Usuario',
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
                if (validarCampos()) {
                  await _dbHelper.initializeDatabase();

                  final username = nombreController.text;
                  final password = encryptPassword(contraController.text);

                  if (await _dbHelper.userExists(username)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Usuario ya existente')),
                    );
                  } else {
                    try {
                      Usuario usuario =
                          new Usuario(username: username, password: password);
                      if (esAdmin) {
                        usuario.setIsAdmin(1);
                        usuario.setIsInicied(true);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Usuario registrado correctamente')),
                      );
                      context.read<UserProvider>().usuarioSup = usuario;

                      _dbHelper.insertUser(usuario);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: Algo salió mal')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: Corrige los campos')),
                  );
                }
              },
              child: Text('Registrar Usuario'),
            ),
          ],
        ),
      ),
    );
  }
}
