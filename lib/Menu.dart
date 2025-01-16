import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:proyectointegradojg2024/Persona.dart';
import 'package:proyectointegradojg2024/Actividad.dart';
import 'package:proyectointegradojg2024/Busqueda.dart';
import 'package:proyectointegradojg2024/FirebaseDB.dart';

class MenuScreen extends StatefulWidget {
  final Persona persona;

  MenuScreen({required this.persona});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool viewingSearches = true;
  List<dynamic> searches = [];
  List<dynamic> activities = [];
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredSearches = [];
  List<dynamic> filteredActivities = [];
  bool mostrarAcciones = false;
  bool viewingVolunteer = false;
  bool viewingParticipant = false;
  FirebaseDB firebaseDB = FirebaseDB();


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Función para cargar datos desde Firebase
  Future<void> _loadData() async {
    try {
      List<Busqueda> loadedSearches = await FirebaseDB().leerBusquedas();
      List<Actividad> loadedActivities = await FirebaseDB().leerActividades();

      // Imprimir las listas cargadas en la terminal para depuración
      print("Busquedas cargadas:");
      loadedSearches.forEach((search) {
        print("ID: ${search.id}, Nombre: ${search.nombre}, Descripción: ${search.descripcion}");
      });

      print("Actividades cargadas:");
      loadedActivities.forEach((activity) {
        print("ID: ${activity.id}, Nombre: ${activity.nombre}, Descripción: ${activity.descripcion}");
      });

      setState(() {
        searches = loadedSearches;
        activities = loadedActivities;
        // Inicializar las listas filtradas
        filteredSearches = List.from(loadedSearches);
        filteredActivities = List.from(loadedActivities);
      });
    } catch (e) {
      print("Error al cargar datos desde Firebase: $e");
    }
  }

  // Función para crear actividad
  Future<void> _crearActividad(Actividad actividad) async {
    await FirebaseDB.crearActividad(
        actividad); // Llama a la función de Firebase
    _loadData(); // Recargar los datos después de crear la actividad
  }

  // Función para crear búsqueda
  Future<void> _crearBusqueda(Busqueda busqueda) async {
    await FirebaseDB.crearBusqueda(busqueda); // Llama a la función de Firebase
    _loadData(); // Recargar los datos después de crear la búsqueda
  }

  // Función para filtrar las búsquedas o actividades del usuario
  void _filterUserItems() {
    setState(() {
      print("Inicio del filtrado");

      if (mostrarAcciones) {
        if (viewingSearches) {
          print("Filtrando búsquedas...");
          if (viewingVolunteer) {
            // Filtrar búsquedas donde el usuario está como voluntario
            filteredSearches = searches.where((busqueda) {
              bool isVolunteer = busqueda.voluntarioId == widget.persona.dni &&
                  busqueda.consumidorId != widget.persona.dni;
              print("Buscando voluntario - $isVolunteer: ${busqueda.nombre}");
              return isVolunteer;
            }).toList();
          } else {
            // Filtrar búsquedas creadas por el consumidor (el usuario)
            filteredSearches = searches.where((busqueda) {
              bool isCreator = busqueda.consumidorId == widget.persona.dni;
              print("Buscando creadas por el consumidor - $isCreator: ${busqueda.nombre}");
              return isCreator;
            }).toList();
          }
          print("Lista filtrada de búsquedas: $filteredSearches");
        } else {
          print("Filtrando actividades...");
          if (viewingParticipant) {
            // Filtrar actividades donde el usuario es un participante
            filteredActivities = activities.where((actividad) {
              bool isParticipant = actividad.participantes.contains(widget.persona.dni) &&
                  actividad.ofertanteId != widget.persona.dni;
              print("Buscando actividades de participantes - $isParticipant: ${actividad.nombre}");
              return isParticipant;
            }).toList();
          } else {
            // Filtrar actividades creadas por el ofertante (el usuario)
            filteredActivities = activities.where((actividad) {
              bool isCreator = actividad.ofertanteId == widget.persona.dni;
              print("Buscando creadas por el ofertante - $isCreator: ${actividad.nombre}");
              return isCreator;
            }).toList();
          }
          print("Lista filtrada de actividades: $filteredActivities");
        }
      } else {
        // Mostrar todas las búsquedas y actividades si no está en "Acciones"
        print("No está en Acciones, mostrando todas las búsquedas y actividades.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar los elementos cuando el estado cambia
    _filterUserItems();

    // Obtener el tamaño de la pantalla
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A9D8F), // Azul verdoso
        title: Row(
          children: [
            IconButton(
              onPressed: _loadData, // Llama al método _loadData para recargar
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeaderButton('Búsquedas', viewingSearches, () {
                    setState(() {
                      viewingSearches = true;
                    });
                  }, screenWidth),
                  SizedBox(width: screenWidth * 0.02),
                  // Ajuste de tamaño dinámico
                  _buildHeaderButton('Actividades', !viewingSearches, () {
                    setState(() {
                      viewingSearches = false;
                    });
                  }, screenWidth),
                  SizedBox(width: screenWidth * 0.02),
                  // Ajuste de tamaño dinámico
                  _buildHeaderButton('Acciones', mostrarAcciones, () {
                    setState(() {
                      mostrarAcciones = !mostrarAcciones;
                    });
                  }, screenWidth),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showUserDialog(); // Mostrar el diálogo de usuario
            },
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (mostrarAcciones) _buildAcciones(),
          // Mostrar las acciones si está activado
          Expanded(
            child: viewingSearches
                ? _buildSearchesList() // Mostrar las búsquedas filtradas
                : _buildActivitiesList(), // Mostrar las actividades filtradas
          ),
          _buildCreateButton(),
          // Nuevo widget que gestiona los botones dinámicos
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String text, bool isSelected, VoidCallback onPressed, double screenWidth) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF76C893) : const Color(0xFF2A9D8F),
        foregroundColor: Colors.white,
        elevation: isSelected ? 4 : 0,
        side: BorderSide(color: Colors.black12, width: isSelected ? 2 : 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.025, // Más pequeño, 2.5% de la pantalla
          vertical: 8, // Reducido para que el botón sea más pequeño
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenWidth > 400 ? 14 : 12, // Aún más pequeño en pantallas pequeñas
        ),
      ),
    );
  }

  // Widget para mostrar los botones de "Mis Búsquedas" y "Mis Actividades" cuando "Acciones" está activado
  Widget _buildAcciones() {
    final tipoUsuario = widget.persona.tipo;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        // Ajuste para que los botones se distribuyan en varias filas
        alignment: WrapAlignment.center,
        children: [
          // Mostrar "Mis Búsquedas" para Consumidor y Ambos
          if (tipoUsuario == 'Consumidor' || tipoUsuario == 'Ambos')
            _buildActionButton('Mis Búsquedas',
                viewingSearches && !viewingVolunteer &&
                    !viewingParticipant, () {
                  setState(() {
                    viewingSearches = true;
                    viewingVolunteer = false;
                    viewingParticipant = false;
                  });
                }),

          // Mostrar "Mis Actividades" para Ofertante y Ambos
          if (tipoUsuario == 'Ofertante' || tipoUsuario == 'Ambos')
            _buildActionButton('Mis Actividades',
                !viewingSearches && !viewingVolunteer &&
                    !viewingParticipant, () {
                  setState(() {
                    viewingSearches = false;
                    viewingVolunteer = false;
                    viewingParticipant = false;
                  });
                }),

          // Mostrar "Voluntariando" solo para Ofertante y Ambos
          if (tipoUsuario == 'Ofertante' || tipoUsuario == 'Ambos')
            _buildActionButton(
                'Voluntariando', viewingSearches && viewingVolunteer, () {
              setState(() {
                viewingSearches = true;
                viewingVolunteer = true;
                viewingParticipant = false;
              });
            }),

          // Mostrar "Participando" solo para Consumidor y Ambos
          if (tipoUsuario == 'Consumidor' || tipoUsuario == 'Ambos')
            _buildActionButton(
                'Participando', !viewingSearches && viewingParticipant, () {
              setState(() {
                viewingSearches = false;
                viewingVolunteer = false;
                viewingParticipant = true;
              });
            }),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, bool isActive, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: isActive ? const Color(0xFF2A9D8F) : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }

  // Métodos para construir la lista de búsquedas y actividades
  Widget _buildSearchesList() {
    print('Mostrando lista de búsquedas: $filteredSearches');
    return ListView.builder(
      itemCount: filteredSearches.length,
      itemBuilder: (context, index) {
        var busqueda = filteredSearches[index];
        print('Buscando item $index: ${busqueda.nombre}');
        return ListTile(
          title: Text(busqueda.nombre),
          subtitle: Text(busqueda.descripcion),
          onTap: () {
            _showDetailsDialog(busqueda);
          },
        );
      },
    );
  }


  Widget _buildActivitiesList() {
    print('Mostrando lista de actividades: $filteredActivities');
    return ListView.builder(
      itemCount: filteredActivities.length,
      itemBuilder: (context, index) {
        var actividad = filteredActivities[index];
        print('Buscando item $index: ${actividad.nombre}');
        return ListTile(
          title: Text(actividad.nombre),
          subtitle: Text(actividad.descripcion),
          onTap: () {
            _showDetailsDialog(actividad);
          },
        );
      },
    );
  }

  void _showDetailsDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(viewingSearches
              ? 'Detalles de la Búsqueda'
              : 'Detalles de la Actividad'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nombre: ${item.nombre}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Descripción: ${item.descripcion}',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Ubicación: ${item.ubicacion}',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Duración: ${item.duracion}',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Fecha: ${item.fecha}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Requisitos: ${item.requisitos}',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),

                // Mostrar participantes solo para actividades
                if (!viewingSearches) ...[
                  // Mostrar participantes en la interfaz
                  if (item.participantes != null &&
                      item.participantes.isNotEmpty)
                    Column(
                      children: [
                        Text('Participantes(${item.participantes?.length ??
                            0}/${item.numParticipantes ?? 0}):',
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        for (var participante in item.participantes)
                          FutureBuilder<Persona?>(
                            future: firebaseDB.leerPersona(participante),
                            // Obtener la persona por su DNI
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator(); // Mostrar cargando mientras obtenemos el nombre
                              }
                              if (snapshot.hasError) {
                                return Text('Error al cargar el nombre');
                              }
                              if (snapshot.data == null) {
                                return Text('Participante desconocido');
                              }
                              return Text('Participante: ${snapshot.data!
                                  .nombre} ${snapshot.data!.apellidos}',
                                  style: TextStyle(fontSize: 14));
                            },
                          ),
                      ],
                    )
                  else
                    Text('No hay participantes aún.',
                        style: TextStyle(fontSize: 14)),
                ],

                // Mostrar voluntario solo para búsquedas
                if (viewingSearches) ...[
                  SizedBox(height: 8),
                  // Mostrar nombre y apellido del voluntario si está asignado
                  FutureBuilder<Persona?>(
                    future: firebaseDB.leerPersona(item.voluntarioId ?? ''),
                    // Usar la ID del voluntario o un valor vacío si no está asignado
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Mostrar cargando mientras obtenemos el nombre
                      }
                      if (snapshot.hasError) {
                        return Text('Error al cargar el voluntario');
                      }
                      if (snapshot.data == null) {
                        return Text('Voluntario: No asignado');
                      }
                      // Mostrar el nombre y apellido del voluntario
                      return Text(
                        'Voluntario: ${snapshot.data!.nombre} ${snapshot.data!
                            .apellidos}',
                        style: TextStyle(fontSize: 16),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            // Acción para "Participar" si es una búsqueda y el voluntario aún no está asignado
            if (viewingSearches &&
                item.voluntarioId == null &&
                widget.persona.tipo != 'Consumidor' &&
                widget.persona.dni != item.consumidorId)
              TextButton(
                onPressed: () async {
                  print('Asignando voluntario: ${widget.persona
                      .dni} a la búsqueda ${item.id}');
                  await FirebaseDB.asignarVoluntario(
                      item.id, widget.persona.dni);
                  await _loadData();
                  Navigator.of(context).pop();
                },
                child: const Text('Participar'),
              ),

            // Acción para "Unirse" si es una actividad, no es participante, y no se ha alcanzado el número máximo de participantes
            if (!viewingSearches &&
                (item.participantes == null ||
                    !item.participantes.contains(widget.persona.dni)) &&
                (item.numParticipantes == null ||
                    item.participantes.length < item.numParticipantes) &&
                item.ofertanteId != widget.persona
                    .dni) // Asegurarse de que el usuario no es el ofertante
              TextButton(
                onPressed: () async {
                  print('Agregando participante: ${widget.persona
                      .dni} a la actividad ${item.id}');
                  await FirebaseDB.agregarParticipante(
                      item.id, widget.persona.dni);
                  await _loadData();
                  Navigator.of(context).pop();
                },
                child: const Text('Unirse'),
              ),

            // Mostrar botón Editar solo si el dni coincide con ofertanteId o consumidorId
            if ((viewingSearches && item.consumidorId == widget.persona.dni) ||
                (!viewingSearches && item.ofertanteId == widget.persona.dni))
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Cerrar el cuadro de diálogo de detalles
                  _showEditDialog(isActivity: !viewingSearches,
                      item: item); // Abrir cuadro de edición
                },
                child: const Text('Editar'),
              ),

            // Mostrar botón Eliminar solo si el dni coincide con ofertanteId o consumidorId
            if ((viewingSearches && item.consumidorId == widget.persona.dni) ||
                (!viewingSearches && item.ofertanteId == widget.persona.dni))
              TextButton(
                onPressed: () async {
                  if (viewingSearches) {
                    await firebaseDB.eliminarBusqueda(
                        item.id); // Eliminar búsqueda
                  } else {
                    await firebaseDB.eliminarActividad(
                        item.id); // Eliminar actividad
                  }
                  Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                  _loadData(); // Recargar datos
                },
                child: const Text('Eliminar'),
              ),

            // Botón de cerrar
            TextButton(
              onPressed: () {
                print('Cerrando el cuadro de diálogo');
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Método para crear el botón "Crear Nueva Actividad" o "Crear Nueva Búsqueda"
  Widget _buildCreateButton() {
    switch (widget.persona.tipo) {
      case 'Ofertante':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              _showCreateDialog(isActivity: true); // Crear nueva actividad
            },
            child: const Text('Crear Nueva Actividad'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF2A9D8F),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        );
      case 'Consumidor':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              _showCreateDialog(isActivity: false); // Crear nueva búsqueda
            },
            child: const Text('Crear Nueva Búsqueda'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF2A9D8F),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        );
      case 'Ambos':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showCreateDialog(isActivity: false); // Crear búsqueda
                  },
                  child: const Text('Crear Nueva Búsqueda'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF76C893),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showCreateDialog(isActivity: true); // Crear actividad
                  },
                  child: const Text('Crear Nueva Actividad'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF2A9D8F),
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox(); // Si no tiene tipo, no muestra nada
    }
  }

  void _showCreateDialog({required bool isActivity}) {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController descripcionController = TextEditingController();
    final TextEditingController ubicacionController = TextEditingController();
    final TextEditingController requisitosController = TextEditingController();
    final TextEditingController numParticipantesController = TextEditingController();
    int? horas; // Para la duración
    int? minutos; // Para la duración
    DateTime? fecha; // Para la fecha

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _selectDuration() async {
              // Mostrar un diálogo personalizado para capturar horas y minutos
              await showDialog(
                context: context,
                builder: (context) {
                  final TextEditingController horasController = TextEditingController();
                  final TextEditingController minutosController = TextEditingController();

                  return AlertDialog(
                    title: const Text('Seleccionar Duración'),
                    content: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: horasController,
                            decoration: const InputDecoration(
                                labelText: 'Horas'),
                            keyboardType: TextInputType.visiblePassword,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: minutosController,
                            decoration: const InputDecoration(
                                labelText: 'Minutos'),
                            keyboardType: TextInputType.visiblePassword,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Cerrar el cuadro de diálogo
                        },
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          final int? enteredHoras = int.tryParse(
                              horasController.text.trim());
                          final int? enteredMinutos = int.tryParse(
                              minutosController.text.trim());

                          if (enteredHoras == null || enteredMinutos == null ||
                              enteredHoras < 0 || enteredMinutos < 0 ||
                              enteredMinutos >= 60) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(
                                  'Por favor, ingrese una duración válida')),
                            );
                            return;
                          }

                          setState(() {
                            horas = enteredHoras;
                            minutos = enteredMinutos;
                          });

                          Navigator.of(context)
                              .pop(); // Cerrar el cuadro de diálogo
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  );
                },
              );
            }

            Future<void> _selectDate() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null && picked != fecha) {
                setState(() => fecha = picked);
              }
            }

            return AlertDialog(
              title: Text(isActivity ? 'Crear Actividad' : 'Crear Búsqueda'),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nombreController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      TextField(
                        controller: descripcionController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                            labelText: 'Descripción'),
                      ),
                      TextField(
                        controller: ubicacionController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                            labelText: 'Ubicación'),
                      ),
                      ListTile(
                        title: Text(horas == null || minutos == null
                            ? 'Seleccionar Duración'
                            : 'Duración: ${horas}h ${minutos}m'),
                        trailing: const Icon(Icons.timer),
                        onTap: _selectDuration,
                      ),
                      ListTile(
                        title: Text(fecha == null
                            ? 'Seleccionar Fecha'
                            : 'Fecha: ${fecha!.toLocal()}'.split(' ')[0]),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _selectDate,
                      ),
                      TextField(
                        controller: requisitosController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                            labelText: 'Requisitos'),
                      ),
                      if (isActivity)
                        TextField(
                          controller: numParticipantesController,
                          decoration: const InputDecoration(
                              labelText: 'Número de Participantes'),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (nombreController.text
                        .trim()
                        .isEmpty ||
                        descripcionController.text
                            .trim()
                            .isEmpty ||
                        ubicacionController.text
                            .trim()
                            .isEmpty ||
                        horas == null ||
                        minutos == null ||
                        fecha == null ||
                        requisitosController.text
                            .trim()
                            .isEmpty ||
                        (isActivity &&
                            (numParticipantesController.text
                                .trim()
                                .isEmpty ||
                                int.tryParse(numParticipantesController.text) ==
                                    null ||
                                int.parse(numParticipantesController.text) <=
                                    0))) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(
                            'Por favor, complete todos los campos correctamente')),
                      );
                      return;
                    }

                    final String duracionStr = '${horas}h ${minutos}m';
                    final String fechaStr = '${fecha!.year}-${fecha!.month
                        .toString().padLeft(2, '0')}-${fecha!.day.toString()
                        .padLeft(2, '0')}';

                    if (isActivity) {
                      Actividad nuevaActividad = Actividad(
                        id: 'nuevo_id',
                        ofertanteId: widget.persona.dni,
                        nombre: nombreController.text.trim(),
                        descripcion: descripcionController.text.trim(),
                        ubicacion: ubicacionController.text.trim(),
                        duracion: duracionStr,
                        fecha: fechaStr,
                        requisitos: requisitosController.text.trim(),
                        numParticipantes: int.parse(numParticipantesController
                            .text.trim()),
                      );
                      _crearActividad(nuevaActividad);
                    } else {
                      Busqueda nuevaBusqueda = Busqueda(
                        id: 'nuevo_id',
                        consumidorId: widget.persona.dni,
                        nombre: nombreController.text.trim(),
                        descripcion: descripcionController.text.trim(),
                        ubicacion: ubicacionController.text.trim(),
                        duracion: duracionStr,
                        fecha: fechaStr,
                        requisitos: requisitosController.text.trim(),
                      );
                      _crearBusqueda(nuevaBusqueda);
                    }

                    Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog({required bool isActivity, required dynamic item}) {
    final TextEditingController nombreController = TextEditingController(
        text: item.nombre);
    final TextEditingController descripcionController = TextEditingController(
        text: item.descripcion);
    final TextEditingController ubicacionController = TextEditingController(
        text: item.ubicacion);
    final TextEditingController requisitosController = TextEditingController(
        text: item.requisitos);
    final TextEditingController numParticipantesController = TextEditingController(
      text: isActivity && item.numParticipantes != null ? item.numParticipantes
          .toString() : '',
    );

    int? horas = int.tryParse(
        item.duracion.split('h')[0]?.trim() ?? ''); // Extraer horas
    int? minutos = int.tryParse(
        item.duracion.split('h')[1]?.replaceAll('m', '').trim() ??
            ''); // Extraer minutos
    DateTime? fecha = DateTime.tryParse(item.fecha);

    // Verificar si la lista de participantes no está vacía
    bool isParticipantListEmpty = isActivity &&
        (item.participantes == null || item.participantes.isEmpty);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _selectDuration() async {
              final TextEditingController horasController = TextEditingController(
                  text: horas?.toString() ?? '0');
              final TextEditingController minutosController = TextEditingController(
                  text: minutos?.toString() ?? '0');

              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Seleccionar Duración'),
                    content: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: horasController,
                            decoration: const InputDecoration(
                                labelText: 'Horas'),
                            keyboardType: TextInputType.visiblePassword,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: minutosController,
                            decoration: const InputDecoration(
                                labelText: 'Minutos'),
                            keyboardType: TextInputType.visiblePassword,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          final int? enteredHoras = int.tryParse(
                              horasController.text.trim());
                          final int? enteredMinutos = int.tryParse(
                              minutosController.text.trim());

                          if (enteredHoras == null || enteredMinutos == null ||
                              enteredHoras < 0 || enteredMinutos < 0 ||
                              enteredMinutos >= 60) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(
                                  'Por favor, ingrese una duración válida')),
                            );
                            return;
                          }

                          setState(() {
                            horas = enteredHoras;
                            minutos = enteredMinutos;
                          });

                          Navigator.of(context).pop();
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  );
                },
              );
            }

            Future<void> _selectDate() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: fecha ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null && picked != fecha) {
                setState(() => fecha = picked);
              }
            }

            return AlertDialog(
              title: Text(isActivity ? 'Editar Actividad' : 'Editar Búsqueda'),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nombreController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      TextField(
                        controller: descripcionController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                            labelText: 'Descripción'),
                      ),
                      TextField(
                        controller: ubicacionController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                            labelText: 'Ubicación'),
                      ),
                      ListTile(
                        title: Text(horas == null || minutos == null
                            ? 'Seleccionar Duración'
                            : 'Duración: ${horas}h ${minutos}m'),
                        trailing: const Icon(Icons.timer),
                        onTap: _selectDuration,
                      ),
                      ListTile(
                        title: Text(fecha == null
                            ? 'Seleccionar Fecha'
                            : 'Fecha: ${fecha!.toLocal()}'.split(' ')[0]),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _selectDate,
                      ),
                      TextField(
                        controller: requisitosController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                            labelText: 'Requisitos'),
                      ),
                      if (isActivity && isParticipantListEmpty)
                        TextField(
                          controller: numParticipantesController,
                          decoration: const InputDecoration(
                              labelText: 'Número de Participantes'),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      if (isActivity && !isParticipantListEmpty)
                        const Text(
                          'El número de participantes no se puede editar porque ya hay participantes registrados.',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    if (nombreController.text
                        .trim()
                        .isEmpty ||
                        descripcionController.text
                            .trim()
                            .isEmpty ||
                        ubicacionController.text
                            .trim()
                            .isEmpty ||
                        horas == null ||
                        minutos == null ||
                        fecha == null ||
                        requisitosController.text
                            .trim()
                            .isEmpty ||
                        (isActivity &&
                            isParticipantListEmpty &&
                            (numParticipantesController.text
                                .trim()
                                .isEmpty ||
                                int.tryParse(numParticipantesController.text) ==
                                    null ||
                                int.parse(numParticipantesController.text) <=
                                    0))) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(
                            'Por favor, complete todos los campos correctamente')),
                      );
                      return;
                    }

                    final String duracionStr = '${horas}h ${minutos}m';
                    final String fechaStr = '${fecha!.year}-${fecha!.month
                        .toString().padLeft(2, '0')}-${fecha!.day.toString()
                        .padLeft(2, '0')}';

                    Map<String, dynamic> data = {
                      'nombre': nombreController.text.trim(),
                      'descripcion': descripcionController.text.trim(),
                      'ubicacion': ubicacionController.text.trim(),
                      'duracion': duracionStr,
                      'fecha': fechaStr,
                      'requisitos': requisitosController.text.trim(),
                    };

                    if (isActivity) {
                      if (isParticipantListEmpty) {
                        data['numParticipantes'] =
                            int.parse(numParticipantesController.text.trim());
                      }
                      await firebaseDB.actualizarActividad(item.id, data);
                    } else {
                      await firebaseDB.actualizarBusqueda(item.id, data);
                    }

                    Navigator.of(context).pop();
                    _loadData();
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Método para mostrar el cuadro de diálogo del usuario con campos editables
  void _showUserDialog() {
    final TextEditingController nombreController = TextEditingController(
        text: widget.persona.nombre);
    final TextEditingController apellidosController = TextEditingController(
        text: widget.persona.apellidos);
    final TextEditingController emailController = TextEditingController(
        text: widget.persona.correo);
    final TextEditingController contrasenaController = TextEditingController(
        text: widget.persona.contrasena);
    final TextEditingController telefonoController = TextEditingController(
        text: widget.persona.telefono.toString());

    String tipo = widget.persona.tipo;
    String passwordStrength = '';
    Color passwordStrengthColor = Colors.grey;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void _validatePassword(String contrasena) {
              if (contrasena.length < 8) {
                passwordStrength = 'Poco segura';
                passwordStrengthColor = Colors.red;
              } else {
                final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(contrasena);
                final hasNumber = RegExp(r'[0-9]').hasMatch(contrasena);
                final hasSpecialChar = RegExp(r'[^a-zA-Z0-9]').hasMatch(
                    contrasena);

                if (hasLetter && hasNumber && hasSpecialChar) {
                  passwordStrength = 'Muy segura';
                  passwordStrengthColor = Colors.green;
                } else if (hasLetter && hasNumber) {
                  passwordStrength = 'Segura';
                  passwordStrengthColor = Colors.orange;
                } else {
                  passwordStrength = 'Poco segura';
                  passwordStrengthColor = Colors.red;
                }
              }
            }

            return AlertDialog(
              title: const Text('Editar Usuario'),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nombreController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      TextField(
                        controller: apellidosController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                            labelText: 'Apellidos'),
                      ),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                            labelText: 'Correo Electrónico'),
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      TextField(
                        controller: contrasenaController,
                        decoration: const InputDecoration(
                            labelText: 'Contraseña'),
                        obscureText: true,
                        onChanged: (value) {
                          setState(() => _validatePassword(value));
                        },
                      ),
                      Text(
                        'Seguridad de la contraseña: $passwordStrength',
                        style: TextStyle(color: passwordStrengthColor),
                      ),
                      if (tipo != 'Consumidor')
                        TextField(
                          controller: telefonoController,
                          decoration: const InputDecoration(
                              labelText: 'Teléfono'),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      const SizedBox(height: 10),
                      const Text('Tipo de usuario:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      CheckboxListTile(
                        title: const Text('Ofertante'),
                        value: tipo == 'Ofertante',
                        onChanged: (_) {
                          setState(() => tipo = 'Ofertante');
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Consumidor'),
                        value: tipo == 'Consumidor',
                        onChanged: (_) {
                          setState(() => tipo = 'Consumidor');
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Ambos'),
                        value: tipo == 'Ambos',
                        onChanged: (_) {
                          setState(() => tipo = 'Ambos');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    // Validar correo
                    final email = emailController.text.trim();
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(
                            'Por favor, ingrese un correo electrónico válido')),
                      );
                      return;
                    }

                    // Validar teléfono
                    int telefono = 0;
                    if (tipo != 'Consumidor') {
                      final telefonoText = telefonoController.text.trim();
                      final telefonoRegex = RegExp(
                          r'^(6\d{8}|7\d{8}|9\d{8}|8\d{8})$');
                      if (!telefonoRegex.hasMatch(telefonoText)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(
                              'Por favor, ingrese un número de teléfono válido')),
                        );
                        return;
                      }
                      telefono = int.tryParse(telefonoText) ?? 0;
                    }

                    // Actualizar los datos del usuario
                    widget.persona.nombre = nombreController.text;
                    widget.persona.apellidos = apellidosController.text;
                    widget.persona.correo = email;
                    widget.persona.contrasena = contrasenaController.text;
                    widget.persona.tipo = tipo;
                    widget.persona.telefono = telefono;

                    await FirebaseDB().actualizarPersona(widget.persona.dni, {
                      'nombre': widget.persona.nombre,
                      'apellidos': widget.persona.apellidos,
                      'correo': widget.persona.correo,
                      'contrasena': widget.persona.contrasena,
                      'telefono': telefono,
                      'tipo': widget.persona.tipo,
                    });
                    Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Datos actualizados')),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Función para filtrar la lista de búsquedas y actividades
  void filterList(String query) {
    print('Texto ingresado en la búsqueda: $query');

    // Filtrar las búsquedas basándose en la lista original
    filteredSearches = searches.where((busqueda) {
      return busqueda.nombre.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Filtrar las actividades basándose en la lista original
    filteredActivities = activities.where((actividad) {
      return actividad.nombre.toLowerCase().contains(query.toLowerCase());
    }).toList();

    print('Lista filtrada de búsquedas: $filteredSearches');
    print('Lista filtrada de actividades: $filteredActivities');

    // Llamar a setState para actualizar la UI
    setState(() {});
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          print('Cambio en la barra de búsqueda: $query');  // Muestra el cambio en la barra
          filterList(query); // Llama al filtro cada vez que cambia el texto
        },
        decoration: InputDecoration(
          labelText: 'Buscar...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

}
