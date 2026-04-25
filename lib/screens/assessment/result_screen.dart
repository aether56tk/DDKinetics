import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../home/home_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.model});
  final AssessmentModel model;

  Color get _rc => AppTheme.resultColor(model.resultLabel);

  @override
  Widget build(BuildContext context) {
    final norm = DDKNorms.getNorm(model.patientType, model.testType);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Results'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false),
            child: Text('Done',
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hero().animate().fadeIn(duration: 400.ms).scale(begin: const Offset(.92, .92)),
            const SizedBox(height: 22),
            _metrics(),
            const SizedBox(height: 18),
            _normPanel(norm),
            if (model.hasRhythm) ...[
              const SizedBox(height: 18),
              _rhythmPanel(),
            ],
            const SizedBox(height: 18),
            if (!model.isEmergency) _patientPanel(),
            const SizedBox(height: 18),
            _interpretationPanel(),
            const SizedBox(height: 28),
            _actions(context),
          ],
        ),
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────────────────────────
  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          _rc.withOpacity(0.16), _rc.withOpacity(0.05)
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _rc.withOpacity(0.35)),
      ),
      child: Column(children: [
        ResultBadge(model.result, large: true),
        const SizedBox(height: 16),
        Text(model.rate.toStringAsFixed(2),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 60, fontWeight: FontWeight.w800, color: _rc, height: 1)),
        Text('syllables / second',
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TestChip(model.testType),
          const SizedBox(width: 8),
          _Chip(model.patientLabel, AppTheme.textMuted),
        ]),
      ]),
    );
  }

  // ── Metrics grid ─────────────────────────────────────────────────────────────
  Widget _metrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Measurements'),
        Row(children: [
          Expanded(child: MetricTile(
            label: 'Duration', value: model.duration.toStringAsFixed(1),
            unit: 's', icon: Icons.timer_outlined)),
          const SizedBox(width: 10),
          Expanded(child: MetricTile(
            label: 'Syllables', value: '${model.totalSyllables}',
            icon: Icons.graphic_eq_rounded)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: MetricTile(
            label: 'Rate', value: model.rate.toStringAsFixed(2), unit: '/s',
            icon: Icons.speed_rounded, color: _rc)),
          const SizedBox(width: 10),
          Expanded(child: MetricTile(
            label: 'Amplitude', value: model.amplitudePct.toStringAsFixed(0),
            unit: '%', icon: Icons.equalizer_rounded)),
        ]),
      ],
    );
  }

  // ── Norm panel ────────────────────────────────────────────────────────────────
  Widget _normPanel(DDKNorm norm) {
    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionLabel('Norm Comparison'),
        _NormRow('Normal',     norm.normalMin,    AppTheme.success),
        const SizedBox(height: 6),
        _NormRow('Borderline', norm.borderlineMin, AppTheme.warning),
        const Divider(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Patient rate',
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
          Text('${model.rate.toStringAsFixed(2)} syl/s',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15, fontWeight: FontWeight.w700, color: _rc)),
        ]),
        const SizedBox(height: 4),
        Text('Norms for ${model.patientLabel} · ${model.testLabel}',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
      ]),
    );
  }

  // ── Rhythm panel ─────────────────────────────────────────────────────────────
  Widget _rhythmPanel() {
    final label = model.rhythmLabel!;
    final Color c = label == 'Regular'
        ? AppTheme.success
        : label == 'Slightly Irregular' ? AppTheme.warning : AppTheme.danger;
    final IconData ic = label == 'Regular'
        ? Icons.graphic_eq_rounded
        : label == 'Slightly Irregular' ? Icons.show_chart_rounded : Icons.ssid_chart_rounded;

    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionLabel('Rhythm Regularity'),
        Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(ic, color: c, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16, fontWeight: FontWeight.w700, color: c)),
            Text('IOI SD = ${model.rhythmSD.toStringAsFixed(1)} ms',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
        ]),
        const Divider(height: 20),
        Text(
          label == 'Regular'
              ? 'Consistent inter-syllable timing. Suggests intact motor timing circuitry.'
              : label == 'Slightly Irregular'
                  ? 'Mild timing variability. May reflect fatigue or task unfamiliarity. Monitor over time.'
                  : 'Significant timing variability (IOI SD > 40 ms). May indicate motor timing disorder — correlate with other clinical findings.',
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
        ),
      ]),
    );
  }

  // ── Patient panel ─────────────────────────────────────────────────────────────
  Widget _patientPanel() {
    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionLabel('Patient'),
        _Row('Name', model.displayName),
        if (model.age != null) _Row('Age', '${model.age} years'),
        if (model.gender != null) _Row('Gender', model.gender!),
        _Row('Type', model.patientLabel),
        _Row('Date', DateFormat('dd MMM yyyy, hh:mm a').format(model.timestamp)),
        if (model.clinicalNotes != null) _Row('Notes', model.clinicalNotes!),
      ]),
    );
  }

  // ── Interpretation panel ──────────────────────────────────────────────────────
  Widget _interpretationPanel() {
    final text = () {
      switch (model.result) {
        case DDKResult.normal:
          return 'DDK rate is within normal limits for ${model.patientLabel.toLowerCase()} patients. '
              '${model.testType == TestType.amr ? "Labial motor function appears intact." : "Oral motor coordination appears intact."} '
              'No further DDK-specific intervention indicated at this time.';
        case DDKResult.borderline:
          return 'DDK rate is in the borderline range. Consider repeat assessment and correlation '
              'with connected speech analysis. May warrant further investigation if other '
              'speech-motor symptoms are present.';
        case DDKResult.possibleDysarthria:
          return 'DDK rate is below normal limits, consistent with possible motor speech disorder or dysarthria. '
              'Recommend comprehensive motor speech evaluation including oral mechanism examination, '
              'connected speech analysis, and — if aetiology is unclear — neurological referral.';
      }
    }();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _rc.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rc.withOpacity(0.22)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.medical_information_outlined, size: 13, color: _rc),
          const SizedBox(width: 6),
          Text('CLINICAL INTERPRETATION',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: _rc, letterSpacing: 1)),
        ]),
        const SizedBox(height: 10),
        Text(text,
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
      ]),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────────
  Widget _actions(BuildContext context) {
    return Row(children: [
      Expanded(child: OutlinedButton.icon(
        onPressed: () => Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false),
        icon: const Icon(Icons.home_outlined, size: 17),
        label: const Text('Home'),
      )),
      const SizedBox(width: 12),
      Expanded(child: ElevatedButton.icon(
        onPressed: () => Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false),
        icon: const Icon(Icons.add_rounded, size: 17),
        label: const Text('New Test'),
      )),
    ]);
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

class _NormRow extends StatelessWidget {
  const _NormRow(this.label, this.min, this.color);
  final String label; final double min; final Color color;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 6, height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      SizedBox(width: 82,
        child: Text(label,
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary))),
      Text('≥ $min syl/s',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
    ]);
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 72,
          child: Text(label,
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted))),
        Expanded(child: Text(value,
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textPrimary))),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.color);
  final String label; final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
