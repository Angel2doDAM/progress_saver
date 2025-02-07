import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/viewmodel/user_provider.dart';
import 'package:progress_saver/viewmodel/language_provider.dart';
import 'package:progress_saver/viewmodel/theme_provider.dart';
import '../database/database_helper.dart';
import 'package:http/http.dart';
import 'package:progress_saver/view/inicio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Ajustes extends StatefulWidget {
  @override
  _AjustesState createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController contraController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

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

                    // Actualiza la imagen en UserProvider
                    context.read<UserProvider>().guardarImagen(inputText);

                    // Actualiza la imagen en la base de datos
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
    double screenWidth = MediaQuery.of(context).size.width;

    double fontSize = screenWidth * 0.04;
    double tittleSize = screenWidth * 0.08;
    double columnSize = screenWidth * 0.5;

    double maxFontSize = 20.0;
    double maxTittleSize = 30.0;

    // Obtener si estamos en modo claro u oscuro
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    // Obtener los colores según el modo
    final fondoColor = isLightMode ? LightColors.fondoColor : DarkColors.fondoColor;
    final azulito = isLightMode ? LightColors.azulito : DarkColors.azulito;
    final botonColor = isLightMode ? LightColors.botonColor : DarkColors.botonColor;
    final laMancha = isLightMode ? LightColors.laMancha : DarkColors.laMancha;
    final azulote = isLightMode ? LightColors.azulote : DarkColors.azulote;
    final navegacion = isLightMode ? LightColors.navegacion : DarkColors.navegacion;
    final mio = isLightMode ? LightColors.mio : DarkColors.mio;

    return Scaffold(
      backgroundColor: fondoColor,  // Fondo según el modo
      appBar: AppBar(
        backgroundColor: azulito,  // Color del AppBar
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
              AppLocalizations.of(context)!.settings,
              style: TextStyle(color: laMancha),  // Color del texto
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Container(
            width: columnSize,
            color: botonColor,  // Color del contenedor
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
                ElevatedButton(
                    onPressed: () async {
                      await _dbHelper.resetAllUsersInitialization();
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) => Inicio()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navegacion,  // Color del botón
                    ),
                    child: Text("Eliminar cuenta",
                        style: TextStyle(
                            fontSize:
                                fontSize > maxFontSize ? maxFontSize : fontSize,
                            fontWeight: FontWeight.bold))),
                SizedBox(height: 20),
                Text(AppLocalizations.of(context)!.interface,
                    style: TextStyle(
                        fontSize: tittleSize > maxTittleSize
                            ? maxTittleSize
                            : tittleSize,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Idioma",
                    style: TextStyle(
                        fontSize:
                            fontSize > maxFontSize ? maxFontSize : fontSize)),
                DropdownButton<String>(
                  value: context
                      .watch<LanguageProvider>()
                      .chosenLocale
                      .languageCode,
                  items: [
                    DropdownMenuItem(value: "es", child: Text("Español")),
                    DropdownMenuItem(value: "en", child: Text("English")),
                    DropdownMenuItem(value: "ca", child: Text("Gatalàn")),
                    DropdownMenuItem(value: "ar", child: Text("Esñapol")),
                    DropdownMenuItem(value: "el", child: Text("Groot")),
                  ],
                  onChanged: (String? newLang) {
                    if (newLang != null) {
                      context.read<LanguageProvider>().changeLanguage(newLang);
                    }
                  },
                ),
                SizedBox(height: 10),
                Text("Tema oscuro",
                    style: TextStyle(
                        fontSize:
                            fontSize > maxFontSize ? maxFontSize : fontSize)),
                Switch(
                  value: !context
                      .watch<ThemeProvider>()
                      .isLightMode,
                  onChanged: (value) {
                    context.read<ThemeProvider>().updateMode(
                        !value);
                  },
                ),
                SizedBox(height: 20),
                Text("Opción 4",
                    style: TextStyle(
                        fontSize:
                            fontSize > maxFontSize ? maxFontSize : fontSize)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
