import 'package:flutter/material.dart';
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

/// Pagina principal de la aplicacion
/// 
/// En ella se gestionan los ejercicios que tiene un usuario asignado
/// Solo administradores pueden crear ejercicios nuevos
/// Se pueden añadir ejercicios ya creados al usuario iniciado
/// Se puede acceder a los ajustes
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

  /// Inicia la base de datos
  Future<void> _initializeDatabase() async {
    await _dbHelper.initializeDatabase();
    _loadExercisesForUser(context.read<UserProvider>().usuarioSup.getNombre());
  }

  /// Carga los ejercicios del usuario iniciado
  Future<void> _loadExercisesForUser(String username) async {
    final userId = await _dbHelper.getUserIdByUsername(username);
    if (userId == null) return;

    final ejerData = await _dbHelper.getExercisesWithWeightByUser(userId);
    setState(() {
      _exercises = ejerData;
    });
  }

  /// Funcion que estipula que pasa al pulsar sobre la navegacion inferior
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

  /// Abre la pestaña de ajustes
  void _navigateToSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Ajustes()));
  }

  /// Alert para crear un ejercicio nuevo si el usuario es Administrador
  void _showCreateExercisesDialog() async {
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    final azulito = isLightMode ? LightColors.azulito : DarkColors.azulito;
    final azulote = isLightMode ? LightColors.azulote : DarkColors.azulote;
    if (context.read<UserProvider>().usuarioSup.getIsAdmin() == 1) {
      /// Si el usuario es administrador accede a otro alert para introducir nombre e imagen del ejercicio
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
                    _nombreController.text = "";
                    _imagenController.text = "";
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    await _dbHelper.initializeDatabase();
                    Ejercicio ejercicio = Ejercicio(
                        ejername: _nombreController.text,
                        ejercice_image: _imagenController.text);
                    await _dbHelper.insertEjer(ejercicio);
                    setState(() {});
                    _nombreController.text = "";
                    _imagenController.text = "";
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            );
          });
    } else {
      /// Si el usuario no es administrador deniega el acceso
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

  /// Muestra un alert para añadir un nuevo ejercicio eligiendolo y asignandole un peso
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
                            /// Abre un sub-alert para la introduccion del peso
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

  /// Muestra un alert para que el usuario introduzca el peso asociado a un ejercicio
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
                  _dbHelper.assignExerciseToUser(
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

  /// Vista general de la pestaña princimal de la aplicacion
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
    final navegacion = isLightMode ? LightColors.navegacion : DarkColors.laMancha;

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
              /// Añade los ejercicios al fondo deslizable en forma de tarjetas
              return Tarjeta(
                name: _exercises[index]['ejername'],
                imageUrl: _exercises[index]['ejercice_image'],
                peso: _exercises[index]['peso'] ?? 0,
                botonColor: botonColor,
                azulote: azulote,
                mio: mio,
                azulito: azulito,
                navegacion: navegacion,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddExercisesDialog();
        },
        backgroundColor: azulote,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat,
    );
  }
}

// Widget que retorna una tarjeta con la imagen, nombre y peso asociado de un ejercicio
class Tarjeta extends StatelessWidget {
  final String name;
  final String imageUrl;
  final int peso;
  final Color botonColor;
  final Color azulote;
  final Color mio;
  final Color azulito;
  final Color navegacion;

  Tarjeta(
      {required this.name,
      required this.imageUrl,
      required this.peso,
      required this.botonColor,
      required this.azulote,
      required this.mio,
      required this.azulito,
      required this.navegacion});

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
              ElevatedButton(
                onPressed: () async {
                  final userId = await DatabaseHelper().getUserIdByUsername(
                    context.read<UserProvider>().usuarioSup.getNombre(),
                  );

                  if (userId != null) {
                    final exerciseData =
                        await DatabaseHelper().getExerciseByName(name);

                    if (exerciseData != null) {
                      int exerciseId = exerciseData['id'];
                      await DatabaseHelper()
                          .removeExerciseFromUser(userId, exerciseId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.exerciseDeleted),
                        ),
                      );
                      (context as Element).markNeedsBuild();

                      final homePageState = context.findAncestorStateOfType<_MyHomePageState>();
                      homePageState?.setState(() {
                        homePageState._loadExercisesForUser(
                          context.read<UserProvider>().usuarioSup.getNombre(),
                        );
                      });
                    }
                  }
                },
                style:
                  ElevatedButton.styleFrom(backgroundColor: navegacion),
                child: Text(AppLocalizations.of(context)!.delete,
                  style: TextStyle(
                    color: azulito,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ],
          ),
        ));
  }
}

