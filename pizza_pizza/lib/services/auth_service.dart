// Servicio de autenticación con Supabase Auth (T006).
// La tabla `usuarios` actúa solo como PERFIL vinculado por `auth_id`;
// NUNCA guarda contraseñas (FR-012, clarify Q1-A).
//
// Diseño testeable: las pantallas dependen de la abstracción
// `AuthRepository`, y los tests inyectan un doble falso sin red.
import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Error de autenticación con código estable para mapear a mensajes.
class AuthError implements Exception {
  /// Código: email-ya-registrado, credenciales-incorrectas,
  /// cuenta-inexistente, email-invalido, password-corta,
  /// sin-conexion, falta-configurar, error-inesperado.
  final String codigo;

  const AuthError(this.codigo);

  /// Mensaje visible en español (contrato auth-navigation.md).
  String get mensaje => switch (codigo) {
        'email-ya-registrado' =>
          'Este correo ya está registrado. Inicia sesión.',
        'credenciales-incorrectas' => 'Correo o contraseña incorrectos.',
        'cuenta-inexistente' => 'No existe una cuenta con ese correo.',
        'email-invalido' => 'Escribe un correo válido.',
        'password-corta' =>
          'La contraseña debe tener al menos 6 caracteres.',
        'sin-conexion' =>
          'Sin conexión. Revisa tu internet e inténtalo de nuevo.',
        'falta-configurar' =>
          'Falta configurar Supabase (SUPABASE_URL / SUPABASE_ANON_KEY).',
        _ => 'Ocurrió un error inesperado. Inténtalo de nuevo.',
      };

  @override
  String toString() => 'AuthError($codigo)';
}

/// Contrato de autenticación que usan las pantallas.
abstract class AuthRepository {
  /// Crea la cuenta y deja la sesión iniciada.
  Future<void> signUp({
    required String nombre,
    required String email,
    required String password,
  });

  /// Inicia sesión con una cuenta existente.
  Future<void> signIn({required String email, required String password});

  /// Cierra la sesión actual.
  Future<void> signOut();

  /// `true` si hay sesión persistida (SC-005).
  bool get sesionActiva;

  /// Nombre a mostrar en la bienvenida.
  String? get nombreActual;

  /// Correo de la sesión actual.
  String? get emailActual;
}

/// Validadores de formularios (lógica pura, testeable sin red).
class Validadores {
  const Validadores._();

  /// Longitud mínima de contraseña (spec: 6).
  static const int minPassword = 6;

  /// Nombre no vacío (los espacios solos cuentan como vacío).
  static String? nombre(String value) {
    if (value.trim().isEmpty) return 'Escribe tu nombre.';
    if (value.trim().length > 80) return 'Máximo 80 caracteres.';
    return null;
  }

  /// Formato básico de correo.
  static String? email(String value) {
    final limpio = value.trim();
    if (limpio.isEmpty) return 'Escribe tu correo.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(limpio)) {
      return 'Escribe un correo válido.';
    }
    return null;
  }

  /// Contraseña con longitud mínima.
  static String? password(String value) {
    if (value.isEmpty) return 'Escribe tu contraseña.';
    if (value.length < minPassword) {
      return 'La contraseña debe tener al menos $minPassword caracteres.';
    }
    return null;
  }
}

/// Implementación real con Supabase (email/password + perfil).
class SupabaseAuthService implements AuthRepository {
  /// Cliente inyectable para pruebas (por defecto el singleton).
  final SupabaseClient Function() _cliente;

  SupabaseAuthService({SupabaseClient Function()? cliente})
      : _cliente = cliente ?? (() => Supabase.instance.client);

  SupabaseClient get _db => _cliente();

  void _exigirConfiguracion() {
    if (SupabaseConfig.faltaConfiguracion) {
      throw const AuthError('falta-configurar');
    }
  }

  @override
  Future<void> signUp({
    required String nombre,
    required String email,
    required String password,
  }) async {
    _exigirConfiguracion();
    final correo = email.trim().toLowerCase();
    try {
      final res = await _db.auth.signUp(
        email: correo,
        password: password,
        data: {'nombre': nombre.trim()},
      );
      final user = res.user;
      if (user == null) throw const AuthError('error-inesperado');
      await _asegurarPerfil(
        authId: user.id,
        nombre: nombre.trim(),
        email: correo,
      );
    } on AuthError {
      rethrow;
    } on AuthException catch (e) {
      throw AuthError(_codigoSupabase(e.message));
    } on SocketException {
      throw const AuthError('sin-conexion');
    } on TimeoutException {
      throw const AuthError('sin-conexion');
    } catch (_) {
      throw const AuthError('error-inesperado');
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    _exigirConfiguracion();
    final correo = email.trim().toLowerCase();
    try {
      final res = await _db.auth.signInWithPassword(
        email: correo,
        password: password,
      );
      final user = res.user;
      if (user == null) throw const AuthError('error-inesperado');
      final meta = user.userMetadata;
      final nombre = (meta?['nombre'] as String?)?.trim();
      await _asegurarPerfil(
        authId: user.id,
        nombre: (nombre == null || nombre.isEmpty)
            ? correo.split('@').first
            : nombre,
        email: correo,
      );
    } on AuthError {
      rethrow;
    } on AuthException catch (e) {
      throw AuthError(_codigoSupabase(e.message));
    } on SocketException {
      throw const AuthError('sin-conexion');
    } on TimeoutException {
      throw const AuthError('sin-conexion');
    } catch (_) {
      throw const AuthError('error-inesperado');
    }
  }

  @override
  Future<void> signOut() async {
    _exigirConfiguracion();
    try {
      await _db.auth.signOut();
    } on SocketException {
      throw const AuthError('sin-conexion');
    } on TimeoutException {
      throw const AuthError('sin-conexion');
    } catch (_) {
      throw const AuthError('error-inesperado');
    }
  }

  @override
  bool get sesionActiva =>
      !SupabaseConfig.faltaConfiguracion &&
      _db.auth.currentSession != null;

  @override
  String? get nombreActual {
    if (SupabaseConfig.faltaConfiguracion) return null;
    final user = _db.auth.currentUser;
    final nombre = user?.userMetadata?['nombre'] as String?;
    if (nombre != null && nombre.trim().isNotEmpty) return nombre.trim();
    final email = user?.email;
    return email?.split('@').first;
  }

  @override
  String? get emailActual {
    if (SupabaseConfig.faltaConfiguracion) return null;
    return _db.auth.currentUser?.email;
  }

  /// Crea o actualiza la fila de perfil en `usuarios` (upsert por auth_id).
  Future<void> _asegurarPerfil({
    required String authId,
    required String nombre,
    required String email,
  }) async {
    try {
      await _db.from('usuarios').upsert({
        'auth_id': authId,
        'nombre': nombre,
        'email': email,
      }, onConflict: 'auth_id');
    } on SocketException {
      throw const AuthError('sin-conexion');
    } on TimeoutException {
      throw const AuthError('sin-conexion');
    } on PostgrestException {
      // La cuenta ya quedó creada en Auth; el perfil se reintentará
      // en el próximo inicio de sesión. No se bloquea la entrada.
    }
  }

  /// Traduce mensajes de Supabase a códigos estables del contrato.
  static String _codigoSupabase(String message) {
    final m = message.toLowerCase();
    if (m.contains('already registered') ||
        m.contains('already exists') ||
        m.contains('user already')) {
      return 'email-ya-registrado';
    }
    if (m.contains('invalid login credentials') ||
        m.contains('invalid_credentials') ||
        m.contains('email not confirmed')) {
      return 'credenciales-incorrectas';
    }
    if (m.contains('user not found')) return 'cuenta-inexistente';
    if (m.contains('password should be at least') ||
        m.contains('weak password')) {
      return 'password-corta';
    }
    if (m.contains('invalid email') || m.contains('invalid-email')) {
      return 'email-invalido';
    }
    if (m.contains('network') ||
        m.contains('failed host') ||
        m.contains('connection')) {
      return 'sin-conexion';
    }
    return 'error-inesperado';
  }
}
