import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_saver/database/database_helper.dart';
import 'package:progress_saver/view/inicio.dart';
import 'package:progress_saver/view/home.dart';
import 'viewmodel/language_provider.dart';
import 'viewmodel/theme_provider.dart';
import 'package:progress_saver/model/usuario.dart';
import 'package:progress_saver/viewmodel/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();  

  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.initializeDatabase();

  Usuario? usuario = await dbHelper.getUserWithIsInicied();

  UserProvider userProvider = UserProvider();
  if (usuario != null) {
    userProvider.setUsuario(usuario);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider(prefs)), 
        ChangeNotifierProvider(create: (_) => userProvider),           
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),    
      ],
      child: MyApp(startPage: usuario != null ? MyHomePage() : Inicio()),
    ),
  );
}


class MyApp extends StatelessWidget {
  final Widget startPage;

  MyApp({required this.startPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('es'),
        Locale('en'),
        Locale('ca'),
        Locale('ar'),
        Locale('el'),
      ],
      locale: context.watch<LanguageProvider>().chosenLocale, 
      theme: context.watch<ThemeProvider>().isLightMode
          ? ThemeData.light()
          : ThemeData.dark(),
      home: startPage,
    );
  }
}

