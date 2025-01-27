import 'package:flutter/material.dart';
import 'package:progress_saver/themes/colors.dart';

class InicioSesion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Controladores para los TextField
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController contraController = TextEditingController();

    // Mensajes de alerta
    String alertaNombre = "";
    String alertaContra = "";

    // Obtiene el tamaño de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fontSize = screenWidth * 0.08; // 8% del ancho de la pantalla
    double buttonWidth = screenWidth * 0.7; // 70% del ancho de la pantalla
    double buttonHeight = screenHeight * 0.07; // 7% del alto de la pantalla
    double buttonTextSize = screenWidth *
        0.05; // 5% del ancho de la pantalla para el texto dentro del botón
    double topSizeBoxHeight = screenHeight * 0.05;
    double middleSizeBoxHeight = screenHeight * 0.1;

    // Establecer una altura máxima para las imágenes, botones y textos
    double maxButtonHeight = 80.0; // Tamaño máximo de los botones
    double maxButtonWidth = 500.0; // Tamaño máximo de los botones (ancho)
    double maxFontSize = 20.0; // Tamaño máximo del texto en pantalla
    double maxTittleSize = 60.0; // Tamaño máximo del título en pantalla

    // Función de validación
    void validarCampos() {
      // Validar Nombre (comienza con mayúscula y solo letras con o sin tildes y números permitidos)
      final nombre = nombreController.text;
      if (nombre.isEmpty) {
        alertaNombre = "El nombre no puede estar vacío";
      } else if (!RegExp(r'^[A-ZÁÉÍÓÚÑ][A-Za-záéíóúñ0-9]*$').hasMatch(nombre)) {
        alertaNombre =
            "El nombre debe comenzar con mayúscula y puede contener números, pero no símbolos.";
      } else {
        alertaNombre = ""; // Nombre válido
      }

      // Validar Contraseña (debe tener al menos una mayúscula, una minúscula, un símbolo especial y 8 caracteres)
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
    }

    return Scaffold(
      backgroundColor: fondoColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height:
                    topSizeBoxHeight), //Hueco en blanco ---------------------------------------------------------------
            // Texto con tamaño dinámico y tamaño máximo
            Text(
              'Inicio de sesión',
              style: TextStyle(
                fontSize: fontSize > maxTittleSize ? maxTittleSize : fontSize,
                fontFamily: 'KeaniaOne',
                color: azulito,
              ),
            ),
            SizedBox(
                height:
                    middleSizeBoxHeight), //Hueco en blanco ---------------------------------------------------------------
            // TextField para introducir el nombre
            Text(
              "Introduzca su nombre:",
              style: TextStyle(
                fontSize: screenWidth * 0.03 > maxFontSize
                    ? maxFontSize
                    : screenWidth * 0.03,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                hintText: 'Tu nombre',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: laMancha), // Borde negro
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: laMancha), // Borde negro para estado habilitado
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: laMancha,
                      width: 2.0), // Borde negro más grueso al enfocar
                ),
                fillColor: azulito, // Relleno del color azulito
                filled: true, // Habilitar el relleno
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
            SizedBox(
                height:
                    topSizeBoxHeight), //Hueco en blanco ---------------------------------------------------------------
            // TextField para introducir la contraseña
            Text(
              "Introduzca su contraseña:",
              style: TextStyle(
                fontSize: screenWidth * 0.03 > maxFontSize
                    ? maxFontSize
                    : screenWidth * 0.03,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contraController,
              decoration: InputDecoration(
                hintText: 'Tu contraseña',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Borde negro
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.black), // Borde negro para estado habilitado
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0), // Borde negro más grueso al enfocar
                ),
                fillColor: azulito, // Relleno del color azulito
                filled: true, // Habilitar el relleno
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                alertaContra,
                style: TextStyle(color: errorColor),
              ),
            ),
            // Texto con tamaño dinámico, ahora en la parte inferior
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 20.0), // Corregido el uso de EdgeInsets
              child: Text(
                'Save your progress, save your life',
                style: TextStyle(
                  fontSize: screenWidth * 0.04 > maxFontSize
                      ? maxFontSize
                      : screenWidth *
                          0.04, // 4% del ancho de la pantalla, con máximo definido
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
