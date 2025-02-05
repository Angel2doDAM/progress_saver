import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/main.dart';
import 'database_helper.dart';
import 'package:http/http.dart';

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
          title: Text("Foto de perfil"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Elija la imagen para su usuario:"),
              SizedBox(height: 10),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Pega URL aquí",
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
                      inputText
                    );

                    setState(() {});
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  setState(() {});
                }
              },
              child: Text("Aceptar"),
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

    double maxFontSize =20.0;
    double maxTittleSize = 30.0;
    return Scaffold(
      backgroundColor: fondoColor,
      appBar: AppBar(
        backgroundColor: azulito,
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
              'Ajustes',
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
                Text("Sesión", style: TextStyle(fontSize: tittleSize > maxTittleSize ? maxTittleSize : tittleSize, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed:() {

                }, 
                child: Text("Eliminar cuenta", style: TextStyle(fontSize: fontSize > maxFontSize ? maxFontSize : fontSize, fontWeight: FontWeight.bold))),
                Text("Opción 2", style: TextStyle(fontSize: fontSize > maxFontSize ? maxFontSize : fontSize, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text("Opción 3", style: TextStyle(fontSize: fontSize > maxFontSize ? maxFontSize : fontSize, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text("Opción 4", style: TextStyle(fontSize: fontSize > maxFontSize ? maxFontSize : fontSize, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
