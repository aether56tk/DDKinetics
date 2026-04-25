import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

// ── DDK Chip (AMR / SMR badge) ────────────────────────────────────────────────
class TestChip extends StatelessWidget {
  const TestChip(this.type, {super.key});
  final TestType type;

  @override
  Widget build(BuildContext context) {
    final c = type == TestType.amr ? AppTheme.amr : AppTheme.smr;
    final label = type == TestType.amr ? 'AMR' : 'SMR';
    return _Pill(label: label, color: c);
  }
}

// ── Result Badge ──────────────────────────────────────────────────────────────
class ResultBadge extends StatelessWidget {
  const ResultBadge(this.result, {super.key, this.large = false});
  final DDKResult result;
  final bool large;

  String get _label {
    switch (result) {
      case DDKResult.normal:             return 'Normal';
      case DDKResult.borderline:         return 'Borderline';
      case DDKResult.possibleDysarthria: return 'Possible Dysarthria';
    }
  }
  Color get _color => AppTheme.resultColor(_label);
  IconData get _icon {
    switch (result) {
      case DDKResult.normal:             return Icons.check_circle_rounded;
      case DDKResult.borderline:         return Icons.warning_amber_rounded;
      case DDKResult.possibleDysarthria: return Icons.error_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 16 : 10, vertical: large ? 10 : 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(large ? 12 : 7),
        border: Border.all(color: _color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: large ? 18 : 13, color: _color),
          SizedBox(width: large ? 8 : 5),
          Text(
            _label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: large ? 15 : 11,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Metric tile ───────────────────────────────────────────────────────────────
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.color,
    this.icon,
  });
  final String label;
  final String value;
  final String? unit;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: AppTheme.textMuted),
              const SizedBox(width: 5),
            ],
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10, color: AppTheme.textMuted,
                fontWeight: FontWeight.w600, letterSpacing: 0.9,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: color ?? AppTheme.textPrimary, height: 1,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(unit!,
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── PillToggle ────────────────────────────────────────────────────────────────
class PillToggle<T> extends StatelessWidget {
  const PillToggle({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.colors,
  });
  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: List.generate(values.length, (i) {
          final active = values[i] == selected;
          final c = colors != null ? colors![i] : AppTheme.accent;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(values[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active ? c.withOpacity(0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: active ? Border.all(color: c.withOpacity(0.45)) : null,
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: active ? c : AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: AppTheme.textMuted, letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Waveform painter ──────────────────────────────────────────────────────────
class WaveformPainter extends CustomPainter {
  WaveformPainter({required this.data, required this.color});
  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final dx = size.width / (data.length - 1);
    final mid = size.height / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final top = Path(), bot = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final h = data[i] * mid * 0.92;
      if (i == 0) { top.moveTo(x, mid - h); bot.moveTo(x, mid + h); }
      else        { top.lineTo(x, mid - h); bot.lineTo(x, mid + h); }
    }
    canvas.drawPath(top, paint);
    canvas.drawPath(bot, paint..color = color.withOpacity(0.35));
  }

  @override
  bool shouldRepaint(WaveformPainter old) => old.data != data;
}

// ── Private pill ─────────────────────────────────────────────────────────────
class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11, fontWeight: FontWeight.w700, color: color,
        ),
      ),
    );
  }
}
