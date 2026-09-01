import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curso Movil Hibrido',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCountry = 'MX';
  bool _isChecked = false;
  String _selectedRadio = 'opcion1';
  bool _isSwitchOn = false;
  double _sliderValue = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widgets Esenciales'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Texto y Tipografia'),
              
              const Text(
                'Texto normal',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Texto en negrita',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Texto con color',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Texto con subrayado',
                style: TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 20),

              const SectionTitle('Tipos de Botones'),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _showSnackBar(context, 'ElevatedButton presionado'),
                    child: const Text('Elevado'),
                  ),
                  OutlinedButton(
                    onPressed: () => _showSnackBar(context, 'OutlinedButton presionado'),
                    child: const Text('Bordeado'),
                  ),
                  TextButton(
                    onPressed: () => _showSnackBar(context, 'TextButton presionado'),
                    child: const Text('Texto'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              ElevatedButton.icon(
                onPressed: () => _showSnackBar(context, 'Boton con icono'),
                icon: const Icon(Icons.favorite),
                label: const Text('Me gusta'),
              ),
              const SizedBox(height: 20),

              const SectionTitle('Controles de Entrada'),
              
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  hintText: 'Escribe tu nombre',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contrasena',
                  hintText: '********',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Selecciona tu pais',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCountry,
                items: const [
                  DropdownMenuItem(value: 'MX', child: Text('Mexico')),
                  DropdownMenuItem(value: 'US', child: Text('Estados Unidos')),
                  DropdownMenuItem(value: 'ES', child: Text('Espana')),
                  DropdownMenuItem(value: 'AR', child: Text('Argentina')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                  });
                  _showSnackBar(context, 'Pais seleccionado: $value');
                },
              ),
              
              if (_selectedCountry != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Pais seleccionado: $_selectedCountry',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              const SectionTitle('Seleccion y Opciones'),
              
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                      _showSnackBar(context, 
                        'Checkbox: ${_isChecked ? "Activado" : "Desactivado"}');
                    },
                  ),
                  Text(
                    _isChecked 
                      ? 'Acepto los terminos' 
                      : 'Acepto los terminos',
                    style: TextStyle(
                      color: _isChecked ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              Row(
                children: [
                  Radio<String>(
                    value: 'opcion1',
                    groupValue: _selectedRadio,
                    onChanged: (value) {
                      setState(() {
                        _selectedRadio = value!;
                      });
                      _showSnackBar(context, 'Opcion seleccionada: $value');
                    },
                  ),
                  Text(
                    'Opcion 1 ${_selectedRadio == "opcion1" ? "Seleccionada" : ""}',
                    style: TextStyle(
                      fontWeight: _selectedRadio == "opcion1" 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                      color: _selectedRadio == "opcion1" 
                        ? Colors.blue 
                        : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'opcion2',
                    groupValue: _selectedRadio,
                    onChanged: (value) {
                      setState(() {
                        _selectedRadio = value!;
                      });
                      _showSnackBar(context, 'Opcion seleccionada: $value');
                    },
                  ),
                  Text(
                    'Opcion 2 ${_selectedRadio == "opcion2" ? "Seleccionada" : ""}',
                    style: TextStyle(
                      fontWeight: _selectedRadio == "opcion2" 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                      color: _selectedRadio == "opcion2" 
                        ? Colors.blue 
                        : Colors.grey,
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Opcion seleccionada: $_selectedRadio',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const SectionTitle('Imagenes e Iconos'),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(
                    Icons.camera_alt,
                    size: 4,
                    color: Colors.blue,
                  ),
                  Image.network(
                    'https://picsum.photos/80/80',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const SectionTitle('Elementos Interactivos'),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isSwitchOn 
                      ? 'Notificaciones Activadas' 
                      : 'Notificaciones Desactivadas',
                    style: TextStyle(
                      color: _isSwitchOn ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: _isSwitchOn,
                    onChanged: (value) {
                      setState(() {
                        _isSwitchOn = value;
                      });
                      _showSnackBar(context, 
                        'Notificaciones: ${value ? "Activadas" : "Desactivadas"}');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Volumen:'),
                      Text(
                        '${_sliderValue.round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _sliderValue,
                    min: 0,
                    max: 100,
                    divisions: 10,
                    label: '${_sliderValue.round()}%',
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                      });
                    },
                  ),
                  LinearProgressIndicator(
                    value: _sliderValue / 100,
                    backgroundColor: Colors.grey[300],
                    color: _sliderValue > 70 
                      ? Colors.green 
                      : _sliderValue > 30 
                        ? Colors.orange 
                        : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const SectionTitle('Contenedores y Cards'),
              
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tarjeta informativa',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Este es un ejemplo de Card con informacion',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Container con decoracion personalizada'),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showAlertDialog(context),
                  icon: const Icon(Icons.warning_amber),
                  label: const Text('Mostrar Dialogo de Alerta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSnackBar(context, 'Boton flotante presionado'),
        child: const Icon(Icons.add),
        tooltip: 'Boton de accion flotante',
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Cerrar',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alerta Importante'),
          content: const Text(
            'Este es un dialogo de alerta.\n\n'
            'Puedes personalizarlo con texto, '
            'iconos y botones de accion.',
          ),
          icon: const Icon(
            Icons.warning,
            color: Colors.orange,
            size: 50,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Accion confirmada');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}