// Tests de persistencia de sesión US2 (T015).
// Cubren la decisión de ruta inicial sin necesidad de Supabase real.
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_pizza/main.dart';

void main() {
  test('sin configuración va al login aunque haya sesión', () {
    expect(
      rutaInicial(configurado: false, haySesion: true),
      '/login',
    );
  });

  test('configurado sin sesión va al login', () {
    expect(
      rutaInicial(configurado: true, haySesion: false),
      '/login',
    );
  });

  test('configurado con sesión va al home (SC-005)', () {
    expect(
      rutaInicial(configurado: true, haySesion: true),
      '/home',
    );
  });
}
