// Módulo 2.5 · RadioButton, CheckBox y Select (FR-006).
// Qué muestra: opciones excluyentes (Radio), opción sí/no (Checkbox) y
// lista desplegable (Dropdown) con resumen visible del estado elegido.
// Contenido migrado del HomeScreen monolítico original (T032).
import 'package:flutter/material.dart';

import '../../shared/widgets/concepto_card.dart';
import '../../shared/widgets/error_contenido.dart';
import 'widgets/resumen_seleccion.dart';

/// Pantalla del módulo 2.5.
class Modulo25SeleccionScreen extends StatefulWidget {
  const Modulo25SeleccionScreen({super.key});

  @override
  State<Modulo25SeleccionScreen> createState() =>
      _Modulo25SeleccionScreenState();
}

class _Modulo25SeleccionScreenState extends State<Modulo25SeleccionScreen> {
  /// Opción excluyente elegida ('opcion1' | 'opcion2').
  String _radio = 'opcion1';

  /// Casilla de aceptación (sí/no).
  bool _checkbox = false;

  /// País elegido en el desplegable.
  String? _pais = 'MX';

  /// Error contenido en esta pantalla (FR-012).
  String? _error;

  static const Map<String, String> _paises = {
    'MX': 'México',
    'US': 'Estados Unidos',
    'ES': 'España',
    'AR': 'Argentina',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2.5 · Radio, Check y Select')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConceptoCard(
                queEs:
                    'El RadioButton elige UNA opción entre varias. El '
                    'CheckBox activa o desactiva UNA opción. El Select '
                    '(Dropdown) elige una de una lista desplegable.',
                paraQueSirve:
                    'En desarrollo móvil sirven para preferencias y '
                    'formularios: elegir un plan, aceptar términos o '
                    'seleccionar un país.',
                ejemploUso:
                    'Cambia la opción de radio, marca la casilla y elige '
                    'un país: el resumen muestra el estado elegido.',
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                ErrorContenido(mensaje: _error!),
                const SizedBox(height: 12),
              ],
              Text('Elige una opción:',
                  style: Theme.of(context).textTheme.titleSmall),
              Semantics(
                label: 'Opción 1',
                child: RadioListTile<String>(
                  title: const Text('Opción 1'),
                  value: 'opcion1',
                  // ignore: deprecated_member_use
                  groupValue: _radio,
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() => _radio = v!),
                ),
              ),
              Semantics(
                label: 'Opción 2',
                child: RadioListTile<String>(
                  title: const Text('Opción 2'),
                  value: 'opcion2',
                  // ignore: deprecated_member_use
                  groupValue: _radio,
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() => _radio = v!),
                ),
              ),
              Semantics(
                label: 'Acepto los términos',
                checked: _checkbox,
                child: CheckboxListTile(
                  title: Text(
                    'Acepto los términos',
                    style: TextStyle(
                      color: _checkbox ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: _checkbox,
                  onChanged: (v) => setState(() => _checkbox = v ?? false),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Selecciona tu país',
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Selecciona tu país',
                    border: OutlineInputBorder(),
                  ),
                  // ignore: deprecated_member_use
                  value: _pais,
                  items: [
                    for (final entry in _paises.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                  ],
                  onChanged: (v) => setState(() => _pais = v),
                ),
              ),
              const SizedBox(height: 12),
              ResumenSeleccion(
                radio: _radio,
                checkbox: _checkbox,
                pais: _pais == null ? '—' : _paises[_pais]!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
