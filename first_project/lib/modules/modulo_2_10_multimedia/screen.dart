// Módulo 2.10 · Multimedia: cámara, audio y video (FR-005).
// Qué muestra: captura de foto real, grabación/reproducción de audio real
// y reproducción de un video de ejemplo incluido (offline).
// Foto y audio viven solo en sesión; sin permiso/hardware → SIMULADO.
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

import '../../shared/services/permisos_service.dart';
import '../../shared/widgets/concepto_card.dart';
import '../../shared/widgets/error_contenido.dart';
import '../../shared/widgets/simulado_badge.dart';
import 'widgets/estado_audio.dart';
import 'widgets/foto_muestra.dart';
import 'widgets/reproductor_video.dart';

/// Pantalla del módulo 2.10.
class Modulo210MultimediaScreen extends StatefulWidget {
  const Modulo210MultimediaScreen({super.key});

  @override
  State<Modulo210MultimediaScreen> createState() =>
      _Modulo210MultimediaScreenState();
}

class _Modulo210MultimediaScreenState extends State<Modulo210MultimediaScreen> {
  /// Foto capturada (null = aún sin capturar; se descarta al salir).
  XFile? _foto;

  /// `true` si la foto es real (vs. marcador ilustrativo).
  bool _fotoReal = false;

  /// Grabador de audio (se libera en dispose).
  final AudioRecorder _grabador = AudioRecorder();

  /// Reproductor de audio (se libera en dispose).
  final AudioPlayer _reproductorAudio = AudioPlayer();

  /// Ruta del audio grabado en el temporal (null = aún sin grabar).
  String? _audioPath;

  /// `true` mientras el micrófono graba.
  bool _grabando = false;

  /// Controlador del video de ejemplo incluido (se libera en dispose).
  late final VideoPlayerController _video;

  /// `true` cuando el video terminó de inicializarse.
  bool _videoListo = false;

  /// Error contenido en esta pantalla (FR-008).
  String? _error;

  @override
  void initState() {
    super.initState();
    // Video offline incluido: determinista, sin red ni permisos.
    _video = VideoPlayerController.asset('assets/video_ejemplo.mp4');
    _video.initialize().then((_) {
      if (!mounted) return;
      setState(() => _videoListo = true);
    }).catchError((Object e) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo cargar el video: $e');
    });
  }

  @override
  void dispose() {
    // Liberar los tres recursos multimedia (patrón de ciclo de vida).
    _grabador.dispose();
    _reproductorAudio.dispose();
    _video.dispose();
    super.dispose();
  }

  /// Captura una foto real con permiso previo explicado (demo cámara).
  Future<void> _tomarFoto() async {
    setState(() => _error = null);
    try {
      final permiso = await PermisosService().solicitarCamara();
      if (!mounted) return;
      if (!permiso.concedido) {
        // Fallback etiquetado cuando se deniega el permiso.
        setState(() {
          _foto = null;
          _fotoReal = false;
          _error = permiso.mensaje;
        });
        return;
      }
      final foto = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (!mounted) return;
      // Cancelar la cámara (null) no es error: se queda el marcador.
      if (foto == null) return;
      setState(() {
        _foto = foto;
        _fotoReal = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _foto = null;
          _fotoReal = false;
          _error = 'No se pudo tomar la foto: $e';
        });
      }
    }
  }

  /// Inicia la grabación de audio en un archivo temporal (demo audio).
  Future<void> _grabar() async {
    setState(() => _error = null);
    try {
      final permiso = await PermisosService().solicitarMicrofono();
      if (!mounted) return;
      if (!permiso.concedido) {
        setState(() => _error = permiso.mensaje);
        return;
      }
      final ruta = '${Directory.systemTemp.path}/demo_audio_2_10.m4a';
      await _grabador.start(const RecordConfig(), path: ruta);
      if (!mounted) return;
      setState(() {
        _grabando = true;
        _audioPath = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'No se pudo grabar: $e');
      }
    }
  }

  /// Detiene la grabación y guarda la ruta del audio de la sesión.
  Future<void> _detener() async {
    try {
      final ruta = await _grabador.stop();
      if (!mounted) return;
      setState(() {
        _grabando = false;
        _audioPath = ruta;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _grabando = false;
          _error = 'No se pudo detener la grabación: $e';
        });
      }
    }
  }

  /// Reproduce el audio grabado en esta sesión.
  Future<void> _reproducirAudio() async {
    setState(() => _error = null);
    try {
      if (_audioPath == null) return;
      await _reproductorAudio.play(DeviceFileSource(_audioPath!));
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'No se pudo reproducir el audio: $e');
      }
    }
  }

  /// Alterna play/pausa del video de ejemplo.
  void _alternarVideo() {
    setState(() {
      if (_video.value.isPlaying) {
        _video.pause();
      } else {
        _video.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('2.10 · Multimedia: cámara, audio y video')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConceptoCard(
                queEs:
                    'La cámara captura fotos, el micrófono graba audio y el '
                    'reproductor muestra video. Son los tres pilares '
                    'multimedia del móvil.',
                paraQueSirve:
                    'En desarrollo móvil sirven para redes sociales, '
                    'mensajes de voz o tutoriales (p. ej. foto de perfil, '
                    'nota de voz, video de ayuda). Requieren permiso.',
                ejemploUso:
                    'Toma una foto, graba y reproduce un audio, y reproduce '
                    'el video de ejemplo incluido sin conexión.',
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                ErrorContenido(mensaje: _error!),
                const SizedBox(height: 12),
              ],
              Text('Cámara',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  SimuladoBadge(esReal: _fotoReal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _fotoReal
                          ? 'Foto real capturada en esta sesión.'
                          : 'Sin foto real: marcador ilustrativo.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FotoMuestra(foto: _foto),
              const SizedBox(height: 8),
              Semantics(
                button: true,
                label: 'Tomar una foto con la cámara',
                child: ElevatedButton(
                  onPressed: _tomarFoto,
                  child: const Text('Tomar foto'),
                ),
              ),
              const SizedBox(height: 16),
              Text('Audio',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  SimuladoBadge(esReal: _audioPath != null),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('El audio vive solo en esta sesión.'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              EstadoAudio(
                grabando: _grabando,
                tieneAudio: _audioPath != null,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  Semantics(
                    button: true,
                    label: 'Grabar audio con el micrófono',
                    child: ElevatedButton(
                      onPressed: _grabando ? null : _grabar,
                      child: const Text('Grabar'),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Detener la grabación de audio',
                    child: OutlinedButton(
                      onPressed: _grabando ? _detener : null,
                      child: const Text('Detener'),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Reproducir el audio grabado',
                    child: OutlinedButton(
                      onPressed:
                          (_audioPath != null && !_grabando) ? _reproducirAudio : null,
                      child: const Text('Reproducir'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Video (ejemplo incluido, sin conexión)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ReproductorVideo(
                controlador: _video,
                listo: _videoListo,
                alternar: _alternarVideo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
