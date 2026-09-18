// Módulo 2.12 · APIs y Servicios Web (FR-003–FR-007, FR-010/FR-011).
// Qué muestra: explicación de API/servicio web + herramienta visual que
// consulta la PokeAPI (sin clave) con auto-carga de pikachu, buscador
// normalizado, ejemplos, aleatorio 1–1025 y estados visibles.
// Sin conexión → ficha ilustrativa con badge SIMULADO (FR-010).
//
// Estilo exclusivo 8-bits Pokédex/GameBoy: AppBar rojo, luces de consola,
// diálogos del Prof. Oak, botones arcade y ficha amarilla pixelada.
import 'package:flutter/material.dart';

import 'models/pokemon.dart';
import 'services/pokemon_service.dart';
import 'widgets/ficha_pokemon.dart';
import 'widgets/pixel_theme.dart';

/// Pantalla del módulo 2.12.
class Modulo212ApisScreen extends StatefulWidget {
  const Modulo212ApisScreen({super.key});

  @override
  State<Modulo212ApisScreen> createState() => _Modulo212ApisScreenState();
}

class _Modulo212ApisScreenState extends State<Modulo212ApisScreen> {
  /// Control del campo de búsqueda de la herramienta.
  final TextEditingController _controlador = TextEditingController();

  /// Ficha visible (`null` = aún sin resultado; solo-sesión).
  Pokemon? _pokemon;

  /// `true` durante la consulta HTTP (indicador de carga).
  bool _cargando = true;

  /// Error contenido en esta pantalla (FR-009: no bloquea el menú).
  String? _error;

  @override
  void initState() {
    super.initState();
    // Ejemplo inicial automático: pikachu (aclaración 1).
    _buscar('pikachu');
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  /// Ejecuta una consulta y refleja carga/resultado/error (data-model.md).
  Future<void> _buscar(String entrada) async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final pokemon = await obtenerPokemon(entrada);
      if (!mounted) return;
      setState(() => _pokemon = pokemon);
    } on EntradaVacia {
      // Validación local: no hubo llamada (contrato pokemon-service.md).
      if (!mounted) return;
      setState(() => _error = 'Escribe un nombre o número antes de buscar.');
    } on PokemonNoEncontrado {
      // 404: se conserva la última ficha válida, si existe.
      if (!mounted) return;
      setState(() => _error =
          'No se encontró ese pokémon. Revisa el nombre o número e inténtalo de nuevo.');
    } on ErrorConexion {
      // Sin red/servicio: respaldo ilustrativo etiquetado (aclaración 3).
      if (!mounted) return;
      setState(() {
        _pokemon = kPikachuSimulado;
        _error = 'Sin conexión: se muestra un ejemplo simulado. '
            'Reintenta con internet para datos reales.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo completar la búsqueda: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Consulta un número aleatorio entre 1 y 1025 (aclaración 4).
  void _aleatorio() => _buscar(numeroAleatorio().toString());

  /// Barra superior de luces estilo Pokédex.
  Widget _lucesPokedex() {
    Widget luz(Color color, double tamano) => Container(
          width: tamano,
          height: tamano,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: PixelPoke.tinta, width: 3),
            boxShadow: const [
              BoxShadow(
                  color: Colors.white54,
                  offset: Offset(-2, -2),
                  blurRadius: 0),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: PixelPoke.rojo,
        border: Border(
          bottom: BorderSide(color: PixelPoke.tinta, width: 4),
        ),
      ),
      child: Row(
        children: [
          luz(const Color(0xFF42C0FB), 34),
          const SizedBox(width: 12),
          luz(const Color(0xFFFF5252), 16),
          const SizedBox(width: 8),
          luz(const Color(0xFFFFEB3B), 16),
          const SizedBox(width: 8),
          luz(const Color(0xFF69F0AE), 16),
          const Spacer(),
          Text('POKéDEX v8-BIT',
              style: PixelPoke.pixelSombra(12, Colors.white)),
        ],
      ),
    );
  }

  /// Diálogo del profesor con las 3 partes obligatorias (FR-003).
  Widget _dialogoOak() {
    Widget linea(String titulo, String texto) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RichText(
            text: TextSpan(
              style: PixelPoke.pixel(13),
              children: [
                TextSpan(
                  text: '$titulo ',
                  style:
                      PixelPoke.pixel(13, PixelPoke.azulOscuro),
                ),
                TextSpan(text: texto),
              ],
            ),
          ),
        );
    return Container(
      decoration: PixelPoke.dialogoPoke(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: PixelPoke.verdePantalla,
                  border: Border.all(color: PixelPoke.tinta, width: 3),
                ),
                child: const Icon(Icons.catching_pokemon,
                    size: 24, color: PixelPoke.tinta),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('¡HOLA! ¡TE HABLA EL PROF. OAK!',
                    style: PixelPoke.pixel(13, PixelPoke.rojoOscuro)),
              ),
              Text('▼', style: PixelPoke.pixel(14)),
            ],
          ),
          const SizedBox(height: 10),
          linea('¿QUÉ ES?',
              'Una API es una dirección de internet que devuelve datos. La app hace un REQUEST y recibe un RESPONSE en JSON: texto con llaves, nombres y valores.'),
          linea('¿PARA QUÉ SIRVE?',
              'En móvil sirve para mostrar datos que no están en el teléfono (el clima, noticias o la ficha de un pokémon) sin guardarlos en la app.'),
          linea('TU MISIÓN:',
              'Esta POKéDEX consulta la PokeAPI (gratis y sin clave): pide GET /pokemon/pikachu y dibuja su ficha. Al abrir ya ves a PIKACHU; busca otro, prueba los ejemplos o pulsa ALEATORIO.'),
          Text('PULSA START PARA EMPEZAR ▶',
              style: PixelPoke.pixel(11, PixelPoke.azulOscuro)),
        ],
      ),
    );
  }

  /// Caja de error estilo diálogo de combate.
  Widget _errorPixel(String mensaje) {
    return Container(
      decoration: BoxDecoration(
        color: PixelPoke.dialogo,
        border: Border.all(color: PixelPoke.rojo, width: 4),
        boxShadow: const [
          BoxShadow(color: PixelPoke.tinta, offset: Offset(6, 6)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: PixelPoke.rojo,
              border: Border.all(color: PixelPoke.tinta, width: 3),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('¡FALLO! $mensaje', style: PixelPoke.pixel(12)),
          ),
        ],
      ),
    );
  }

  /// Botón arcade con sombra maciza.
  Widget _botonPixel({
    required String texto,
    required IconData icono,
    required Color fondo,
    required Color textoColor,
    required VoidCallback? onPressed,
    required String semantics,
  }) {
    return Semantics(
      button: true,
      label: semantics,
      child: GestureDetector(
        onTap: onPressed,
        child: Opacity(
          opacity: onPressed == null ? 0.5 : 1,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: fondo,
              border: Border.all(color: PixelPoke.tinta, width: 4),
              boxShadow: const [
                BoxShadow(color: PixelPoke.tinta, offset: Offset(4, 4)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, size: 18, color: textoColor),
                const SizedBox(width: 8),
                Text(texto,
                    style: PixelPoke.pixel(13, textoColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Chip de ejemplo con color de cada pokémon.
  Widget _chipEjemplo(String ejemplo) {
    final Color fondo = switch (ejemplo) {
      'pikachu' => PixelPoke.amarillo,
      'charizard' => const Color(0xFFEE8130),
      'mewtwo' => const Color(0xFFB388EB),
      _ => PixelPoke.dialogo,
    };
    final oscuro = ejemplo == 'pikachu';
    return Semantics(
      button: true,
      label: 'Ver ejemplo $ejemplo',
      child: GestureDetector(
        onTap: _cargando ? null : () => _buscar(ejemplo),
        child: Opacity(
          opacity: _cargando ? 0.5 : 1,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: fondo,
              border: Border.all(color: PixelPoke.tinta, width: 3),
              boxShadow: const [
                BoxShadow(color: PixelPoke.tinta, offset: Offset(3, 3)),
              ],
            ),
            child: Text(
              ejemplo.toUpperCase(),
              style: PixelPoke.pixel(
                  12, oscuro ? PixelPoke.tinta : Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelPoke.fondoConsola,
      appBar: AppBar(
        backgroundColor: PixelPoke.rojo,
        foregroundColor: Colors.white,
        title: Text(
          '2.12 · APIs y Servicios Web',
          style: PixelPoke.pixelSombra(14, Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _lucesPokedex(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogoOak(),
                  const SizedBox(height: 16),
                  if (_error != null) ...[
                    _errorPixel(_error!),
                    const SizedBox(height: 16),
                  ],
                  // Consola de búsqueda.
                  Container(
                    decoration: PixelPoke.consola(fondo: PixelPoke.azul),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('>> BUSCADOR POKéMON',
                            style: PixelPoke.pixelSombra(13)),
                        const SizedBox(height: 10),
                        Semantics(
                          label:
                              'Campo para buscar por nombre o número de pokémon',
                          textField: true,
                          child: TextField(
                            controller: _controlador,
                            textInputAction: TextInputAction.search,
                            style: PixelPoke.pixel(14),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: PixelPoke.dialogo,
                              labelText: 'Nombre o número',
                              labelStyle: PixelPoke.pixel(12),
                              hintText: 'pikachu o 25',
                              hintStyle: PixelPoke.pixel(
                                  12, Colors.grey.shade600),
                              prefixIcon: const Icon(Icons.search,
                                  color: PixelPoke.tinta),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: PixelPoke.tinta, width: 3),
                                borderRadius: BorderRadius.zero,
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: PixelPoke.tinta, width: 4),
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            onSubmitted: _buscar,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _botonPixel(
                              texto: 'BUSCAR',
                              icono: Icons.search,
                              fondo: PixelPoke.rojo,
                              textoColor: Colors.white,
                              semantics: 'Buscar el pokémon escrito',
                              onPressed: _cargando
                                  ? null
                                  : () => _buscar(_controlador.text),
                            ),
                            const SizedBox(width: 12),
                            _botonPixel(
                              texto: 'ALEATORIO',
                              icono: Icons.shuffle,
                              fondo: PixelPoke.amarillo,
                              textoColor: PixelPoke.tinta,
                              semantics:
                                  'Mostrar un pokémon aleatorio del 1 al 1025',
                              onPressed:
                                  _cargando ? null : _aleatorio,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('ATAJOS:',
                            style: PixelPoke.pixelSombra(11)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final ejemplo in kEjemplosDirectos)
                              _chipEjemplo(ejemplo),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_cargando && _pokemon == null)
                    Container(
                      decoration: PixelPoke.dialogoPoke(),
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            Text('¡UN POKéMON SALVAJE APARECE...!',
                                textAlign: TextAlign.center,
                                style: PixelPoke.pixel(13)),
                            const SizedBox(height: 16),
                            const CircularProgressIndicator(
                              color: PixelPoke.rojo,
                              semanticsLabel: 'Buscando pokémon',
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    if (_cargando)
                      Container(
                        decoration: BoxDecoration(
                          color: PixelPoke.dialogo,
                          border: Border.all(
                              color: PixelPoke.tinta, width: 3),
                        ),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: PixelPoke.rojo,
                                semanticsLabel: 'Actualizando ficha',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('ACTUALIZANDO FICHA...',
                                  style: PixelPoke.pixel(11)),
                            ),
                          ],
                        ),
                      ),
                    if (_pokemon != null)
                      FichaPokemon(pokemon: _pokemon!),
                  ],
                  const SizedBox(height: 12),
                  Center(
                    child: Text('© POKéDEX 8-BIT · DATOS: POKEAPI',
                        style: PixelPoke.pixel(10, Colors.grey.shade700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
