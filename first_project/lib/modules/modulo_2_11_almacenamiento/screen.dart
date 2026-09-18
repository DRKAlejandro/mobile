// Módulo 2.11 · Almacenamiento (FR-006).
// Qué muestra: preferencias locales (shared_preferences) para guardar
// y recuperar un texto simple que persiste entre sesiones.
// Es la única demo con persistencia de toda la app (decisión clarify).
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/widgets/concepto_card.dart';
import '../../shared/widgets/error_contenido.dart';
import 'widgets/texto_guardado.dart';

/// Clave única del texto demo en las preferencias locales.
const String kClaveDemoTexto = 'demo_texto_2_11';

/// Pantalla del módulo 2.11.
class Modulo211AlmacenamientoScreen extends StatefulWidget {
  const Modulo211AlmacenamientoScreen({super.key});

  @override
  State<Modulo211AlmacenamientoScreen> createState() =>
      _Modulo211AlmacenamientoScreenState();
}

class _Modulo211AlmacenamientoScreenState
    extends State<Modulo211AlmacenamientoScreen> {
  /// Control del campo de texto de la demo.
  final TextEditingController _controlador = TextEditingController();

  /// Acceso perezoso a las preferencias locales (API nueva asíncrona).
  /// Se crea dentro del flujo con try/catch: en entornos sin plataforma
  /// registrada (p. ej. widget tests) el constructor avisa y la pantalla
  /// muestra el error contenido en vez de romperse (FR-008).
  SharedPreferencesAsync? _prefs;

  /// Devuelve las preferencias o null si no hay plataforma disponible.
  Future<SharedPreferencesAsync?> _obtenerPrefs() async {
    if (_prefs != null) return _prefs;
    try {
      return _prefs = SharedPreferencesAsync();
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Almacenamiento no disponible aquí: $e');
      }
      return null;
    }
  }

  /// Texto recuperado (vacío = aún sin guardar).
  String _guardado = '';

  /// `true` si el valor ya existía al abrir la pantalla.
  bool _esPrevio = false;

  /// Error contenido en esta pantalla (FR-008).
  String? _error;

  @override
  void initState() {
    super.initState();
    _recuperar();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  /// Guarda el texto; devuelve `false` si no hay plataforma disponible.
  Future<bool> _guardarValor(String texto) async {
    final prefs = await _obtenerPrefs();
    if (prefs == null) return false;
    await prefs.setString(kClaveDemoTexto, texto);
    return true;
  }

  /// Lee el valor previo al abrir: prueba visible de la persistencia.
  Future<void> _recuperar() async {
    try {
      final prefs = await _obtenerPrefs();
      if (prefs == null) return;
      final previo = await prefs.getString(kClaveDemoTexto);
      if (!mounted) return;
      setState(() {
        _guardado = previo ?? '';
        _esPrevio = previo != null && previo.isNotEmpty;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'No se pudo leer lo guardado: $e');
      }
    }
  }

  /// Guarda el texto actual en las preferencias locales.
  Future<void> _guardar() async {
    setState(() => _error = null);
    try {
      final texto = _controlador.text.trim();
      if (texto.isEmpty) {
        setState(() => _error = 'Escribe un texto antes de guardar.');
        return;
      }
      final ok = await _guardarValor(texto);
      if (!mounted) return;
      if (!ok) return; // _obtenerPrefs ya mostró el error contenido.
      setState(() {
        _guardado = texto;
        _esPrevio = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Texto guardado en el dispositivo')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'No se pudo guardar el texto: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2.11 · Almacenamiento')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConceptoCard(
                queEs:
                    'El almacenamiento en preferencias guarda pares '
                    'clave-valor simples (como un texto) en el dispositivo, '
                    'que sobreviven al cerrar la app.',
                paraQueSirve:
                    'En desarrollo móvil sirve para recordar ajustes o datos '
                    'pequeños (p. ej. el nombre del usuario o el tema '
                    'elegido) sin necesidad de internet.',
                ejemploUso:
                    'Escribe un texto y pulsa "Guardar": cierra y reabre la '
                    'app para comprobar que sigue ahí.',
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                ErrorContenido(mensaje: _error!),
                const SizedBox(height: 12),
              ],
              Semantics(
                label: 'Campo para escribir el texto a guardar',
                textField: true,
                child: TextField(
                  controller: _controlador,
                  decoration: const InputDecoration(
                    labelText: 'Texto a guardar',
                    hintText: 'Escribe algo para recordar',
                    prefixIcon: Icon(Icons.save_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _guardar(),
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                button: true,
                label: 'Guardar el texto en el dispositivo',
                child: ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('Guardar'),
                ),
              ),
              const SizedBox(height: 12),
              TextoGuardado(texto: _guardado, esPrevio: _esPrevio),
            ],
          ),
        ),
      ),
    );
  }
}
