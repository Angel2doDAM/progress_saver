import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/viewmodel/user_provider.dart';
import 'package:progress_saver/view/home.dart';
import 'package:crypto/crypto.dart';
import 'package:progress_saver/model/usuario.dart';
import 'dart:convert';
import '../database/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InicioSesion extends StatefulWidget {
  @override
  _InicioSesionState createState() => _InicioSesionState();
}

/// Pagina para el inicio de sesion
/// 
/// En ella se introducen las credenciales:
///   Nombre
///   Contraseña
class _InicioSesionState extends State<InicioSesion> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController contraController = TextEditingController();

  /// Funcion que cifra la contraseña para que no se pueda acceder a ella desde los archivos
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

    /// Identifica si la aplicacion esta en modo claro u oscuro
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    /// Obtener los colores según el modo
    final fondoColor = isLightMode ? LightColors.fondoColor : DarkColors.fondoColor;
    final azulito = isLightMode ? LightColors.azulito : DarkColors.azulito;
    final botonColor = isLightMode ? LightColors.botonColor : DarkColors.botonColor;
    final laMancha = isLightMode ? LightColors.laMancha : DarkColors.laMancha;
    final logo = isLightMode ? LightColors.logo : DarkColors.logo;

    return Scaffold(
      backgroundColor: fondoColor,
      appBar: AppBar(
        backgroundColor: azulito,
        title: Text(AppLocalizations.of(context)!.sessionInit),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.05),
            /// Nombre/Titulo de la aplicacion
            Text(
              AppLocalizations.of(context)!.sessionInit,
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
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.enterPasswd,
                style: TextStyle(
                  fontSize: screenWidth * 0.03 > maxFontSize
                      ? maxFontSize
                      : screenWidth * 0.03,
                )),
            const SizedBox(height: 8),
            /// Hueco para rellenar con la nombre del usuario
            TextField(
              controller: contraController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.password,
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
            const SizedBox(height: 20),
            /// Boton para enviar los datos e iniciar sesion
            ElevatedButton(
              onPressed: () async {
                if (nombreController.text.isNotEmpty && contraController.text.isNotEmpty) {
                  await _dbHelper.initializeDatabase();

                  final username = nombreController.text;
                  final password = encryptPassword(contraController.text);

                  try {
                    /// Comprueba si el usuario existe e inicia sesion si asi es
                    Usuario? usuario = await _dbHelper.validateUser(username, password);
                    if (usuario != null) {
                      _dbHelper.updateUserInitialization(username, 1);
                      final photo = await _dbHelper.getUserProfileImage(username);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.successfullyLogged)),
                      );

                      context.read<UserProvider>().usuarioSup = usuario;
                      context.read<UserProvider>().guardarImagen(photo);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.erroneousUser)),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.somethingWrong)),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: botonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
