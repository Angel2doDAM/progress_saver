import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/view/home.dart';
import 'package:progress_saver/viewmodel/user_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:progress_saver/model/usuario.dart';
import 'dart:convert';
import '../database/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegistroUsuario extends StatefulWidget {
  @override
  _RegistroUsuarioState createState() => _RegistroUsuarioState();
}

/// Pagina para el registro de un nuevo usuario
/// 
/// En ella se introducen las credenciales:
///   Nombre
///   Contraseña
class _RegistroUsuarioState extends State<RegistroUsuario> {
  
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController contraController = TextEditingController();

  String alertaNombre = "";
  String alertaContra = "";

  bool esAdmin = false;

  /// Comprueba si el nombre y la contraseña cumplen con los requisitos
  bool validarCampos() {
    setState(() {
      final nombre = nombreController.text;
      if (nombre.isEmpty) {
        alertaNombre = AppLocalizations.of(context)!.emptyName;
      } else if (!RegExp(r'^[A-ZÁÉÍÓÚÑ][a-záéíóúñ0-9]*$').hasMatch(nombre)) {
        alertaNombre =
            AppLocalizations.of(context)!.badName;
      } else {
        alertaNombre = "";
      }

      final contra = contraController.text;
      if (contra.isEmpty) {
        alertaContra = AppLocalizations.of(context)!.emptyPassword;
      } else if (contra.length < 8) {
        alertaContra = AppLocalizations.of(context)!.passwordLong;
      } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).*$')
          .hasMatch(contra)) {
        alertaContra =
            AppLocalizations.of(context)!.badPassword;
      } else {
        alertaContra = "";
      }
    });

    return alertaNombre.isEmpty && alertaContra.isEmpty;
  }

  /// Encripta la contraseña
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

    /// Obtener si esta en modo claro u oscuro
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    /// Obtener los colores según el modo
    final fondoColor = isLightMode ? LightColors.fondoColor : DarkColors.fondoColor;
    final azulito = isLightMode ? LightColors.azulito : DarkColors.azulito;
    final botonColor = isLightMode ? LightColors.botonColor : DarkColors.botonColor;
    final laMancha = isLightMode ? LightColors.laMancha : DarkColors.laMancha;
    final errorColor = isLightMode ? LightColors.errorColor : DarkColors.errorColor;
    final logo = isLightMode ? LightColors.logo : DarkColors.logo;

    return Scaffold(
      backgroundColor: fondoColor,
      appBar: AppBar(
        backgroundColor: azulito,
        title: Text(AppLocalizations.of(context)!.userRegistration),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.05),
            /// Nombre/Titulo de la aplicacion
            Text(
              AppLocalizations.of(context)!.userRegistration,
              style: TextStyle(
                fontSize: fontSize > maxTittleSize ? maxTittleSize : fontSize,
                fontFamily: 'KeaniaOne',
                color: logo,
              ),
            ),
            SizedBox(height: screenHeight * 0.1),
            Text(AppLocalizations.of(context)!.enterNickname,
                style: TextStyle(
                  fontSize: screenWidth * 0.03 > maxFontSize
                      ? maxFontSize
                      : screenWidth * 0.03,
                )),
            const SizedBox(height: 8),
            /// Hueco para rellenar con el nombre de usuario
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.userName,
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
            /// Hueco para rellenar con la nombre del usuario
            Text(AppLocalizations.of(context)!.enterPasswd,
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
                hintText: AppLocalizations.of(context)!.password,
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
            /// Boton para enviar los datos e iniciar sesion creando el usuario
            ElevatedButton(
              onPressed: () async {
                if (validarCampos()) {
                  await _dbHelper.initializeDatabase();

                  final username = nombreController.text;
                  final password = encryptPassword(contraController.text);

                  /// Comprueba si el usuario existe e inicia sesion si asi es
                  if (await _dbHelper.userExists(username)) {
                    /// Si existe muestra un error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.existingUser)),
                    );
                  } else {
                    /// Si no existe se crea al usuario y se accede a la pestaña principal de la aplicacion
                    try {
                      Usuario usuario =
                          new Usuario(username: username, password: password);
                      if (esAdmin) {
                        usuario.setIsAdmin(1);
                        usuario.setIsInicied(true);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!.correctUser)),
                      );
                      context.read<UserProvider>().usuarioSup = usuario;

                      _dbHelper.insertUser(usuario);
                      _dbHelper.setIsInicied(username);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.somethingWrong)),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.errorCorrectFields)),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.registerUser),
              style: ElevatedButton.styleFrom(
                backgroundColor: botonColor,  /// Color del botón
              ),
            ),
          ],
        ),
      ),
    );
  }
}
