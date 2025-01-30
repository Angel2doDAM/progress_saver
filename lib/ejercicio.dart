class Ejercicio {
  String _ejername;
  int _isselected;
  String _ejercice_image="";

  Ejercicio(
      {required String ejername,
      int isselected = 0,
      ejercice_image="https://cdn.dribbble.com/users/3629745/screenshots/12522080/inexistente.png"})
      : _ejername = ejername,
        _isselected = isselected,
        _ejercice_image= ejercice_image;

  // Método para convertir un Map en un objeto Ejercicio
  factory Ejercicio.fromMap(Map<String, Object?> map) {
    return Ejercicio(
        ejername: map['username'] as String,
        isselected: map['isadmin'] as int,
        ejercice_image: map['profile_image'] as String);
  }

  Map<String, Object?> toMap() {
    return {
      'username': getEjer(),
      'isadmin': getIsSelected(),
      'profile_image': getImagen()
    };
  }

  getEjer() {
    return _ejername;
  }

  getIsSelected() {
    return _isselected;
  }

  getImagen() {
    return _ejercice_image;
  }

  setImagen(String imagen) {
    _ejercice_image = imagen;
  }

  setEjer(String nombre) {
    _ejername = nombre;
  }

  setIsSelected(int admin) {
    _isselected = admin;
  }
}