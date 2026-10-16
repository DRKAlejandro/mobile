// Tests de la historia US2: login (T014).
// Se escribieron ANTES que la pantalla: deben FALLAR sin implementación.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_pizza/home/home_screen.dart';
import 'package:pizza_pizza/login/login_screen.dart';
import 'package:pizza_pizza/services/auth_service.dart';

import 'fake_auth.dart';

/// App de prueba con las rutas reales de la historia.
Widget appLogin(FakeAuth auth) {
  return MaterialApp(
    initialRoute: '/login',
    routes: {
      '/login': (context) => LoginScreen(auth: auth),
      '/registro': (context) => const Scaffold(body: Text('Crear cuenta')),
      '/home': (context) => HomeScreen(auth: auth),
    },
  );
}

Future<void> llenarLoginValido(WidgetTester tester) async {
  await tester.enterText(
      find.byKey(const Key('campo-email')), 'demo@test.com');
  await tester.enterText(find.byKey(const Key('campo-password')), '123456');
  await tester.pump();
}

void main() {
  testWidgets('muestra errores de validación con campos vacíos',
      (tester) async {
    await tester.pumpWidget(appLogin(FakeAuth()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pump();

    expect(find.text('Escribe tu correo.'), findsOneWidget);
    expect(find.text('Escribe tu contraseña.'), findsOneWidget);
  });

  testWidgets('credenciales incorrectas muestran aviso y no navegan',
      (tester) async {
    final auth = FakeAuth()
      ..fallaCon = const AuthError('credenciales-incorrectas');
    await tester.pumpWidget(appLogin(auth));
    await llenarLoginValido(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(auth.llamadasSignIn, 1);
  });

  testWidgets('login exitoso navega a home al primer intento',
      (tester) async {
    final auth = FakeAuth()..nombre = 'Demo Pizza';
    await tester.pumpWidget(appLogin(auth));
    await llenarLoginValido(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Bienvenido'), findsWidgets);
    expect(auth.llamadasSignIn, 1);
  });

  testWidgets('enlace a registro abre la pantalla de registro',
      (tester) async {
    await tester.pumpWidget(appLogin(FakeAuth()));

    await tester.tap(find.text('Crear una cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Crear cuenta'), findsWidgets);
  });
}
