class Busqueda {
  String id;
  String consumidorId;
  String nombre;
  String descripcion;
  String ubicacion;
  String duracion;
  String fecha;
  String requisitos;
  String? voluntarioId; // Nuevo campo, puede ser nulo si no hay un voluntario asignado

  Busqueda({
    required this.id,
    required this.consumidorId,
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    required this.duracion,
    required this.fecha,
    required this.requisitos,
    this.voluntarioId, // Si no hay un voluntario, este campo puede ser null
  });
  @override
  String toString() {
    return 'Busqueda(nombre: $nombre, descripcion: $descripcion)';
  }
}
