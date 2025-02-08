class Usuario {
  String _username;
  String _password;
  int _isadmin;
  String _profile_image = "";
  bool _isInicied = false;

  /// Constructor para crear un objeto Usuario.
  Usuario({
    required String username,
    required String password,
    int isadmin = 0,
    String profile_image = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
  })  : _password = password,
        _username = username,
        _isadmin = isadmin,
        _profile_image = profile_image;

  /// Funcion que crea un objeto Usuario a partir de un mapa de datos.
  factory Usuario.fromMap(Map<String, Object?> map) {
    return Usuario(
      username: map['username'] as String,
      password: map['password'] as String,
      isadmin: map['isadmin'] as int,
      profile_image: map['profile_image'] as String,
    ).._isInicied = (map['isInicied'] as int? ?? 0) == 1;
  }

  /// Funcion que convierte el objeto Usuario a un mapa de datos.
  Map<String, Object?> toMap() {
    return {
      'username': getNombre(),
      'password': getContrasena(),
      'isadmin': getIsAdmin(),
      'profile_image': getImagen(),
      'isInicied': getIsInicied() ? 1 : 0,
    };
  }

  String getNombre() => _username;

  String getContrasena() => _password;

  int getIsAdmin() => _isadmin;

  String getImagen() => _profile_image;

  bool getIsInicied() => _isInicied;

  void setImagen(String imagen) {
    _profile_image = imagen;
  }

  void setNombre(String nombre) {
    _username = nombre;
  }

  void setIsAdmin(int admin) {
    _isadmin = admin;
  }

  void setContrasena(String contrasena) {
    _password = contrasena;
  }

  void setIsInicied(bool value) {
    _isInicied = value;
  }
}
