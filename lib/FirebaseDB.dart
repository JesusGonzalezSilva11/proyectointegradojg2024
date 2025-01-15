import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyectointegradojg2024/Actividad.dart';
import 'package:proyectointegradojg2024/Busqueda.dart';
import 'package:proyectointegradojg2024/Persona.dart';

class FirebaseDB {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Métodos para Actividad
  static Future<void> crearActividad(Actividad actividad) async {
    // Crear un nuevo documento con un ID generado automáticamente
    DocumentReference ref = await FirebaseFirestore.instance.collection('actividades').add({
      'ofertanteId': actividad.ofertanteId,
      'nombre': actividad.nombre,
      'descripcion': actividad.descripcion,
      'ubicacion': actividad.ubicacion,
      'duracion': actividad.duracion,
      'fecha': actividad.fecha,
      'requisitos': actividad.requisitos,
      'numParticipantes': actividad.numParticipantes,
      'participantes': actividad.participantes,
    });

    // Si necesitas el ID generado, puedes acceder a él con `ref.id`
    print("Actividad creada con ID: ${ref.id}");
  }

  Future<List<Actividad>> leerActividades() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('actividades').get();
      return snapshot.docs.map((doc) {
        return Actividad(
          id: doc.id,
          ofertanteId: doc['ofertanteId'],
          nombre: doc['nombre'],
          descripcion: doc['descripcion'],
          ubicacion: doc['ubicacion'],
          duracion: doc['duracion'],
          fecha: doc['fecha'],
          requisitos: doc['requisitos'],
          numParticipantes: doc['numParticipantes'] ?? 0,
          participantes: List<String>.from(doc['participantes'] ?? []),
        );
      }).toList();
    } catch (e) {
      print("Error al leer actividades: $e");
      return [];
    }
  }

  Future<void> actualizarActividad(String id, Map<String, dynamic> data) async {
    await _firestore.collection('actividades').doc(id).update(data);
  }

  Future<void> eliminarActividad(String id) async {
    await _firestore.collection('actividades').doc(id).delete();
  }

  static Future<void> agregarParticipante(String actividadId, String userId) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection('actividades').doc(actividadId);
      DocumentSnapshot docSnap = await docRef.get();

      if (docSnap.exists) {
        List<String> participantes = List<String>.from(docSnap['participantes'] ?? []);
        int numParticipantes = docSnap['numParticipantes'] ?? 0;

        if (participantes.length < numParticipantes) {
          // Agregar al usuario a la lista de participantes
          await docRef.update({
            'participantes': FieldValue.arrayUnion([userId])
          });
          print("Participante agregado correctamente.");
        } else {
          print("La actividad ya alcanzó el límite de participantes.");
        }
      } else {
        print("Actividad no encontrada.");
      }
    } catch (e) {
      print("Error al agregar participante: $e");
    }
  }


  // Métodos para Busqueda
  static Future<void> crearBusqueda(Busqueda busqueda) async {
    // Crear un nuevo documento con un ID generado automáticamente
    DocumentReference ref = await FirebaseFirestore.instance.collection('busquedas').add({
      'consumidorId': busqueda.consumidorId,
      'nombre': busqueda.nombre,
      'descripcion': busqueda.descripcion,
      'ubicacion': busqueda.ubicacion,
      'duracion': busqueda.duracion,
      'fecha': busqueda.fecha,
      'requisitos': busqueda.requisitos,
      'voluntarioId': busqueda.voluntarioId, // Este campo puede ser nulo o vacío
    });

    // Si necesitas el ID generado, puedes acceder a él con `ref.id`
    print("Búsqueda creada con ID: ${ref.id}");
  }

  Future<List<Busqueda>> leerBusquedas() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('busquedas').get();
      return snapshot.docs.map((doc) {
        return Busqueda(
          id: doc.id,
          consumidorId: doc['consumidorId'],
          nombre: doc['nombre'],
          descripcion: doc['descripcion'],
          ubicacion: doc['ubicacion'],
          duracion: doc['duracion'],
          fecha: doc['fecha'],
          requisitos: doc['requisitos'],
          voluntarioId: doc['voluntarioId'],
        );
      }).toList();
    } catch (e) {
      print("Error al leer busquedas: $e");
      return [];
    }
  }

  Future<void> actualizarBusqueda(String id, Map<String, dynamic> data) async {
    await _firestore.collection('busquedas').doc(id).update(data);
  }

  Future<void> eliminarBusqueda(String id) async {
    await _firestore.collection('busquedas').doc(id).delete();
  }

  static Future<void> asignarVoluntario(String busquedaId, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('busquedas')
          .doc(busquedaId)
          .update({'voluntarioId': userId});
      print('Voluntario asignado correctamente.');
    } catch (e) {
      print('Error al asignar voluntario: $e');
    }
  }

  // Métodos para Persona
  Future<void> crearPersona(Persona persona) async {
    await _firestore.collection('personas').doc(persona.dni).set({
      'tipo': persona.tipo,
      'nombre': persona.nombre,
      'apellidos': persona.apellidos,
      'telefono': persona.telefono,
      'correo': persona.correo,
      'contrasena': persona.contrasena,
    });
  }

  Future<List<Persona>> leerPersonas() async {
    QuerySnapshot snapshot = await _firestore.collection('personas').get();
    return snapshot.docs
        .map((doc) => Persona(
      dni: doc.id,
      tipo: doc['tipo'],
      nombre: doc['nombre'],
      apellidos: doc['apellidos'],
      telefono: doc['telefono'],
      correo: doc['correo'],
      contrasena: doc['contrasena'],
    ))
        .toList();
  }

  Future<void> actualizarPersona(String dni, Map<String, dynamic> data) async {
    await _firestore.collection('personas').doc(dni).update(data);
  }

  Future<void> eliminarPersona(String dni) async {
    await _firestore.collection('personas').doc(dni).delete();
  }

  Future<Persona?> leerPersona(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('personas').doc(id).get();
      if (doc.exists) {
        return Persona(
          dni: doc.id,
          tipo: doc['tipo'],
          nombre: doc['nombre'],
          apellidos: doc['apellidos'],
          telefono: doc['telefono'],
          correo: doc['correo'],
          contrasena: doc['contrasena'],
        );
      }
      return null;
    } catch (e) {
      print("Error al leer persona con ID $id: $e");
      return null;
    }
  }

}
