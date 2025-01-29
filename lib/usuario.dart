class Usuario {
  String _username;
  String _password;
  int _isadmin;
  String _profile_image="";

  Usuario(
      {required String username,
      required String password,
      int admin = 0,
      imagen="https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"})
      : _password = password,
        _username = username,
        _isadmin = admin,
        _profile_image= imagen;

  // Método para convertir un Map en un objeto Usuario
  factory Usuario.fromMap(Map<String, Object?> map) {
    return Usuario(
        username: map['username'] as String,
        password: map['password'] as String,
        admin: map['admin'] as int,
        imagen: map['imagen'] as String);
  }

  Map<String, Object?> toMap() {
    return {
      'username': getNombre(),
      'password': getContrasena(),
      'admin': getIsAdmin(),
      'imagen': getImagen()
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