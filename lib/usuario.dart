class Usuario {
  String _username;
  String _password;
  int _isadmin;
  String _profile_image="";

  Usuario(
      {required String username,
      required String password,
      int isadmin = 0,
      profile_image="https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"})
      : _password = password,
        _username = username,
        _isadmin = isadmin,
        _profile_image= profile_image;

  // Método para convertir un Map en un objeto Usuario
  factory Usuario.fromMap(Map<String, Object?> map) {
    return Usuario(
        username: map['username'] as String,
        password: map['password'] as String,
        isadmin: map['isadmin'] as int,
        profile_image: map['profile_image'] as String);
  }

  Map<String, Object?> toMap() {
    return {
      'username': getNombre(),
      'password': getContrasena(),
      'isadmin': getIsAdmin(),
      'profile_image': getImagen()
    };
  }

  getNombre() {
    return _username;
  }

  getContrasena() {
    return _password;
  }

  getIsAdmin() {
    return _isadmin;
  }

  getImagen() {
    return _profile_image;
  }

  setImagen(String imagen) {
    _profile_image = imagen;
  }

  setNombre(String nombre) {
    _username = nombre;
  }

  setIsAdmin(int admin) {
    _isadmin = admin;
  }

  setContrasena(String contrasena) {
    _password = contrasena;
  }
}