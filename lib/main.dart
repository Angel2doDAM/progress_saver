import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:progress_saver/iniciosesion.dart';

void main() {
  runApp(MyApp());
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
  late Database _db;
  bool _isLoading = true;

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) { // Índice del botón "Profile"
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InicioSesion()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;

    // Crea la base de datos
    _db = await databaseFactory.openDatabase('app_data.db');

    // Crea la tabla de usuarios
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS Usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double anchoVentana = MediaQuery.of(context).size.width;

    // Calcular el número de columnas basado en el ancho de la pantalla
    int columnas = 1;
    if (anchoVentana >= 300 && anchoVentana < 600) {
      columnas = 2;
    } else if (anchoVentana > 600 && anchoVentana < 1200) {
      columnas = 3;
    } else if (anchoVentana > 1200 && anchoVentana < 1800) {
      columnas = 4;
    } else if (anchoVentana > 1800 && anchoVentana < 2400) {
      columnas = 5;
    } else if (anchoVentana >= 2400) {
      columnas = 6;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFECFEFE),
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/angeldiablo.jpg'),
              radius: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Bienvenido',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? Container(
              color: const Color(0xFF979696),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnas, // Número de tarjetas por fila dinámico
                          crossAxisSpacing: 16, // Espacio horizontal entre tarjetas
                          mainAxisSpacing: 16, // Espacio vertical entre tarjetas
                          childAspectRatio: 3 / 4, // Proporción de ancho/alto
                        ),
                        itemCount: 6, // Número total de tarjetas
                        itemBuilder: (context, index) {
                          return Tarjeta(); // Crear cada tarjeta
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Prueba de la base de datos
                  final username = 'admin';
                  final password = '1234';

                  await _db.insert('Usuarios', {
                    'username': username,
                    'password': EncryptPassword.encryptpassword(password),
                  });

                  final users = await _db.query('Usuarios');
                  print(users); // Verifica que los usuarios se almacenaron correctamente
                },
                child: const Text('Test Database'),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'New',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundImage: AssetImage('assets/images/angeldiablo.jpg'),
              radius: 20,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        backgroundColor: const Color(0xFFECFEFE),
        onTap: _onItemTapped,
        iconSize: 30, // Ajusta el tamaño de los iconos aquí
      ),
    );
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }
}

class Tarjeta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = constraints.maxWidth * 0.07; // Proporción del tamaño del texto

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Card(
            elevation: 5,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/pressdebanca.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Press de banca',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '80 KG',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EncryptPassword {
  static String encryptpassword(String password) {
    return password.split('').reversed.join();
  }
}
