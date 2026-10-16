// Tests de home + navegación común US1/US2 (T010).
// Se escribieron ANTES que las pantallas: deben FALLAR sin implementación.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_pizza/home/home_screen.dart';
import 'package:pizza_pizza/login/login_screen.dart';

import 'fake_auth.dart';

/// App de prueba con sesión simulada.
Widget appHome(FakeAuth auth) {
  return MaterialApp(
    initialRoute: '/home',
    routes: {
      '/home': (context) => HomeScreen(auth: auth),
      '/login': (context) => LoginScreen(auth: auth),
    },
  );
}

void main() {
  testWidgets('muestra el nombre del usuario en la bienvenida',
      (tester) async {
    final auth = FakeAuth()
      ..sesion = true
      ..nombre = 'Demo Pizza'
      ..correo = 'demo@test.com';
    await tester.pumpWidget(appHome(auth));
    await tester.pumpAndSettle();

    expect(find.text('Demo Pizza'), findsOneWidget);
    expect(find.text('demo@test.com'), findsOneWidget);
  });

  testWidgets('cerrar sesión vuelve al login', (tester) async {
    final auth = FakeAuth()
      ..sesion = true
      ..nombre = 'Demo Pizza';
    await tester.pumpWidget(appHome(auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Cerrar sesión'), findsNothing);
    expect(auth.llamadasSignOut, 1);
  });
}
