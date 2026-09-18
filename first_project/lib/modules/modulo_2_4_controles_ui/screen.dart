// Módulo 2.4 · Input, Label y Button (FR-005).
// Qué muestra: campo de texto (TextField), etiqueta (Text) y botón
// (ElevatedButton) que refleja lo escrito como resultado visible.
// Contenido migrado del HomeScreen monolítico original (T031).
import 'package:flutter/material.dart';

import '../../shared/widgets/concepto_card.dart';
import '../../shared/widgets/error_contenido.dart';
import 'widgets/eco_resultado.dart';

/// Pantalla del módulo 2.4.
class Modulo24ControlesUiScreen extends StatefulWidget {
  const Modulo24ControlesUiScreen({super.key});

  @override
  State<Modulo24ControlesUiScreen> createState() =>
      _Modulo24ControlesUiScreenState();
}

class _Modulo24ControlesUiScreenState extends State<Modulo24ControlesUiScreen> {
  /// Control del campo de texto de la demo.
  final TextEditingController _controlador = TextEditingController();

  /// Texto reflejado al pulsar el botón (resultado visible de la demo).
  String _ecoVisible = '';

  /// Error contenido en esta pantalla (FR-012).
  String? _error;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  /// Refleja el texto ingresado como resultado (demo 2.4).
  void _reflejarTexto() {
    setState(() => _error = null);
    try {
      final texto = _controlador.text.trim();
      setState(() {
        _ecoVisible =
            texto.isEmpty ? 'Escribe algo primero y pulsa el botón.' : texto;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Texto reflejado abajo')),
      );
    } catch (e) {
      setState(() => _error = 'No se pudo reflejar el texto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2.4 · Input, Label y Button')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConceptoCard(
                queEs:
                    'El campo de texto (TextField) captura lo que escribe el '
                    'usuario. La etiqueta (Text/Label) lo identifica y el '
                    'botón (Button) ejecuta la acción.',
                paraQueSirve:
                    'En desarrollo móvil sirven para formularios: pedir el '
                    'nombre, el correo o una contraseña y actuar al pulsar '
                    'el botón (p. ej. registrarse).',
                ejemploUso:
                    'Escribe tu nombre en el campo y pulsa "Mostrar": '
                    'el texto aparece reflejado como resultado.',
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                ErrorContenido(mensaje: _error!),
                const SizedBox(height: 12),
              ],
              Semantics(
                label: 'Campo para escribir tu nombre',
                textField: true,
                child: TextField(
                  controller: _controlador,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    hintText: 'Escribe tu nombre',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _reflejarTexto(),
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                button: true,
                label: 'Mostrar el texto escrito',
                child: ElevatedButton(
                  onPressed: _reflejarTexto,
                  child: const Text('Mostrar'),
                ),
              ),
              const SizedBox(height: 12),
              EcoResultado(texto: _ecoVisible),
            ],
          ),
        ),
      ),
    );
  }
}
