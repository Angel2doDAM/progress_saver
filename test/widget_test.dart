import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progress_saver/view/home.dart';
import 'package:progress_saver/view/inicio.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/viewmodel/language_provider.dart';
import 'package:progress_saver/viewmodel/theme_provider.dart';
import 'package:progress_saver/viewmodel/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_saver/database/database_helper.dart';
import 'package:progress_saver/model/usuario.dart';

void main() {
  testWidgets('Verificar que el texto "Progress Saver" se muestra en pantalla', (WidgetTester tester) async {
    // Configuración de SharedPreferences, DatabaseHelper y UserProvider como en tu código real
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();
    Usuario? usuario = await dbHelper.getUserWithIsInicied();
    UserProvider userProvider = UserProvider();
    if (usuario != null) {
      userProvider.usuarioSup = usuario;
    }

    // Ejecutamos la app con el MultiProvider que incluye todos los providers necesarios
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider(prefs)),
          ChangeNotifierProvider(create: (_) => userProvider),
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: usuario != null ? MyHomePage() : Inicio(),
        ),
      ),
    );

    // Esperamos que la app cargue
    await tester.pumpAndSettle();

    // Buscamos el texto "Progress Saver"
    expect(find.text('Progress Saver'), findsOneWidget);
  });
}
