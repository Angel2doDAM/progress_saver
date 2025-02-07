import 'package:flutter/material.dart';
import 'package:progress_saver/view/inicio_sesion.dart';
import 'package:progress_saver/view/registro_usuario.dart';
import 'package:progress_saver/database/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:progress_saver/themes/colors.dart'; // Asegúrate de importar los colores que definiste.

class Inicio extends StatelessWidget {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    _dbHelper.resetAllUsersInitialization();

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double logoSize = screenWidth * 0.3;
    double brainSize = screenWidth * 0.2;
    double fontSize = screenWidth * 0.08;
    double buttonWidth = screenWidth * 0.7;
    double buttonHeight = screenHeight * 0.07;
    double buttonTextSize = screenWidth * 0.05;

    double maxImageSize = 350.0;
    double maxButtonHeight = 80.0;
    double maxButtonWidth = 500.0;
    double maxFontSize = 40.0;
    double maxTittleSize = 60.0;

    // Obtener el modo actual (claro/oscuro)
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    // Obtener los colores correspondientes según el modo actual
    final carpeta = isLightMode ? 'assets/images/logo.png' : 'assets/images/logoOscuro.png';
    final fondoColor = isLightMode ? LightColors.fondoColor : DarkColors.fondoColor;
    final logo = isLightMode ? LightColors.logo : DarkColors.logo;
    final botonColor = isLightMode ? LightColors.botonColor : DarkColors.botonColor;
    final azulote = isLightMode ? LightColors.azulote : DarkColors.azulote;

    return Scaffold(
      backgroundColor: fondoColor,  // Fondo según el tema
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: logoSize > maxImageSize ? maxImageSize : logoSize,
              height: logoSize > maxImageSize ? maxImageSize : logoSize,
              child: Image.asset(carpeta),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.tittle,
              style: TextStyle(
                fontSize: fontSize > maxTittleSize ? maxTittleSize : fontSize,
                fontFamily: 'KeaniaOne',
                color: logo,  // Color según el tema
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: brainSize > maxImageSize ? maxImageSize : brainSize,
              height: brainSize > maxImageSize ? maxImageSize : brainSize,
              child: Image.asset('assets/images/cerebro.png'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InicioSesion()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: botonColor,  // Color de fondo del botón
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(
                    buttonWidth > maxButtonWidth ? maxButtonWidth : buttonWidth,
                    buttonHeight > maxButtonHeight ? maxButtonHeight : buttonHeight),
              ),
              child: Text(
                AppLocalizations.of(context)!.login,
                style: TextStyle(
                  fontSize: buttonTextSize > maxFontSize ? maxFontSize : buttonTextSize,
                  fontWeight: FontWeight.bold,
                  color: azulote,  // Color del texto del botón
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroUsuario()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: botonColor,  // Color de fondo del botón
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(
                    buttonWidth > maxButtonWidth ? maxButtonWidth : buttonWidth,
                    buttonHeight > maxButtonHeight ? maxButtonHeight : buttonHeight),
              ),
              child: Text(
                AppLocalizations.of(context)!.register,
                style: TextStyle(
                  fontSize: buttonTextSize > maxFontSize ? maxFontSize : buttonTextSize,
                  fontWeight: FontWeight.bold,
                  color: azulote,  // Color del texto del botón
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                AppLocalizations.of(context)!.slogan,
                style: TextStyle(
                  fontSize: screenWidth * 0.04 > maxFontSize ? maxFontSize : screenWidth * 0.04,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
