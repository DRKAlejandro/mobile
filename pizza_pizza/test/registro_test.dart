// Tests de la historia US1: registro (T009).
// Se escribieron ANTES que la pantalla: deben FALLAR sin implementación.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_pizza/home/home_screen.dart';
import 'package:pizza_pizza/registro/registro_screen.dart';
import 'package:pizza_pizza/services/auth_service.dart';

import 'fake_auth.dart';

/// App de prueba con las rutas reales de la historia.
Widget appRegistro(FakeAuth auth) {
  return MaterialApp(
    initialRoute: '/registro',
    routes: {
      '/registro': (context) => RegistroScreen(auth: auth),
      '/home': (context) => HomeScreen(auth: auth),
      '/login': (context) => const Scaffold(body: Text('Pantalla login')),
    },
  );
}

Future<void> llenarFormularioValido(WidgetTester tester) async {
  await tester.enterText(
      find.byKey(const Key('campo-nombre')), 'Demo Pizza');
  await tester.enterText(
      find.byKey(const Key('campo-email')), 'demo@test.com');
  await tester.enterText(find.byKey(const Key('campo-password')), '123456');
  await tester.pump();
}

void main() {
  testWidgets('muestra errores de validación con campos vacíos',
      (tester) async {
    await tester.pumpWidget(appRegistro(FakeAuth()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
    await tester.pump();

    expect(find.text('Escribe tu nombre.'), findsOneWidget);
    expect(find.text('Escribe tu correo.'), findsOneWidget);
    expect(find.text('Escribe tu contraseña.'), findsOneWidget);
  });

  testWidgets('muestra aviso cuando el correo ya está registrado',
      (tester) async {
    final auth = FakeAuth()..fallaCon = const AuthError('email-ya-registrado');
    await tester.pumpWidget(appRegistro(auth));
    await llenarFormularioValido(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
    await tester.pumpAndSettle();

    expect(
      find.text('Este correo ya está registrado. Inicia sesión.'),
      findsOneWidget,
    );
    expect(auth.llamadasSignUp, 1);
  });

  testWidgets('navega a home tras un registro exitoso', (tester) async {
    await tester.pumpWidget(appRegistro(FakeAuth()));
    await llenarFormularioValido(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Bienvenido'), findsWidgets);
    expect(find.text('Demo Pizza'), findsOneWidget);
  });
}
