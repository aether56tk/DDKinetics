import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/assessment_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import 'recording_screen.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AssessmentProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.emergency.withOpacity(0.15),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppTheme.emergency.withOpacity(0.4)),
            ),
            child: Text('EMERGENCY',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: AppTheme.emergency, letterSpacing: 1.2,
              )),
          ),
          const SizedBox(width: 10),
          Text('Quick Assessment',
            style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary)),
        ]),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.emergency.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.emergency.withOpacity(0.25)),
              ),
              child: Row(children: [
                const Icon(Icons.bolt_rounded, color: AppTheme.emergency, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'No patient information required. Choose test type and begin immediately.',
                  style: GoogleFonts.inter(
                    fontSize: 13, color: AppTheme.emergency.withOpacity(0.8), height: 1.4),
                )),
              ]),
            ),
            const SizedBox(height: 28),

            const SectionLabel('Test Type'),
            PillToggle<TestType>(
              values: TestType.values,
              labels: const ['AMR  pa-pa-pa', 'SMR  pa-ta-ka'],
              selected: ap.testType,
              onChanged: ap.setTestType,
              colors: const [AppTheme.amr, AppTheme.smr],
            ),
            const SizedBox(height: 20),

            const SectionLabel('Input Mode'),
            PillToggle<InputMode>(
              values: InputMode.values,
              labels: const ['Manual Tap', 'Auto (Mic)'],
              selected: ap.inputMode,
              onChanged: ap.setInputMode,
            ),
            const SizedBox(height: 20),

            // Duration
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const SectionLabel('Duration'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.emergency.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppTheme.emergency.withOpacity(0.3)),
                ),
                child: Text('${ap.targetSecs.round()}s',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.emergency)),
              ),
            ]),
            Slider(
              value: ap.targetSecs, min: 5, max: 15, divisions: 10,
              label: '${ap.targetSecs.round()}s',
              onChanged: ap.setTargetSecs,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const RecordingScreen())),
                icon: const Icon(Icons.flash_on_rounded, size: 20),
                label: const Text('Start Emergency Assessment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emergency,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
