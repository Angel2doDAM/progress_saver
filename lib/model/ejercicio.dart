class Ejercicio {
  String _ejername;
  String _ejercice_image = "";

  /// Constructor para crear un ejercicio con nombre e imagen por defecto.
  Ejercicio({
    required String ejername,
    int peso = 0,
    String ejercice_image = "https://cdn.dribbble.com/users/3629745/screenshots/12522080/inexistente.png",
    String fecha = "",
  })  : _ejername = ejername,
        _ejercice_image = ejercice_image;

  /// Funcion que crea un objeto Ejercicio a partir de un mapa de datos.
  factory Ejercicio.fromMap(Map<String, Object?> map) {
    return Ejercicio(
      ejername: map['ejername'] as String,
      ejercice_image: map['ejercice_image'] as String,
    );
  }

  /// Funcion que convierte el objeto Ejercicio a un mapa de datos.
  Map<String, Object?> toMap() {
    return {
      'ejername': _ejername,
      'ejercice_image': _ejercice_image,
    };
  }

  String getEjer() {
    return _ejername;
  }

  String getImagen() {
    return _ejercice_image;
  }

  setImagen(String imagen) {
    _ejercice_image = imagen;
  }

  setEjer(String nombre) {
    _ejername = nombre;
  }
}
