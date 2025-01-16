class Actividad {
  String id;
  String ofertanteId;
  String nombre;
  String descripcion;
  String ubicacion;
  String duracion;
  String fecha;
  String requisitos;
  int numParticipantes;
  List<String> participantes;

  Actividad({
    required this.id,
    required this.ofertanteId,
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    required this.duracion,
    required this.fecha,
    required this.requisitos,
    this.numParticipantes = 0,
    this.participantes = const [],
  });
  @override
  String toString() {
    return 'Actividad(nombre: $nombre, descripcion: $descripcion)';
  }
}