class SuperUsuario {
  static final SuperUsuario _instance = SuperUsuario._internal();

  // Atributos del usuario
  String? _username;
  bool _isAdmin = false;
  String? _profilePictureUrl; // Atributo para la URL de la foto de perfil

  // Constructor privado
  SuperUsuario._internal();

  // Acceso a la única instancia
  factory SuperUsuario() {
    return _instance;
  }

  // Métodos para gestionar la sesión
  void iniciarSesion({required String username, bool isAdmin = false, String? profilePictureUrl}) {
    _username = username;
    _isAdmin = isAdmin;
    _profilePictureUrl = profilePictureUrl; // Guardamos la URL de la imagen de perfil
  }

  void cerrarSesion() {
    _username = null;
    _isAdmin = false;
    _profilePictureUrl = null; // Limpiar la URL de la foto de perfil al cerrar sesión
  }

  bool get sesionActiva => _username != null;

  String? get username => _username;

  bool get isAdmin => _isAdmin;

  String? getNombre() {
    return _username;
  }

  String? getProfilePictureUrl() {
    return _profilePictureUrl; // Método para obtener la URL de la foto de perfil
  }

  void setProfilePictureUrl(String ruta) {
    _profilePictureUrl = ruta; // Método para agregar la URL de la foto de perfil
  }

  @override
  String toString() {
    return sesionActiva
        ? 'Usuario: $_username, Admin: $_isAdmin'
        : 'No hay sesión activa';
  }
}

