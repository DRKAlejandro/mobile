// Servicio del módulo 2.12 · Consultas a la PokeAPI (contracts/pokemon-service.md).
// Qué muestra: GET sin clave a `https://pokeapi.co/api/v2/pokemon/{nombre-o-id}`
// con timeout de 10 s. Sin red/servicio → la pantalla muestra
// [kPikachuSimulado] etiquetado como simulado (FR-010).
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

/// Entrada vacía: validación local, sin llamada HTTP.
class EntradaVacia implements Exception {
  const EntradaVacia();
}

/// La API respondió 404: ese nombre/número no existe.
class PokemonNoEncontrado implements Exception {
  const PokemonNoEncontrado(this.entrada);

  /// Entrada normalizada que no existe.
  final String entrada;
}

/// Sin conexión, timeout u otro fallo: usar [kPikachuSimulado].
class ErrorConexion implements Exception {
  const ErrorConexion([this.detalle = '']);

  /// Detalle técnico para el mensaje visible.
  final String detalle;
}

/// Accesos directos de ejemplo (contrato: pikachu, charizard, mewtwo).
const List<String> kEjemplosDirectos = ['pikachu', 'charizard', 'mewtwo'];

/// Límite del aleatorio: catálogo completo 1–1025.
const int kMaxAleatorio = 1025;

/// Ejemplo inicial y respaldo sin conexión (aclaración 1 y 3).
/// Valores ilustrativos de pikachu; siempre con badge SIMULADO.
const Pokemon kPikachuSimulado = Pokemon(
  id: 25,
  nombre: 'pikachu',
  imagenUrl:
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
  tipos: ['electric'],
  alturaM: 0.4,
  pesoKg: 6.0,
  habilidades: [
    Habilidad(nombre: 'static', oculta: false),
    Habilidad(nombre: 'lightning-rod', oculta: true),
  ],
  stats: [
    Stat(nombre: 'hp', valor: 35),
    Stat(nombre: 'attack', valor: 55),
    Stat(nombre: 'defense', valor: 40),
    Stat(nombre: 'special-attack', valor: 50),
    Stat(nombre: 'special-defense', valor: 50),
    Stat(nombre: 'speed', valor: 90),
  ],
  esReal: false,
);

/// Número aleatorio de pokémon entre 1 y [kMaxAleatorio].
int numeroAleatorio() => Random().nextInt(kMaxAleatorio) + 1;

/// Consulta un pokémon por nombre o número.
/// Normaliza (`trim().toLowerCase()`); lanza [EntradaVacia] sin llamar,
/// [PokemonNoEncontrado] ante 404 y [ErrorConexion] sin red/timeout/fallo.
Future<Pokemon> obtenerPokemon(String entrada) async {
  // Normalizar: "  Pikachu " → "pikachu" (FR-011).
  final normalizada = entrada.trim().toLowerCase();
  if (normalizada.isEmpty) {
    throw const EntradaVacia();
  }
  try {
    final respuesta = await http
        .get(Uri.https('pokeapi.co', '/api/v2/pokemon/$normalizada'))
        .timeout(const Duration(seconds: 10));
    if (respuesta.statusCode == 200) {
      return Pokemon.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    if (respuesta.statusCode == 404) {
      throw PokemonNoEncontrado(normalizada);
    }
    throw ErrorConexion('HTTP ${respuesta.statusCode}');
  } on PokemonNoEncontrado {
    // El 404 es respuesta válida ("no existe"), no fallo de red.
    rethrow;
  } on TimeoutException catch (e) {
    throw ErrorConexion('timeout: $e');
  } on SocketException catch (e) {
    throw ErrorConexion('sin red: $e');
  } catch (e) {
    throw ErrorConexion('$e');
  }
}
