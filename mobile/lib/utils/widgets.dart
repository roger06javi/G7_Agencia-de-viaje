import 'package:flutter/material.dart';
import 'theme.dart';

// ── Snackbar helpers ──────────────────────────────────────
void showSuccess(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.check_circle, color: Colors.white, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
    ]),
    backgroundColor: AppTheme.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  ));
}

void showError(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.error_outline, color: Colors.white, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
    ]),
    backgroundColor: AppTheme.error,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 4),
  ));
}

// ── Confirm Dialog ────────────────────────────────────────
Future<bool> confirmDelete(BuildContext ctx, String nombre) async {
  return await showDialog<bool>(
    context: ctx,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
        SizedBox(width: 10),
        Text('Confirmar', style: TextStyle(color: AppTheme.textPrimary)),
      ]),
      content: Text('¿Eliminar "$nombre"?\nEsta acción no se puede deshacer.',
          style: const TextStyle(color: AppTheme.textMuted)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  ) ?? false;
}

// ── Empty State ───────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({super.key, required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textMuted.withOpacity(.4)),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
            textAlign: TextAlign.center),
      ]),
    ),
  );
}

// ── Loading ───────────────────────────────────────────────
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AppTheme.primary),
  );
}

// ── Section Badge ─────────────────────────────────────────
class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const AppBadge({super.key, required this.label, required this.color, required this.bg});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}

// ── Info Row en Cards ─────────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const InfoRow({super.key, required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Icon(icon, size: 14, color: AppTheme.textMuted),
      const SizedBox(width: 6),
      Text('$label: ', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
      Expanded(child: Text(value,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis)),
    ]),
  );
}

// ── Form Field ────────────────────────────────────────────
class AppField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool required;
  final int maxLines;
  final String? hint;
  const AppField({super.key, required this.label, required this.controller,
      this.keyboardType, this.required = false, this.maxLines = 1, this.hint});
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: const TextStyle(color: AppTheme.textPrimary),
    validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null : null,
    decoration: InputDecoration(labelText: label, hintText: hint),
  );
}

// ── Stat Card (Dashboard) ─────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const StatCard({super.key, required this.label, required this.value,
      required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textMuted.withOpacity(.5)),
        ]),
        const SizedBox(height: 14),
        Text('$value', style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
      ]),
    ),
  );
}
