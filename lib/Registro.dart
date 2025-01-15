import 'package:flutter/material.dart';
import 'package:proyectointegradojg2024/FirebaseDB.dart';
import 'package:proyectointegradojg2024/Persona.dart';

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();

  String? _selectedTipo;
  String? _dniError;
  String? _correoError;
  bool _obscurePassword = true;
  String _passwordStrength = 'Poco segura';
  Color _passwordStrengthColor = Colors.red;

  final FirebaseDB db = FirebaseDB();

  // Validación del DNI
  String? _validateDNI(String? value) {
    if (value == null || value.isEmpty) {
      return 'DNI es obligatorio';
    }

    final dniRegExp = RegExp(r'^\d{8}[A-Za-z]$');
    if (!dniRegExp.hasMatch(value)) {
      return 'DNI no existe';
    }
    return null;
  }

  // Validación de la contraseña
  String _validarContrasena(String contrasena) {
    if (contrasena.length < 8) {
      _passwordStrength = 'Poco segura';
      _passwordStrengthColor = Colors.red;
    } else {
      final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(contrasena);
      final hasNumber = RegExp(r'[0-9]').hasMatch(contrasena);
      final hasSpecialChar = RegExp(r'[^a-zA-Z0-9]').hasMatch(contrasena);

      if (hasLetter && hasNumber && hasSpecialChar) {
        _passwordStrength = 'Muy segura';
        _passwordStrengthColor = Colors.green;
      } else if (hasLetter && hasNumber) {
        _passwordStrength = 'Segura';
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrength = 'Poco segura';
        _passwordStrengthColor = Colors.red;
      }
    }
    return _passwordStrength;
  }

  // Validación del correo
  String? _validateCorreo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Correo es obligatorio';
    }

    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Correo no válido';
    }
    return null;
  }

  // Validación del teléfono
  String? _validateTelefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'Teléfono es obligatorio';
    }

    // Validar número de España
    final telefonoRegExp = RegExp(r'^(6\d{8}|7\d{8}|9\d{8}|8\d{8})$');
    if (!telefonoRegExp.hasMatch(value)) {
      return 'Teléfono no válido';
    }

    return null;
  }

  // Procesar el registro y guardar en la base de datos
  void _procesarRegistro() async {
    if (_formKey.currentState!.validate()) {
      // Crear la persona con los datos del formulario
      Persona persona = Persona(
        dni: _dniController.text,
        tipo: _selectedTipo ?? '',
        nombre: _nombreController.text,
        apellidos: _apellidosController.text,
        telefono: int.tryParse(_telefonoController.text) ?? 0,
        correo: _correoController.text,
        contrasena: _contrasenaController.text,
      );

      try {
        // Llamar al método para crear la persona en Firebase
        await db.crearPersona(persona);
        print('Persona registrada correctamente');

        // Redirigir al login después de registrar
        Navigator.pop(context);  // Vuelve a la pantalla de login
      } catch (e) {
        print('Error al registrar la persona: $e');
      }
    } else {
      print('Formulario no válido');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // DNI
              TextFormField(
                controller: _dniController,
                decoration: InputDecoration(
                  labelText: 'DNI',
                  errorText: _dniError,
                ),
                onChanged: (value) {
                  setState(() {
                    _dniError = _validateDNI(value);
                  });
                },
                keyboardType: TextInputType.text,
              ),
              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                keyboardType: TextInputType.text,
              ),
              // Apellidos
              TextFormField(
                controller: _apellidosController,
                decoration: InputDecoration(labelText: 'Apellidos'),
                keyboardType: TextInputType.text,
              ),
              // Contraseña
              TextFormField(
                controller: _contrasenaController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _validarContrasena(value);
                  });
                },
              ),
              Text(
                'Nivel de seguridad: $_passwordStrength',
                style: TextStyle(color: _passwordStrengthColor),
              ),
              // Correo
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _correoError = _validateCorreo(value);
                  });
                },
                validator: _validateCorreo,
              ),
              // Tipo (Dropdown)
              DropdownButton<String>(
                value: _selectedTipo,
                hint: Text("Seleccione una opción"),
                items: <String>['Ofertante', 'Consumidor', 'Ambos']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTipo = newValue;
                  });
                },
              ),
              // Teléfono (solo si no es Consumidor)
              if (_selectedTipo != 'Consumidor')
                TextFormField(
                  controller: _telefonoController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _validateTelefono,
                ),
              // Botón de registro
              ElevatedButton(
                onPressed: _procesarRegistro,
                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
