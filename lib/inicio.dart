import 'package:flutter/material.dart';
import 'package:progress_saver/inicio_sesion.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/registro_usuario.dart';

class Inicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtiene el tamaño de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Calcula el tamaño del texto, las imágenes y los botones basado en el tamaño de la pantalla
    double logoSize = screenWidth * 0.3; // 30% del ancho de la pantalla
    double brainSize = screenWidth * 0.2; // 20% del ancho de la pantalla
    double fontSize = screenWidth * 0.08; // 8% del ancho de la pantalla
    double buttonWidth = screenWidth * 0.7; // 70% del ancho de la pantalla
    double buttonHeight = screenHeight * 0.07; // 7% del alto de la pantalla
    double buttonTextSize = screenWidth *
        0.05; // 5% del ancho de la pantalla para el texto dentro del botón

    // Establecer una altura máxima para las imágenes, botones y textos 
    double maxImageSize = 350.0; // Tamaño máximo de la imagen
    double maxButtonHeight = 80.0; // Tamaño máximo de los botones
    double maxButtonWidth = 500.0; // Tamaño máximo de los botones (ancho)
    double maxFontSize = 40.0; // Tamaño máximo del texto en pantalla
    double maxTittleSize = 60.0; // Tamaño máximo del título en pantalla

    return Scaffold(
      backgroundColor: fondoColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo con tamaño dinámico y altura máxima
            Container(
              width: logoSize > maxImageSize ? maxImageSize : logoSize,
              height: logoSize > maxImageSize ? maxImageSize : logoSize,
              child: Image.asset('assets/images/logo.png'),
            ),
            const SizedBox(height: 20),
            // Texto con tamaño dinámico y tamaño máximo
            Text(
              'Progress Saver',
              style: TextStyle(
                fontSize: fontSize > maxTittleSize ? maxTittleSize : fontSize,
                fontFamily: 'KeaniaOne',
                color: azulito,
              ),
            ),
            const SizedBox(height: 20),
            // Imagen del cerebro con tamaño dinámico y altura máxima
            Container(
              width: brainSize > maxImageSize ? maxImageSize : brainSize,
              height: brainSize > maxImageSize ? maxImageSize : brainSize,
              child: Image.asset('assets/images/cerebro.png'),
            ),
            const SizedBox(height: 20),
            // Botón "Iniciar Sesión" con tamaño dinámico y altura máxima
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
                  fontSize: buttonTextSize > maxFontSize ? maxFontSize : buttonTextSize, // Tamaño dinámico del texto dentro del botón
                  fontWeight: FontWeight.bold,
                  color: azulote
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Botón "Registrarse" con tamaño dinámico y altura máxima
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroUser()),
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
                  fontSize: buttonTextSize > maxFontSize ? maxFontSize : buttonTextSize, // Tamaño dinámico del texto dentro del botón
                  fontWeight: FontWeight.bold,
                  color: azulote
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 20.0),
              child: Text(
                'Save your progress, save your life',
                style: TextStyle(
                  fontSize: screenWidth * 0.04 > maxFontSize ? maxFontSize : screenWidth * 0.04, // 4% del ancho de la pantalla, con máximo definido
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
