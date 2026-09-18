// Fachada de permisos con mensajes claros en español.
// Cada pantalla explica QUÉ permiso pide y POR QUÉ antes de solicitarlo;
// el estado resultante (concedido/denegado/permanente) forma parte de la demo.
import 'package:permission_handler/permission_handler.dart';

/// Resultado de una solicitud, listo para mostrar en la UI de demostración.
class ResultadoPermiso {
  const ResultadoPermiso({required this.concedido, required this.mensaje});

  /// `true` si el permiso quedó concedido (total o limitado en iOS).
  final bool concedido;

  /// Explicación en español del estado, en lenguaje claro.
  final String mensaje;
}

/// Servicio único de permisos para los módulos 2.3, 2.7, 2.9 y 2.10.
class PermisosService {
  /// Solicita permiso de ubicación (módulo 2.7, mapa + GPS).
  Future<ResultadoPermiso> solicitarUbicacion() async {
    final estado = await Permission.location.request();
    return _interpretar(estado, 'ubicación');
  }

  /// Solicita permiso de notificaciones (módulo 2.3, Android 13+).
  Future<ResultadoPermiso> solicitarNotificaciones() async {
    final estado = await Permission.notification.request();
    return _interpretar(estado, 'notificaciones');
  }

  /// Solicita permiso de cámara (módulo 2.10, foto).
  Future<ResultadoPermiso> solicitarCamara() async {
    final estado = await Permission.camera.request();
    return _interpretar(estado, 'cámara');
  }

  /// Solicita permiso de micrófono (módulo 2.10, audio).
  Future<ResultadoPermiso> solicitarMicrofono() async {
    final estado = await Permission.microphone.request();
    return _interpretar(estado, 'micrófono');
  }

  /// Interpreta el estado del sistema en lenguaje claro.
  ResultadoPermiso _interpretar(PermissionStatus estado, String nombre) {
    if (estado.isGranted || estado.isLimited) {
      return ResultadoPermiso(
        concedido: true,
        mensaje: 'Permiso de $nombre concedido: la demo usa datos reales.',
      );
    }
    if (estado.isPermanentlyDenied) {
      return const ResultadoPermiso(
        concedido: false,
        mensaje:
            'Permiso denegado permanentemente: actívalo en Ajustes o usa el modo simulado.',
      );
    }
    return ResultadoPermiso(
      concedido: false,
      mensaje:
          'Permiso de $nombre denegado: la demo muestra valores simulados etiquetados.',
    );
  }
}
