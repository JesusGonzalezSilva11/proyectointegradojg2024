class Persona {
  String dni;
  String tipo;
  String nombre;
  String apellidos;
  int telefono;
  String correo;
  String contrasena;

  Persona({
    required this.dni,
    required this.tipo,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.contrasena,
  });
  // Sobrescribir el método toString() para personalizar la salida al imprimir la persona
  @override
  String toString() {
    return 'Nombre: $nombre, DNI: $dni, Tipo: $tipo';
  }
}
