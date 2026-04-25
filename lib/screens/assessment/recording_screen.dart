import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/assessment_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import 'result_screen.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});
  @override State<RecordingScreen> createState() => _State();
}

class _State extends State<RecordingScreen> with TickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  // Navigate to results once done
  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AssessmentProvider>();

    if (ap.sessionState == SessionState.done && ap.result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => ResultScreen(model: ap.result!)));
      });
    }

    final typeColor = ap.testType == TestType.amr ? AppTheme.amr : AppTheme.smr;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(ap.isEmergency ? 'Emergency Assessment' : 'Assessment'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            context.read<AssessmentProvider>().resetSession();
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: TestChip(ap.testType),
          ),
        ],
      ),
      body: _body(ap, typeColor),
    );
  }

  Widget _body(AssessmentProvider ap, Color typeColor) {
    switch (ap.sessionState) {
      case SessionState.countdown: return _countdown(ap);
      case SessionState.recording: return _recording(ap, typeColor);
      case SessionState.processing: return _processing();
      case SessionState.error: return _error(ap);
      default: return _idle(ap, typeColor);
    }
  }

  // ── Idle ─────────────────────────────────────────────────────────────────────
  Widget _idle(AssessmentProvider ap, Color typeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Instruction card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.card, borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(Icons.record_voice_over_rounded, color: typeColor, size: 30),
                ),
                const SizedBox(height: 16),
                Text('Say ${ap.instruction}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary, height: 1.3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${ap.targetSecs.round()} second test  ·  '
                  '${ap.inputMode == InputMode.manual ? "Tap per syllable" : "Auto mic detection"}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 18),

          // Tips
          _tips(ap.inputMode),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: ap.start,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('Start  (3s countdown)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: typeColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Countdown ────────────────────────────────────────────────────────────────
  Widget _countdown(AssessmentProvider ap) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Get ready…',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Transform.scale(
              scale: 0.93 + _pulse.value * 0.07,
              child: Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withOpacity(0.08 + _pulse.value * 0.1),
                  border: Border.all(color: AppTheme.accent, width: 2.5),
                ),
                child: Center(
                  child: Text('${ap.countdown}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 78, fontWeight: FontWeight.w800,
                      color: AppTheme.accent, height: 1)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Say ${ap.instruction}',
            style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondary),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ── Recording ─────────────────────────────────────────────────────────────────
  Widget _recording(AssessmentProvider ap, Color typeColor) {
    final progress = (ap.elapsedSecs / ap.targetSecs).clamp(0.0, 1.0);
    final isManual = ap.inputMode == InputMode.manual;

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: progress,
          minHeight: 3,
          backgroundColor: AppTheme.border,
          valueColor: AlwaysStoppedAnimation(typeColor),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Metrics
                Row(children: [
                  Expanded(child: MetricTile(
                    label: 'Time', value: ap.elapsedSecs.toStringAsFixed(1),
                    unit: 's', icon: Icons.timer_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: MetricTile(
                    label: 'Syllables', value: '${ap.syllableCount}',
                    icon: Icons.graphic_eq_rounded, color: typeColor)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: MetricTile(
                    label: 'Rate', value: ap.liveRate.toStringAsFixed(1),
                    unit: '/s', icon: Icons.speed_rounded)),
                  const SizedBox(width: 10),
                  Expanded(child: MetricTile(
                    label: 'Amplitude',
                    value: '${(ap.liveRms * 100).round()}', unit: '%',
                    icon: Icons.equalizer_rounded)),
                ]),

                // Waveform (auto mode only)
                if (!isManual && ap.waveform.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.card, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: CustomPaint(
                      size: const Size(double.infinity, 72),
                      painter: WaveformPainter(data: ap.waveform, color: typeColor),
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // Tap button (manual) or Mic indicator (auto)
                if (isManual)
                  _tapButton(ap, typeColor)
                else
                  _micIndicator(ap),

                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: ap.stop,
                  icon: const Icon(Icons.stop_rounded, size: 16),
                  label: const Text('Stop Early'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    side: BorderSide(color: AppTheme.danger.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tapButton(AssessmentProvider ap, Color typeColor) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => GestureDetector(
        onTapDown: (_) {
          HapticFeedback.mediumImpact();
          ap.tap();
        },
        child: Container(
          width: 190, height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: typeColor.withOpacity(0.10 + _pulse.value * 0.08),
            border: Border.all(color: typeColor, width: 2.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded, color: typeColor, size: 44),
              const SizedBox(height: 8),
              Text('TAP',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  color: typeColor, letterSpacing: 3)),
              Text('per syllable',
                style: GoogleFonts.inter(fontSize: 11, color: typeColor.withOpacity(0.6))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _micIndicator(AssessmentProvider ap) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: 120, height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.danger.withOpacity(0.07 + _pulse.value * 0.08),
          border: Border.all(
            color: AppTheme.danger.withOpacity(0.4 + _pulse.value * 0.5), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_rounded, color: AppTheme.danger, size: 34),
            const SizedBox(height: 4),
            Text('REC',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12, fontWeight: FontWeight.w800,
                color: AppTheme.danger, letterSpacing: 2.5)),
          ],
        ),
      ),
    );
  }

  // ── Processing ───────────────────────────────────────────────────────────────
  Widget _processing() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2),
          SizedBox(height: 20),
          Text('Analysing audio…',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────────
  Widget _error(AssessmentProvider ap) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.danger, size: 52),
            const SizedBox(height: 18),
            Text('Assessment Error',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            Text(ap.errorMsg,
              style: GoogleFonts.inter(
                fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
              textAlign: TextAlign.center),
            const SizedBox(height: 28),
            ElevatedButton(onPressed: ap.resetSession, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

  // ── Tips ─────────────────────────────────────────────────────────────────────
  Widget _tips(InputMode mode) {
    final tips = mode == InputMode.manual
        ? ['Position yourself clearly in front of the patient',
           'Tap once for each syllable you hear',
           'Maintain a consistent, non-rushed pace']
        : ['Hold device 20–30 cm from the patient',
           'Reduce background noise as much as possible',
           'Ask patient to speak loudly and clearly'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 13, color: AppTheme.warning),
          const SizedBox(width: 6),
          Text('TIPS', style: GoogleFonts.spaceGrotesk(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: AppTheme.warning, letterSpacing: 1)),
        ]),
        const SizedBox(height: 10),
        ...tips.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(margin: const EdgeInsets.only(top: 6),
              width: 3, height: 3,
              decoration: const BoxDecoration(
                color: AppTheme.textMuted, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(t,
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary))),
          ]),
        )),
      ]),
    );
  }
}
