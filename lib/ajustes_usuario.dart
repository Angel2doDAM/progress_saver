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
              try{
              Uri uri = Uri.parse(_textController.text);
              if((await get(uri)).statusCode == 200){
                await _dbHelper.initializeUsuariosDatabase();
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
              }catch(e){
                setState(() {
                });
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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          ],
        ),
      ),
    );
  }
}

