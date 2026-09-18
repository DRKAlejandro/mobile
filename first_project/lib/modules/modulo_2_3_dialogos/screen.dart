// Módulo 2.3 · Diálogos y notificaciones (FR-004).
// Qué muestra: AlertDialog en-app + notificaciones reales del sistema.
// Demo: diálogo confirmar/descartar + botón "Enviar notificación real"
// (permiso previo explicado; denegado → explicación + fallback en-app).
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../shared/services/permisos_service.dart';
import '../../shared/widgets/concepto_card.dart';
import '../../shared/widgets/error_contenido.dart';
import '../../shared/widgets/simulado_badge.dart';
import 'widgets/resultado_dialogo.dart';

/// Pantalla del módulo 2.3.
class Modulo23DialogosScreen extends StatefulWidget {
  const Modulo23DialogosScreen({super.key});

  @override
  State<Modulo23DialogosScreen> createState() => _Modulo23DialogosScreenState();
}

class _Modulo23DialogosScreenState extends State<Modulo23DialogosScreen> {
  /// Resultado del último diálogo: confirmado / descartado / aún sin probar.
  String? _dialogoResultado;

  /// `true` si ya se envió al menos una notificación real en esta sesión.
  bool _notificacionEnviada = false;

  /// Mensaje de error contenido en esta pantalla (FR-012).
  String? _error;

  /// Plugin de notificaciones locales (sin backend).
  final FlutterLocalNotificationsPlugin _notificaciones =
      FlutterLocalNotificationsPlugin();

  /// Canal de ejemplo de Android (ver research.md §2).
  bool _canalListo = false;

  Future<void> _asegurarCanal() async {
    if (_canalListo) return;
    const ajustesAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ajustes = InitializationSettings(android: ajustesAndroid);
    await _notificaciones.initialize(settings: ajustes);
    const canal = AndroidNotificationChannel(
      'demo_canal',
      'Demostración de ejemplo',
      description: 'Canal para la demo del módulo 2.3',
      importance: Importance.defaultImportance,
    );
    await _notificaciones
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(canal);
    _canalListo = true;
  }

  /// Muestra el diálogo de confirmación y registra el resultado visible.
  Future<void> _mostrarDialogo() async {
    setState(() => _error = null);
    try {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar acción'),
          content: const Text(
            'Esto es un AlertDialog: pregunta al usuario y espera '
            'una respuesta explícita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Descartar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      setState(() {
        _dialogoResultado =
            confirmado == null ? null : (confirmado ? 'confirmado' : 'descartado');
      });
      if (confirmado != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              confirmado ? 'Acción confirmada' : 'Acción descartada',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'No se pudo mostrar el diálogo: $e');
    }
  }

  /// Flujo de notificación real: explica → pide permiso → envía.
  Future<void> _enviarNotificacion() async {
    setState(() => _error = null);
    try {
      final permiso =
          await PermisosService().solicitarNotificaciones();
      if (!mounted) return;
      if (!permiso.concedido) {
        // Fallback en-app cuando el permiso se deniega (FR-004).
        setState(() => _error = permiso.mensaje);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permiso denegado: aviso mostrado solo en-app.'),
            ),
          );
        }
        return;
      }
      await _asegurarCanal();
      const detalleAndroid =
          AndroidNotificationDetails('demo_canal', 'Demostración de ejemplo');
      const detalles = NotificationDetails(android: detalleAndroid);
      await _notificaciones.show(
        id: 0,
        title: 'Demo 2.3 · Notificación real',
        body: 'Esta notificación la envió la app desde el módulo 2.3.',
        notificationDetails: detalles,
      );
      setState(() => _notificacionEnviada = true);
    } catch (e) {
      setState(() => _error = 'No se pudo enviar la notificación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2.3 · Diálogos y notificaciones')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConceptoCard(
                queEs:
                    'Los diálogos (AlertDialog, SnackBar) piden o confirman '
                    'información dentro de la app. Las notificaciones del '
                    'sistema avisan al usuario incluso fuera de la app.',
                paraQueSirve:
                    'En desarrollo móvil sirven para confirmar acciones '
                    'importantes (p. ej. borrar) y para avisar eventos '
                    '(p. ej. un recordatorio), con permiso del usuario.',
                ejemploUso:
                    'Pulsa "Mostrar diálogo" y elige Confirmar o Descartar; '
                    'luego pulsa "Enviar notificación real" para ver el '
                    'aviso del sistema.',
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                ErrorContenido(mensaje: _error!),
                const SizedBox(height: 12),
              ],
              ResultadoDialogo(resultado: _dialogoResultado),
              const SizedBox(height: 12),
              Row(
                children: [
                  SimuladoBadge(esReal: _notificacionEnviada),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _notificacionEnviada
                          ? 'Notificación real enviada en esta sesión.'
                          : 'Aún no se envía la notificación del sistema.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  Semantics(
                    button: true,
                    label: 'Mostrar diálogo de confirmación',
                    child: ElevatedButton(
                      onPressed: _mostrarDialogo,
                      child: const Text('Mostrar diálogo'),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Enviar notificación real del sistema',
                    child: OutlinedButton(
                      onPressed: _enviarNotificacion,
                      child: const Text('Enviar notificación real'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
