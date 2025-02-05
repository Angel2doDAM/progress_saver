import 'package:flutter/material.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/inicio.dart';
import 'package:progress_saver/inicio_sesion.dart';
import 'package:progress_saver/ajustes_usuario.dart';
import 'package:progress_saver/usuario.dart';
import 'package:provider/provider.dart';
import 'database_helper.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Bottom Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

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
    Usuario usuario = new Usuario(
        username: "Admin",
        password:
            "51473f7aa097890b5f14fdea9d5b468fa0aa5d5da1b1d4a6b1ab52ca2bdc0121",
        isadmin: 1);
    /*_dbHelper.insertUser(usuario);
    await _dbHelper.insertarEjerciciosDeEjemplo();
    await _dbHelper.assignExerciseToUserWithDetails(1, 1, 80);
    await _dbHelper.assignExerciseToUserWithDetails(1, 2, 80);
    await _dbHelper.assignExerciseToUserWithDetails(1, 3, 80);
    await _dbHelper.assignExerciseToUserWithDetails(1, 4, 80);
    await _dbHelper.assignExerciseToUserWithDetails(1, 5, 80);*/

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

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Inicio()));
    } else if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => InicioSesion()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _navigateToSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Ajustes()));
  }

  @override
  Widget build(BuildContext context) {
    double anchoVentana = MediaQuery.of(context).size.width;
    int columnas = (anchoVentana / 300).clamp(1, 6).toInt();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulito,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: _navigateToSettings,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  context.watch<UserProvider>().usuarioSup.getImagen() ??
                      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
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
                peso: _exercises[index]['peso'] ??
                    0, // Asegurarse de que el peso no sea nulo
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'New'),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundImage: NetworkImage(
                context.read<UserProvider>().usuarioSup.getImagen() ??
                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
              ),
              radius: 20,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: navegacion,
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
  final int peso; // Agregar peso

  Tarjeta({required this.name, required this.imageUrl, required this.peso});

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

class UserProvider extends ChangeNotifier {
  Usuario usuarioSup = Usuario(
      username: "Anonimo",
      password: "",
      profile_image:
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png");

  void guardarImagen(String imagen) {
    usuarioSup.setImagen(imagen);
    notifyListeners();
  }

  void guardar() {
    notifyListeners();
  }
}
