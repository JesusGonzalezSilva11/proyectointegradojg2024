import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyectointegradojg2024/FirebaseDB.dart';
import 'package:proyectointegradojg2024/Persona.dart';
import 'package:proyectointegradojg2024/Menu.dart';
import 'package:proyectointegradojg2024/Registro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final FirebaseDB db = FirebaseDB();
  String errorMessage = '';

  void _login() async {
    String nombre = _nombreController.text;
    String contrasena = _contrasenaController.text;

    if (nombre.isNotEmpty && contrasena.isNotEmpty) {
      try {
        final personas = await db.leerPersonas();
        final persona = personas.firstWhere(
              (p) => p.nombre == nombre && p.contrasena == contrasena,
          orElse: () => Persona(dni: '', tipo: '', nombre: '', apellidos: '', telefono: 0, correo: '', contrasena: ''),
        );

        if (persona.dni.isNotEmpty) {
          // Pasar el objeto persona al MenuScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MenuScreen(persona: persona),
            ),
          );
        } else {
          setState(() {
            errorMessage = 'Credenciales incorrectas.';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error al verificar el login.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(  // Centra todo el contenido en el eje principal
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Centra los elementos en el eje vertical
            crossAxisAlignment: CrossAxisAlignment.center,  // Centra los elementos en el eje horizontal
            children: <Widget>[
              TextField(
                controller: _nombreController,
                keyboardType: TextInputType.visiblePassword,  // Usa visiblePassword para que el teclado aparezca al menos
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              SizedBox(height: 20),  // Espacio entre campos
              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña'),
              ),
              SizedBox(height: 20),  // Espacio entre el botón de login y el error
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: TextStyle(color: Colors.red)),
              SizedBox(height: 20),  // Espacio adicional
              ElevatedButton(
                onPressed: _login,
                child: Text('Entrar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistroScreen()),
                  );
                },
                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
