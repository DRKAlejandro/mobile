// Doble de prueba de AuthRepository sin red (tests US1/US2).
// Permite simular éxito, errores y sesión persistida.
import 'package:pizza_pizza/services/auth_service.dart';

/// AuthRepository falso con comportamiento programable.
class FakeAuth implements AuthRepository {
  /// Excepción a lanzar en signUp/signIn, o null para éxito.
  AuthError? fallaCon;

  /// Estado de sesión simulado.
  bool sesion = false;

  /// Datos de la sesión simulada.
  String? nombre;
  String? correo;

  /// Veces que se llamó a cada método.
  int llamadasSignUp = 0;
  int llamadasSignIn = 0;
  int llamadasSignOut = 0;

  @override
  Future<void> signUp({
    required String nombre,
    required String email,
    required String password,
  }) async {
    llamadasSignUp++;
    if (fallaCon != null) throw fallaCon!;
    sesion = true;
    this.nombre = nombre;
    correo = email;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    llamadasSignIn++;
    if (fallaCon != null) throw fallaCon!;
    sesion = true;
    correo = email;
  }

  @override
  Future<void> signOut() async {
    llamadasSignOut++;
    if (fallaCon != null) throw fallaCon!;
    sesion = false;
  }

  @override
  bool get sesionActiva => sesion;

  @override
  String? get nombreActual => nombre;

  @override
  String? get emailActual => correo;
}
