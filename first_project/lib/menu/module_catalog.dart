// Catálogo estático de módulos (2.3–2.12).
// Fuente única de módulos: número, título, descripción, icono y ruta.
// Para agregar un módulo: añadir una entrada aquí + registrar su ruta en main.dart.
import 'package:flutter/material.dart';

/// Representa un módulo del menú.
class ModuloMenu {
  const ModuloMenu({
    required this.numero,
    required this.titulo,
    required this.descripcionCorta,
    required this.icono,
    required this.ruta,
  });

  /// Número de módulo, p. ej. '2.3'. Único y ordenado.
  final String numero;

  /// Título descriptivo del concepto.
  final String titulo;

  /// Descripción de una línea visible en la tarjeta del menú (máx. 120 caracteres).
  final String descripcionCorta;

  /// Icono Material distintivo del módulo.
  final IconData icono;

  /// Ruta nombrada registrada en MaterialApp.routes.
  final String ruta;
}

/// Los 10 módulos del alcance, en orden pedagógico.
const List<ModuloMenu> kModulos = [
  ModuloMenu(
    numero: '2.3',
    titulo: 'Diálogos y notificaciones',
    descripcionCorta: 'AlertDialog, SnackBar y notificaciones reales del sistema.',
    icono: Icons.notifications_outlined,
    ruta: '/modulo-2-3',
  ),
  ModuloMenu(
    numero: '2.4',
    titulo: 'Input, Label y Button',
    descripcionCorta: 'Campo de texto, etiqueta y botón con resultado visible.',
    icono: Icons.text_fields_outlined,
    ruta: '/modulo-2-4',
  ),
  ModuloMenu(
    numero: '2.5',
    titulo: 'RadioButton, CheckBox y Select',
    descripcionCorta: 'Opciones de selección con reflejo del estado elegido.',
    icono: Icons.check_box_outlined,
    ruta: '/modulo-2-5',
  ),
  ModuloMenu(
    numero: '2.6',
    titulo: 'Gestos',
    descripcionCorta: 'Toque, doble toque, pulsación larga y deslizamiento.',
    icono: Icons.touch_app_outlined,
    ruta: '/modulo-2-6',
  ),
  ModuloMenu(
    numero: '2.7',
    titulo: 'Localización y mapas',
    descripcionCorta: 'GPS real y mapa interactivo, con nota sobre permisos.',
    icono: Icons.map_outlined,
    ruta: '/modulo-2-7',
  ),
  ModuloMenu(
    numero: '2.8',
    titulo: 'Acelerómetro',
    descripcionCorta: 'Lecturas reales en los tres ejes X, Y y Z.',
    icono: Icons.sensors_outlined,
    ruta: '/modulo-2-8',
  ),
  ModuloMenu(
    numero: '2.9',
    titulo: 'Red, batería y vibración',
    descripcionCorta: 'Estado de conexión, nivel de batería y vibración real.',
    icono: Icons.battery_std_outlined,
    ruta: '/modulo-2-9',
  ),
  ModuloMenu(
    numero: '2.10',
    titulo: 'Multimedia: cámara, audio y video',
    descripcionCorta: 'Foto real, audio grabado y video de ejemplo offline.',
    icono: Icons.camera_alt_outlined,
    ruta: '/modulo-2-10',
  ),
  ModuloMenu(
    numero: '2.11',
    titulo: 'Almacenamiento',
    descripcionCorta: 'Guardar y recuperar un texto que persiste.',
    icono: Icons.save_outlined,
    ruta: '/modulo-2-11',
  ),
  ModuloMenu(
    numero: '2.12',
    titulo: 'APIs y Servicios Web',
    descripcionCorta: 'Consulta datos reales de PokeAPI con ficha visual.',
    icono: Icons.cloud_outlined,
    ruta: '/modulo-2-12',
  ),
  ModuloMenu(
    numero: '2.13',
    titulo: 'CRUD Canciones',
    descripcionCorta: 'Crear, leer, editar y borrar canciones en Supabase.',
    icono: Icons.library_music_outlined,
    ruta: '/modulo-2-13',
  ),
];
