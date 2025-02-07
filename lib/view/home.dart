import 'package:flutter/material.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/view/inicio.dart';
import 'package:progress_saver/view/inicio_sesion.dart';
import 'package:progress_saver/view/ajustes_usuario.dart';
import 'package:progress_saver/viewmodel/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/database/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _exercises = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await _dbHelper.initializeDatabase();
    _loadExercisesForUser(context.read<UserProvider>().usuarioSup.getNombre());
  }

  Future<void> _loadExercisesForUser(String username) async {
    final userId = await _dbHelper.getUserIdByUsername(username);
    if (userId == null) return;

    final ejerData = await _dbHelper.getExercisesWithWeightByUser(userId);
    setState(() {
      _exercises = ejerData;
    });
  }

  Future<void> _onItemTapped(int index) async {
    if (index == 2) {
      await _dbHelper.resetAllUsersInitialization();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Inicio()));
    } else if (index == 1) {
      _showAddExercisesDialog(); // Mostrar el diálogo de ejercicios no asignados
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _navigateToSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Ajustes()));
  }

  // Función para mostrar el diálogo de ejercicios no asignados
  void _showAddExercisesDialog() async {
    final userId = await _dbHelper.getUserIdByUsername(
        context.read<UserProvider>().usuarioSup.getNombre());
    if (userId == null) return;

    final exercisesNotAssigned = await _dbHelper.getExercisesNotAssignedToUser(userId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addExercise),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: exercisesNotAssigned.map<Widget>((exercise) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(exercise['ejername']),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _dbHelper.assignExerciseToUser(userId, exercise['id']);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double anchoVentana = MediaQuery.of(context).size.width;
    int columnas = (anchoVentana / 300).clamp(1, 6).toInt();

    // Obtener el modo actual (claro/oscuro)
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    // Obtener los colores correspondientes según el modo actual
    final fondoColor = isLightMode ? LightColors.fondoColor : DarkColors.fondoColor;
    final azulito = isLightMode ? LightColors.azulito : DarkColors.azulito;
    final botonColor = isLightMode ? LightColors.botonColor : DarkColors.botonColor;
    final azulote = isLightMode ? LightColors.azulote : DarkColors.azulote;
    final mio = isLightMode ? LightColors.mio : DarkColors.mio;
    final laMancha = isLightMode ? LightColors.laMancha : DarkColors.laMancha;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: azulito, // Fondo según el tema
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: _navigateToSettings,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  context.watch<UserProvider>().usuarioSup.getImagen() ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                ),
                radius: 20,
              ),
            ),
            SizedBox(width: 10),
            Text(
              context.watch<UserProvider>().usuarioSup.getNombre(),
              style: TextStyle(color: laMancha),
            ),
          ],
        ),
      ),
      body: Container(
        color: fondoColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnas,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 4,
            ),
            itemCount: _exercises.length,
            itemBuilder: (context, index) {
              return Tarjeta(
                name: _exercises[index]['ejername'],
                imageUrl: _exercises[index]['ejercice_image'],
                peso: _exercises[index]['peso'] ?? 0,
                botonColor: botonColor,
                azulote: azulote,
                mio: mio,
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: AppLocalizations.of(context)!.home),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: AppLocalizations.of(context)!.newo),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundImage: NetworkImage(
                context.read<UserProvider>().usuarioSup.getImagen() ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
              ),
              radius: 20,
            ),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: azulote,
        backgroundColor: azulito,
        onTap: _onItemTapped,
        iconSize: 30,
      ),
    );
  }
}

class Tarjeta extends StatelessWidget {
  final String name;
  final String imageUrl;
  final int peso;
  final Color botonColor;
  final Color azulote;
  final Color mio;

  Tarjeta({required this.name, required this.imageUrl, required this.peso, required this.botonColor, required this.azulote, required this.mio});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Ajustes()),
          );
        },
        child: Card(
          color: mio,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$peso kg",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
