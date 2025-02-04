import 'package:flutter/material.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/inicio_sesion.dart';
import 'package:progress_saver/registro_usuario.dart';
import 'database_helper.dart';

class Inicio extends StatelessWidget {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: fondoColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: logoSize > maxImageSize ? maxImageSize : logoSize,
              height: logoSize > maxImageSize ? maxImageSize : logoSize,
              child: Image.asset('assets/images/logo.png'),
            ),
            const SizedBox(height: 20),
            Text(
              'Progress Saver',
              style: TextStyle(
                fontSize: fontSize > maxTittleSize ? maxTittleSize : fontSize,
                fontFamily: 'KeaniaOne',
                color: azulito,
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
                backgroundColor: botonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(
                    buttonWidth > maxButtonWidth ? maxButtonWidth : buttonWidth, 
                    buttonHeight > maxButtonHeight ? maxButtonHeight : buttonHeight
                ),
              ),
              child: Text(
                'Iniciar Sesión',
                style: TextStyle(
                  fontSize: buttonTextSize > maxFontSize ? maxFontSize : buttonTextSize,
                  fontWeight: FontWeight.bold,
                  color: azulote
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
                backgroundColor: botonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(
                    buttonWidth > maxButtonWidth ? maxButtonWidth : buttonWidth, 
                    buttonHeight > maxButtonHeight ? maxButtonHeight : buttonHeight
                ),
              ),
              child: Text(
                'Registrarse',
                style: TextStyle(
                  fontSize: buttonTextSize > maxFontSize ? maxFontSize : buttonTextSize,
                  fontWeight: FontWeight.bold,
                  color: azulote
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Save your progress, save your life',
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
