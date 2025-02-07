import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:progress_saver/model/ejercicio.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/view/ajustes_usuario.dart';
import 'package:progress_saver/viewmodel/user_provider.dart';
import 'package:progress_saver/view/perfil.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/database/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _imagenController = TextEditingController();
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
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Perfil()));
    } else if (index == 1) {
      _showCreateExercisesDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _navigateToSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Ajustes()));
  }

  void _showCreateExercisesDialog() async {
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    final azulito = isLightMode ? LightColors.azulito : DarkColors.azulito;
    final azulote = isLightMode ? LightColors.azulote : DarkColors.azulote;
    if (context.read<UserProvider>().usuarioSup.getIsAdmin() == 1) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: azulito,
              shadowColor: azulote,
              title: Text(AppLocalizations.of(context)!.exerciseCreator),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.enterExerciseName),
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: AppLocalizations.of(context)!.exerciseName,
                    ),
                  ),
                  Text(AppLocalizations.of(context)!.enterExerciseImage),
                  TextField(
                    controller: _imagenController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: AppLocalizations.of(context)!.exerciseImage,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                        await _dbHelper.initializeDatabase();
                        Ejercicio ejercicio = Ejercicio(ejername: _nombreController.text, ejercice_image: _imagenController.text);
                        await _dbHelper.insertEjer(ejercicio);
                        setState(() {});
                        Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: azulito,
              shadowColor: azulote,
              title: Text(AppLocalizations.of(context)!.exerciseCreator),
              content: Text(AppLocalizations.of(context)!.restrictedAccess),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ],
            );
          });
    }
  }

  void _showAddExercisesDialog() async {
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    final azulito = isLightMode ? LightColors.azulito : DarkColors.azulito;
    final azulote = isLightMode ? LightColors.azulote : DarkColors.azulote;
    final userId = await _dbHelper.getUserIdByUsername(
        context.read<UserProvider>().usuarioSup.getNombre());
    if (userId == null) return;

    final exercisesNotAssigned =
        await _dbHelper.getExercisesNotAssignedToUser(userId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: azulito,
          shadowColor: azulote,
          title: Text(AppLocalizations.of(context)!.addExercise),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: exercisesNotAssigned.isEmpty
                ? [Text(AppLocalizations.of(context)!.noExercisesToAssign)]
                : exercisesNotAssigned.map<Widget>((exercise) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(exercise['ejername']),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showWeightInputDialog(userId, exercise['id']);
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

  void _showWeightInputDialog(int userId, int exerciseId) {
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    final azulito = isLightMode ? LightColors.azulito : DarkColors.azulito;
    final azulote = isLightMode ? LightColors.azulote : DarkColors.azulote;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: azulito,
          shadowColor: azulote,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.desiredWeight),
              SizedBox(height: 10),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: AppLocalizations.of(context)!.weight,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _textController.text = "";
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                try {
                  int peso = int.parse(_textController.text.trim());
                  _dbHelper.assignExerciseToUserWithDetails(
                      userId, exerciseId, peso, DateTime.now());
                  _textController.text = "";
                  _loadExercisesForUser(
                    context.read<UserProvider>().usuarioSup.getNombre(),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.onlyNumbers),
                    ),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.ok),
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

    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    final fondoColor =
        isLightMode ? LightColors.fondoColor : DarkColors.fondoColor;
    final azulito = isLightMode ? LightColors.azulito : DarkColors.azulito;
    final botonColor =
        isLightMode ? LightColors.botonColor : DarkColors.botonColor;
    final azulote = isLightMode ? LightColors.azulote : DarkColors.azulote;
    final mio = isLightMode ? LightColors.mio : DarkColors.mio;
    final laMancha = isLightMode ? LightColors.laMancha : DarkColors.laMancha;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: azulito,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: _navigateToSettings,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  context.watch<UserProvider>().usuarioSup.getImagen(),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: AppLocalizations.of(context)!.home),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: AppLocalizations.of(context)!.newo),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundImage: NetworkImage(
                context.read<UserProvider>().usuarioSup.getImagen(),
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
      // Floating Action Button añadido aquí
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddExercisesDialog(); // Acción al presionar el botón flotante
        },
        backgroundColor: azulote,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Ubicación a la derecha inferior
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

  Tarjeta(
      {required this.name,
      required this.imageUrl,
      required this.peso,
      required this.botonColor,
      required this.azulote,
      required this.mio});

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
                      "$peso" + AppLocalizations.of(context)!.kg,
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
