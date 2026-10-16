// Pruebas del módulo mapas2 (US1/US2/US3 + Haversine + fallback OSRM).
import 'package:first_project/main.dart';
import 'package:first_project/menu/menu_screen.dart';
import 'package:first_project/modules/modulo_mapas2_osm/models/punto_mapa.dart';
import 'package:first_project/modules/modulo_mapas2_osm/screen.dart';
import 'package:first_project/modules/modulo_mapas2_osm/services/ruta_osm_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Cliente falso que simula OSRM caído (500) para probar el fallback.
class _ClienteFallo extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(const Stream.empty(), 500);
  }
}

void main() {
  group('US1 - menú y navegación', () {
    testWidgets('el menú muestra la tarjeta Mapas2', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MenuScreen()),
      );
      expect(find.textContaining('Mapas2'), findsWidgets);
    });

    testWidgets('la ruta /mapas2-osm muestra el mapa y el concepto',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {'/mapas2-osm': (context) => const Mapas2OsmScreen()},
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/mapas2-osm'),
              child: const Text('ir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('ir'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('mapas2-mapa')), findsOneWidget);
      expect(find.byKey(const Key('mapas2-concepto')), findsOneWidget);
    });
  });

  group('US2 - puntos', () {
    testWidgets('agregar ejemplos crea 3 puntos y se pueden limpiar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Mapas2OsmScreen()),
      );
      expect(find.textContaining('Sin puntos'), findsOneWidget);
      await tester.ensureVisible(
          find.byKey(const Key('mapas2-agregar-ejemplos')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('mapas2-agregar-ejemplos')));
      await tester.pump();
      expect(find.text('Centro Histórico'), findsOneWidget);
      expect(find.text('Parque Tangamanga'), findsOneWidget);
      await tester.ensureVisible(
          find.byKey(const Key('mapas2-limpiar-todo')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('mapas2-limpiar-todo')));
      await tester.pump();
      expect(find.textContaining('Sin puntos'), findsOneWidget);
    });
  });

  group('US3 - rutas', () {
    testWidgets('trazar recta muestra info y limpiar conserva puntos',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Mapas2OsmScreen()),
      );
      await tester.ensureVisible(
          find.byKey(const Key('mapas2-agregar-ejemplos')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('mapas2-agregar-ejemplos')));
      await tester.pump();
      await tester.ensureVisible(
          find.byKey(const Key('mapas2-trazar-recta')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('mapas2-trazar-recta')));
      await tester.pump();
      expect(
          find.byKey(const Key('mapas2-info-recorrido')), findsOneWidget);
      expect(find.textContaining('Distancia:'), findsOneWidget);
      await tester.ensureVisible(
          find.byKey(const Key('mapas2-limpiar-ruta')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('mapas2-limpiar-ruta')));
      await tester.pump();
      expect(
          find.byKey(const Key('mapas2-info-recorrido')), findsNothing);
      // Los puntos se conservan.
      expect(find.text('Centro Histórico'), findsOneWidget);
    });

    testWidgets('con menos de 2 puntos se avisa en vez de trazar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Mapas2OsmScreen()),
      );
      await tester.ensureVisible(
          find.byKey(const Key('mapas2-trazar-recta')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('mapas2-trazar-recta')));
      await tester.pump();
      expect(find.byKey(const Key('mapas2-aviso')), findsOneWidget);
    });

    test('Haversine: SLP centro a Tangamanga ≈ 5 km', () {
      final d = RutaOsmService.haversineM(
        const LatLng(22.1565, -100.9855),
        const LatLng(22.1180, -101.0060),
      );
      expect(d, greaterThan(4000));
      expect(d, lessThan(7000));
    });

    test('OSRM caído devuelve error para el fallback a recta', () async {
      final servicio = RutaOsmService(cliente: _ClienteFallo());
      final resultado = await servicio.rutaVial(PuntosEjemploSlp.crear());
      expect(resultado.error, isNotNull);
      expect(resultado.trazado, isEmpty);
    });
  });

  group('Modelos', () {
    test('PuntoMapa rechaza coordenadas fuera de rango', () {
      expect(
        () => PuntoMapa(id: 'p1', latitud: 200, longitud: 0, titulo: 'X'),
        throwsArgumentError,
      );
    });

    test('rutaRecta exige al menos 2 puntos', () {
      expect(
        () => RutaOsmService.rutaRecta([]),
        throwsArgumentError,
      );
    });
  });

  // Puerta de regresión: la app completa sigue arrancando en el menú.
  group('App', () {
    testWidgets('MyApp arranca en el menú con Mapas2', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.textContaining('Mapas2'), findsOneWidget);
    });
  });
}
