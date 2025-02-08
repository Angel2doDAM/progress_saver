import 'package:flutter/material.dart';
import 'package:progress_saver/model/usuario.dart';

/// Provider para gestionar el usuario registrado actualmente
/// 
/// Se usa para acceder a los datos de un usuario iniciado
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