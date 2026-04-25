import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/assessment_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import 'recording_screen.dart';

class TestConfigScreen extends StatelessWidget {
  const TestConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AssessmentProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Test Configuration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProgressBar2(),
            const SizedBox(height: 24),
            Text('Configure Test',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('Choose assessment parameters',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 28),

            // Patient type
            const SectionLabel('Patient Type'),
            PillToggle<PatientType>(
              values: PatientType.values,
              labels: const ['Child', 'Adult', 'Geriatric'],
              selected: ap.patientType,
              onChanged: ap.setPatientType,
            ),
            const SizedBox(height: 18),

            // Test type
            const SectionLabel('Test Type'),
            PillToggle<TestType>(
              values: TestType.values,
              labels: const ['AMR  pa-pa-pa', 'SMR  pa-ta-ka'],
              selected: ap.testType,
              onChanged: ap.setTestType,
              colors: const [AppTheme.amr, AppTheme.smr],
            ),
            const SizedBox(height: 8),
            _typeInfo(ap.testType),
            const SizedBox(height: 18),

            // Input mode
            const SectionLabel('Input Mode'),
            PillToggle<InputMode>(
              values: InputMode.values,
              labels: const ['Manual Tap', 'Auto (Mic)'],
              selected: ap.inputMode,
              onChanged: ap.setInputMode,
            ),
            const SizedBox(height: 8),
            _modeInfo(ap.inputMode),
            const SizedBox(height: 18),

            // Duration
            _durationSlider(ap),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const RecordingScreen())),
                child: const Text('Start Assessment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeInfo(TestType t) {
    final txt = t == TestType.amr
        ? 'AMR assesses labial (lip) motor speed via single-syllable repetition.'
        : 'SMR assesses oral motor coordination via tri-syllabic sequencing.';
    return _InfoBox(txt, color: t == TestType.amr ? AppTheme.amr : AppTheme.smr);
  }

  Widget _modeInfo(InputMode m) {
    final txt = m == InputMode.manual
        ? 'Tap the screen once per syllable you hear. Best in noisy environments.'
        : 'Microphone detects syllables via RMS energy + 130ms refractory window.';
    return _InfoBox(txt, color: AppTheme.textMuted);
  }

  Widget _durationSlider(AssessmentProvider ap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const SectionLabel('Duration'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
            ),
            child: Text('${ap.targetSecs.round()}s',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.accent)),
          ),
        ]),
        Slider(
          value: ap.targetSecs,
          min: 5, max: 15, divisions: 10,
          label: '${ap.targetSecs.round()}s',
          onChanged: ap.setTargetSecs,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('5s', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
          Text('15s', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
        ]),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox(this.text, {required this.color});
  final String text; final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 13, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text,
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.4))),
        ],
      ),
    );
  }
}

class _ProgressBar2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(2, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < 1 ? 6 : 0),
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.accent, borderRadius: BorderRadius.circular(2)),
        ),
      )),
    );
  }
}
