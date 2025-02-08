import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/viewmodel/user_provider.dart';
import 'package:progress_saver/viewmodel/language_provider.dart';
import 'package:progress_saver/viewmodel/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Pantalla de ajustes que permite al usuario configurar el idioma y tema.
class Ajustes extends StatefulWidget {
  @override
  _AjustesState createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController contraController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    /// Tamaño dinámico de fuentes y elementos dependiendo del ancho de la pantalla
    double fontSize = screenWidth * 0.04;
    double tittleSize = screenWidth * 0.08;
    double columnSize = screenWidth * 0.5;
    double logoSize = screenWidth * 0.1;

    /// Tamaño máximo de los elementos para evitar que se agranden demasiado
    double maxFontSize = 20.0;
    double maxTittleSize = 30.0;
    double maxLogoSize = 100.0;

    /// Determina si el modo oscuro o claro está activado
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    /// Definir colores dependiendo del modo de tema
    final fondoColor = isLightMode ? LightColors.fondoColor : DarkColors.fondoColor;
    final azulito = isLightMode ? LightColors.azulito : DarkColors.azulito;
    final azulote = isLightMode ? LightColors.azulote : DarkColors.azulote;
    final botonColor = isLightMode ? LightColors.botonColor : DarkColors.botonColor;
    final laMancha = isLightMode ? LightColors.laMancha : DarkColors.laMancha;
    final logo = isLightMode ? LightColors.logo : DarkColors.logo;

    return Scaffold(
      backgroundColor: fondoColor,
      appBar: AppBar(
        backgroundColor: azulito,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              /// Avatar del usuario que lee la imagen del perfil
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  context.read<UserProvider>().usuarioSup.getImagen(),
                ),
                radius: 20,
              ),
            ),
            SizedBox(width: 10),
            /// Título de la pantalla de ajustes
            Text(
              AppLocalizations.of(context)!.settings,
              style: TextStyle(color: laMancha),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          /// Columna izquierda para las opciones de interfaz y tema
          Container(
            width: columnSize,
            color: botonColor,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Título de la sección de la interfaz
                Text(AppLocalizations.of(context)!.interface,
                        style: TextStyle(
                            fontSize: tittleSize > maxTittleSize
                                ? maxTittleSize
                                : tittleSize,
                            fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(AppLocalizations.of(context)!.lenguaje,
                        style: TextStyle(
                            fontSize: fontSize > maxFontSize
                                ? maxFontSize
                                : fontSize)),
                    SizedBox(width: 20),
                    /// Dropdown para seleccionar el idioma
                    DropdownButton<String>(
                      dropdownColor: azulito,
                      iconEnabledColor: azulote,
                      value: context
                          .watch<LanguageProvider>()
                          .chosenLocale
                          .languageCode,
                      items: const[
                        DropdownMenuItem(value: "es", child: Text("Español")),
                        DropdownMenuItem(value: "en", child: Text("English")),
                        DropdownMenuItem(value: "ca", child: Text("Gatalàn")),
                        DropdownMenuItem(value: "ar", child: Text("Esñapol")),
                        DropdownMenuItem(value: "el", child: Text("Groot")),
                      ],
                      onChanged: (String? newLang) {
                        if (newLang != null) {
                          /// Cambiar el idioma seleccionado
                          context
                              .read<LanguageProvider>()
                              .changeLanguage(newLang);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(AppLocalizations.of(context)!.darkTheme,
                        style: TextStyle(
                            fontSize: fontSize > maxFontSize
                                ? maxFontSize
                                : fontSize)),
                    SizedBox(width: 20),
                    /// Interruptor para cambiar entre modo oscuro y claro
                    Switch(
                      activeColor: azulote,
                      inactiveTrackColor: azulito,
                      inactiveThumbColor: azulote,
                      value: !context.watch<ThemeProvider>().isLightMode,
                      onChanged: (value) {
                        /// Actualizar el modo de tema
                        context.read<ThemeProvider>().updateMode(!value);
                      },
                    ),
                  ],
                ),
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
