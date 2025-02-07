import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_saver/themes/colors.dart';
import 'package:progress_saver/viewmodel/user_provider.dart';
import '../database/database_helper.dart';
import 'package:progress_saver/view/inicio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Perfil extends StatefulWidget {
  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double fontSize = screenWidth * 0.04;
    double tittleSize = screenWidth * 0.08;
    double logoSize = screenWidth * 0.1;
    double columnSize = screenWidth * 0.5;

    double maxFontSize = 20.0;
    double maxTittleSize = 30.0;
    double maxLogoSize = 100.0;

    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    final fondoColor =
        isLightMode ? LightColors.fondoColor : DarkColors.fondoColor;
    final azulito = isLightMode ? LightColors.azulito : DarkColors.azulito;
    final botonColor =
        isLightMode ? LightColors.botonColor : DarkColors.botonColor;
    final laMancha = isLightMode ? LightColors.laMancha : DarkColors.laMancha;
    final navegacion =
        isLightMode ? LightColors.navegacion : DarkColors.navegacion;
    final logo = isLightMode ? LightColors.logo : DarkColors.logo;
    return Scaffold(
      backgroundColor: fondoColor,
      appBar: AppBar(
        backgroundColor: azulito,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                context.read<UserProvider>().usuarioSup.getImagen(),
              ),
              radius: 20,
            ),
            SizedBox(width: 10),
            Text(
              context.watch<UserProvider>().usuarioSup.getNombre(),
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
                Text(AppLocalizations.of(context)!.session,
                    style: TextStyle(
                        fontSize: tittleSize > maxTittleSize
                            ? maxTittleSize
                            : tittleSize,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      await _dbHelper.resetAllUsersInitialization();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Inicio()));
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: navegacion),
                    child: Text(AppLocalizations.of(context)!.logout,
                        style: TextStyle(
                          color: azulito,
                            fontSize:
                                fontSize > maxFontSize ? maxFontSize : fontSize,
                            fontWeight: FontWeight.bold))),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      await _dbHelper.resetAllUsersInitialization();
                      int? userId = await _dbHelper.getUserIdByUsername(
                          context.read<UserProvider>().usuarioSup.getNombre());
                      if (userId != null) {
                        await _dbHelper.removeAllExercisesFromUser(userId);
                      }
                      await _dbHelper.deleteUser(
                          context.read<UserProvider>().usuarioSup.getNombre());
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Inicio()));
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: navegacion),
                    child: Text(AppLocalizations.of(context)!.deleteAcount,
                        style: TextStyle(
                            color: azulito,
                            fontSize:
                                fontSize > maxFontSize ? maxFontSize : fontSize,
                            fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.tit,
                      style: TextStyle(
                        fontSize:
                            logoSize > maxLogoSize ? maxLogoSize : logoSize,
                        fontFamily: 'KeaniaOne',
                        color: logo,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.tle,
                      style: TextStyle(
                        fontSize:
                            logoSize > maxLogoSize ? maxLogoSize : logoSize,
                        fontFamily: 'KeaniaOne',
                        color: logo,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
