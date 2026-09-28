// Tests del módulo 2.13 (FR-004–FR-008b):
// lista, búsqueda, estados, alta/edición validada, favorita y borrado,
// con MemoriaCancionService (sin red). Constitución V.
import 'package:first_project/modules/modulo_2_13_crud/models/cancion.dart';
import 'package:first_project/modules/modulo_2_13_crud/screen.dart';
import 'package:first_project/modules/modulo_2_13_crud/services/cancion_service.dart';
import 'package:first_project/modules/modulo_2_13_crud/services/memoria_cancion_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MemoriaCancionService servicioEjemplo() => MemoriaCancionService([
      const Cancion(id: 1, titulo: 'Imagine', artista: 'John Lennon'),
      const Cancion(
          id: 2,
          titulo: 'Bohemian Rhapsody',
          artista: 'Queen',
          favorita: true),
    ]);

Future<void> abrirPantalla(
    WidgetTester tester, CancionService servicio) async {
  await tester.pumpWidget(
    MaterialApp(home: Modulo213CrudScreen(servicio: servicio)),
  );
  await tester.pumpAndSettle();
}

/// Lleva el widget a la vista (scroll) y lo toca.
Future<void> tocarVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('US2 - lista y búsqueda', () {
    testWidgets('Muestra las canciones con título y artista',
        (tester) async {
      await abrirPantalla(tester, servicioEjemplo());
      expect(find.text('Imagine'), findsOneWidget);
      expect(find.text('Bohemian Rhapsody'), findsOneWidget);
      expect(find.text('John Lennon'), findsOneWidget);
    });

    testWidgets('La búsqueda filtra por título o artista', (tester) async {
      await abrirPantalla(tester, servicioEjemplo());
      await tester.enterText(
          find.byType(TextField), 'queen');
      await tester.pumpAndSettle();
      expect(find.text('Bohemian Rhapsody'), findsOneWidget);
      expect(find.text('Imagine'), findsNothing);
    });

    testWidgets('Sin coincidencias muestra mensaje de sin resultados',
        (tester) async {
      await abrirPantalla(tester, servicioEjemplo());
      await tester.enterText(find.byType(TextField), 'zzz-sin-coincidencia');
      await tester.pumpAndSettle();
      expect(find.text('Sin resultados para esa búsqueda.'),
          findsOneWidget);
    });

    testWidgets('Tabla vacía invita a agregar la primera', (tester) async {
      await abrirPantalla(tester, MemoriaCancionService());
      expect(find.textContaining('Agrega la primera'), findsOneWidget);
    });

    testWidgets('Error de conexión muestra aviso y reintenta',
        (tester) async {
      final servicio = servicioEjemplo()
        ..fallarSiguienteCon = const ErrorConexion('corte simulado');
      await abrirPantalla(tester, servicio);
      expect(find.textContaining('corte simulado'), findsOneWidget);
      await tocarVisible(tester, find.text('Reintentar'));

      expect(find.text('Imagine'), findsOneWidget);
    });
  });

  group('US3 - alta, edición, favorita y borrado', () {
    testWidgets('Guardar sin título avisa y no guarda', (tester) async {
      final servicio = servicioEjemplo();
      await abrirPantalla(tester, servicio);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(TextFormField).at(1), 'Artista X');
      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();
      expect(find.text('El título es obligatorio.'), findsOneWidget);
      expect(servicio.canciones.length, 2);
    });

    testWidgets('Alta válida aparece en la lista con confirmación',
        (tester) async {
      final servicio = servicioEjemplo();
      await abrirPantalla(tester, servicio);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(TextFormField).at(0), 'La Bamba');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'Ritchie Valens');
      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();
      expect(find.text('La Bamba'), findsOneWidget);
      expect(find.text('Canción agregada.'), findsOneWidget);
    });

    testWidgets('Toggle de favorita persiste al instante', (tester) async {
      final servicio = servicioEjemplo();
      await abrirPantalla(tester, servicio);
      // Imagine (id 1) no es favorita: su estrella está vacía.
      await tocarVisible(tester, find.byIcon(Icons.star_border).first);
      expect(
          servicio.canciones
              .firstWhere((c) => c.id == 1)
              .favorita,
          isTrue);
      expect(find.text('Marcada como favorita.'), findsOneWidget);
    });

    testWidgets('Editar refleja los cambios', (tester) async {
      final servicio = servicioEjemplo();
      await abrirPantalla(tester, servicio);
      // La lista ordena recientes primero: ubicar la fila de Imagine.
      final filaImagine = find.ancestor(
        of: find.text('Imagine'),
        matching: find.byType(ListTile),
      );
      await tocarVisible(
          tester,
          find.descendant(
              of: filaImagine, matching: find.byIcon(Icons.edit_outlined)));
      await tester.enterText(
          find.byType(TextFormField).at(0), 'Imagine (remaster)');
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();
      expect(find.text('Imagine'), findsNothing);
      expect(find.text('Imagine (remaster)'), findsOneWidget);
      expect(find.text('Cambios guardados.'), findsOneWidget);
    });

    testWidgets('Borrar pide confirmación: cancelar conserva',
        (tester) async {
      final servicio = servicioEjemplo();
      await abrirPantalla(tester, servicio);
      await tocarVisible(tester, find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      expect(find.text('Eliminar canción'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(servicio.canciones.length, 2);
      expect(find.text('Imagine'), findsOneWidget);
    });

    testWidgets('Borrar confirmando elimina con aviso', (tester) async {
      final servicio = servicioEjemplo();
      await abrirPantalla(tester, servicio);
      await tocarVisible(tester, find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();
      expect(servicio.canciones.length, 1);
      expect(find.text('Canción eliminada.'), findsOneWidget);
    });
  });

  group('Configuración', () {
    testWidgets('Sin inicializar Supabase avisa falta de configuración',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Modulo213CrudScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Falta configurar Supabase'),
          findsOneWidget);
    });
  });
}
