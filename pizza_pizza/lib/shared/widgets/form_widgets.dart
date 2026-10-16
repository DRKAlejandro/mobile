// Widgets compartidos de formularios (T008).
// Pequeños y comentados (constitución IV): los reutilizan
// login y registro para mantener la identidad anaranjada.
import 'package:flutter/material.dart';

/// Campo de nombre con validación externa.
class NombreField extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const NombreField({super.key, required this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('campo-nombre'),
      controller: controller,
      validator: validator,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Nombre',
        hintText: '¿Cómo te llamas?',
        prefixIcon: Icon(Icons.person_outline),
      ),
    );
  }
}

/// Campo de correo con teclado de email.
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const EmailField({super.key, required this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('campo-email'),
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'Correo',
        hintText: 'tucorreo@ejemplo.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
    );
  }
}

/// Campo de contraseña con mostrar/ocultar.
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;

  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Contraseña',
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('campo-password'),
      controller: widget.controller,
      obscureText: _oculta,
      validator: widget.validator,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_oculta ? Icons.visibility_outlined : Icons.visibility_off),
          onPressed: () => setState(() => _oculta = !_oculta),
        ),
      ),
    );
  }
}

/// Botón primario naranja de ancho completo con estado de carga.
class PrimaryButton extends StatelessWidget {
  final String texto;
  final bool cargando;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: cargando ? null : onPressed,
      child: cargando
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(texto),
    );
  }
}

/// Aviso de error o de conexión con icono.
class ErrorNotice extends StatelessWidget {
  final String mensaje;

  const ErrorNotice({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('aviso-error'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso de "Falta configurar" cuando no hay --dart-define (R-03).
class FaltaConfigurarNotice extends StatelessWidget {
  const FaltaConfigurarNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return const ErrorNotice(
      mensaje: 'Falta configurar Supabase. Ejecuta con '
          '--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
    );
  }
}
