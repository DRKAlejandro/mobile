// Reproductor del video de ejemplo (módulo 2.10).
// Envuelve el VideoPlayer con su botón play/pausa.
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Video incluido en la app con controles mínimos propios.
class ReproductorVideo extends StatelessWidget {
  const ReproductorVideo({
    required this.controlador,
    required this.listo,
    required this.alternar,
    super.key,
  });

  /// Controlador del asset `assets/video_ejemplo.mp4`.
  final VideoPlayerController controlador;

  /// `true` cuando el video terminó de inicializarse.
  final bool listo;

  /// Callback play/pausa hacia la pantalla.
  final VoidCallback alternar;

  @override
  Widget build(BuildContext context) {
    if (!listo) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: controlador.value.aspectRatio,
            child: VideoPlayer(controlador),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: controlador.value.isPlaying
              ? 'Pausar el video de ejemplo'
              : 'Reproducir el video de ejemplo',
          child: ElevatedButton(
            onPressed: alternar,
            child: Text(
              controlador.value.isPlaying ? 'Pausar' : 'Reproducir',
            ),
          ),
        ),
      ],
    );
  }
}
