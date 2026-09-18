// Estado visible de la demo de audio (módulo 2.10).
// Refleja si se está grabando, si hay audio listo o si falta permiso.
import 'package:flutter/material.dart';

/// Texto de estado de la grabación/reproducción de audio.
class EstadoAudio extends StatelessWidget {
  const EstadoAudio({
    required this.grabando,
    required this.tieneAudio,
    super.key,
  });

  /// `true` mientras el micrófono graba.
  final bool grabando;

  /// `true` si ya hay un audio grabado listo para reproducir.
  final bool tieneAudio;

  @override
  Widget build(BuildContext context) {
    final texto = grabando
        ? 'Grabando… pulsa "Detener".'
        : tieneAudio
            ? 'Audio listo: pulsa "Reproducir".'
            : 'Sin audio: pulsa "Grabar".';
    return Text(texto, style: Theme.of(context).textTheme.titleSmall);
  }
}
