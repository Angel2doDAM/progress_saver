import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/viewmodel/user_provider.dart';
import '../database/database_helper.dart';
import 'package:progress_saver/view/inicio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class Perfil extends StatefulWidget {
  @override
  _PerfilState createState() => _PerfilState();
}

/// Pagina para la gestion de usuario
/// 
/// En ella se gestiona:
///   Foto de usuario
///   Cerrar sesion
///   Eliminar cuenta
class _PerfilState extends State<Perfil> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _textController = TextEditingController();

// Muestera una alerta con la confirmacion de si realmente se quiere eliminar la cuenta de usuario
void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDeleteAccount),
          content: Text(AppLocalizations.of(context)!.areYouSure),
          actions: [
            TextButton(
              onPressed: () async {
                await _dbHelper.resetAllUsersInitialization();
                int? userId = await _dbHelper.getUserIdByUsername(
                    context.read<UserProvider>().usuarioSup.getNombre());
                if (userId != null) {
                  await _dbHelper.removeAllExercisesFromUser(userId);
                }
                await _dbHelper.deleteUser(
                    context.read<UserProvider>().usuarioSup.getNombre());
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Inicio()));
              },
              child: Text(AppLocalizations.of(context)!.yes),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.no),
            ),
          ],
        );
      },
    );
  }

// Muestra una alerta para introducir la URL de la imagen de foto de perfil
void _showCustomAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.profilePhoto),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.choseImage),
              SizedBox(height: 10),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: AppLocalizations.of(context)!.pasteUrl,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                try {
                  Uri uri = Uri.parse(_textController.text);
                  if ((await get(uri)).statusCode == 200) {
                    await _dbHelper.initializeDatabase();
                    String inputText = _textController.text;

                    /// Actualiza la imagen en UserProvider
                    context.read<UserProvider>().guardarImagen(inputText);

                    /// Actualiza la imagen en la base de datos
                    await _dbHelper.updateUserProfileImage(
                        context.read<UserProvider>().usuarioSup.getNombre(),
                        inputText);

                    setState(() {});
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  setState(() {});
                }
              },
              child: Text(AppLocalizations.of(context)!.accept),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Obtiene las medidas de la pantalla para su uso en cuanto a widgets
    double screenWidth = MediaQuery.of(context).size.width;

    double fontSize = screenWidth * 0.04;
    double tittleSize = screenWidth * 0.08;
    double logoSize = screenWidth * 0.1;
    double columnSize = screenWidth * 0.5;

    double maxFontSize = 20.0;
    double maxTittleSize = 30.0;
    double maxLogoSize = 100.0;

    /// Obtiene si la aplicacion se encuentra en modo claro u oscuro
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    /// Define los colores segun el modo actual
    final fondoColor = isLightMode ? LightColors.fondoColor : DarkColors.fondoColor;
    final azulito = isLightMode ? LightColors.azulito : DarkColors.azulito;
    final botonColor = isLightMode ? LightColors.botonColor : DarkColors.botonColor;
    final laMancha = isLightMode ? LightColors.laMancha : DarkColors.laMancha;
    final navegacion = isLightMode ? LightColors.navegacion : DarkColors.navegacion;
    final logo = isLightMode ? LightColors.logo : DarkColors.logo;
    return Scaffold(
      backgroundColor: fondoColor,
      appBar: AppBar(
        backgroundColor: azulito,
        elevation: 0,
        title: Row(
          children: [
            /// Muestra la imagen de usuario y permite cambiarla mediante un alert al que se accede clicando
            GestureDetector(
              onTap: () => _showCustomAlert(context),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  context.read<UserProvider>().usuarioSup.getImagen(),
                ),
                radius: 20,
              ),
            ),
            SizedBox(width: 10),
            /// Muestra el nombre de usuario
            Text(
              context.watch<UserProvider>().usuarioSup.getNombre(),
              style: TextStyle(color: laMancha),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Container(
            width: columnSize,
            color: botonColor,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.session,
                    style: TextStyle(
                        fontSize: tittleSize > maxTittleSize
                            ? maxTittleSize
                            : tittleSize,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                /// Boton para cerrar sesion
                ElevatedButton(
                    onPressed: () async {
                      /// Establece todos los usuarios como "no iniciados"
                      await _dbHelper.resetAllUsersInitialization();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Inicio()));
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: navegacion),
                    child: Text(AppLocalizations.of(context)!.logout,
                        style: TextStyle(
                          color: azulito,
                            fontSize:
                                fontSize > maxFontSize ? maxFontSize : fontSize,
                            fontWeight: FontWeight.bold))),
                SizedBox(height: 20),
                /// Boton para eliminar la cuenta
                ElevatedButton(
                    onPressed: () async {
                      /// Muestra la alerta de confirmacion
                      _showDeleteConfirmationDialog(context);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: navegacion),
                    child: Text(AppLocalizations.of(context)!.deleteAcount,
                        style: TextStyle(
                            color: azulito,
                            fontSize:
                                fontSize > maxFontSize ? maxFontSize : fontSize,
                            fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          /// Parte de la derecha con el titulo
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Nombre/Titulo de la aplicacion
                    Text(
                      AppLocalizations.of(context)!.tit,
                      style: TextStyle(
                        fontSize:
                            logoSize > maxLogoSize ? maxLogoSize : logoSize,
                        fontFamily: 'KeaniaOne',
                        color: logo,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.tle,
                      style: TextStyle(
                        fontSize:
                            logoSize > maxLogoSize ? maxLogoSize : logoSize,
                        fontFamily: 'KeaniaOne',
                        color: logo,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
