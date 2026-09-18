// Suite principal de la app (T037):
// el antiguo smoke test del contador quedó obsoleto al reemplazar el
// HomeScreen monolítico por el menú principal. Esta suite verifica el
// arranque en el menú con las 10 tarjetas.
import 'package:first_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('La app arranca en el menú principal', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Desarrollo móvil'), findsOneWidget);
    expect(find.text('Módulos'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(10));
  });
}
