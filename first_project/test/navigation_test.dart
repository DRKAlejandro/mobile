// Test de navegación (constitución V, FR-002):
// cada tarjeta abre su pantalla, volver regresa al menú,
// y una ruta desconocida muestra el fallback informativo.
import 'package:first_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rutas = {
    '/modulo-2-3': '2.3 · Diálogos y notificaciones',
    '/modulo-2-4': '2.4 · Input, Label y Button',
    '/modulo-2-5': '2.5 · Radio, Check y Select',
    '/modulo-2-6': '2.6 · Gestos',
    '/modulo-2-7': '2.7 · Localización y mapas',
    '/modulo-2-8': '2.8 · Acelerómetro',
    '/modulo-2-9': '2.9 · Red, batería y vibración',
    '/modulo-2-10': '2.10 · Multimedia: cámara, audio y video',
    '/modulo-2-11': '2.11 · Almacenamiento',
    '/modulo-2-12': '2.12 · APIs y Servicios Web',
  };

  testWidgets('Cada tarjeta navega a su pantalla y vuelve al menú',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    for (final entry in rutas.entries) {
      // Ir a la pantalla por ruta nombrada.
      // Nota: pump() con duración fija en vez de pumpAndSettle(), porque
      // la demo 2.10 muestra un indicador de carga animado (video) y la
      // 2.12 deja una consulta HTTP en curso; en tests nunca terminan de
      // resolverse y bloquearían el settle.
      Navigator.of(tester.element(find.byType(Scaffold).first))
          .pushNamed(entry.key);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(entry.value), findsOneWidget);

      // Volver al menú.
      Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
      await tester.pumpAndSettle();
      expect(find.text('Módulos'), findsOneWidget);
    }
  });

  testWidgets('Tocar una tarjeta abre su pantalla', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Gestos').first);
    await tester.pumpAndSettle();
    expect(find.text('2.6 · Gestos'), findsOneWidget);
  });

  testWidgets('Ruta desconocida muestra fallback con vuelta al menú',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.byType(Scaffold).first))
        .pushNamed('/modulo-inexistente');
    await tester.pumpAndSettle();
    expect(find.text('Ruta no encontrada'), findsOneWidget);

    await tester.tap(find.text('Volver al menú'));
    await tester.pumpAndSettle();
    expect(find.text('Módulos'), findsOneWidget);
  });
}
