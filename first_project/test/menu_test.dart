// Test del menú principal (constitución V, FR-001):
// verifica que las 11 tarjetas 2.3–2.13 son visibles con número/título.
import 'package:first_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Menú muestra las 11 tarjetas del menú', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Las 11 tarjetas usan ListTile dentro de Card.
    expect(find.byType(Card), findsNWidgets(11));

    // Cada módulo muestra su número y título.
    for (final numero in ['2.3', '2.4', '2.5', '2.6', '2.7', '2.8', '2.9', '2.10', '2.11', '2.12', '2.13']) {
      expect(find.textContaining(numero), findsWidgets);
    }
    expect(find.textContaining('Diálogos'), findsOneWidget);
    expect(find.textContaining('Acelerómetro'), findsOneWidget);
    expect(find.textContaining('Multimedia'), findsOneWidget);
    expect(find.textContaining('Almacenamiento'), findsOneWidget);
    expect(find.textContaining('APIs'), findsOneWidget);
    expect(find.textContaining('CRUD Canciones'), findsOneWidget);
  });
}
