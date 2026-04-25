import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Clinical Help'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _section('What is DDK?', Icons.psychology_rounded, AppTheme.accent, [
            _card('Diadochokinesis (DDK)',
              'Diadochokinesis is the ability to make rapid, alternating movements. '
              'In speech assessment, it measures how quickly and accurately a patient can produce '
              'repetitive syllable sequences.\n\n'
              'DDK rates provide objective, quantifiable data about oral motor speed and coordination — '
              'key indicators of neuromotor integrity. Reduced DDK rates may indicate dysarthria, '
              'motor neuron disease, or cerebellar dysfunction.',
              Icons.info_outline_rounded, AppTheme.accent),
          ]),

          _section('Test Types', Icons.mic_rounded, AppTheme.amr, [
            _card('AMR — Alternating Motion Rate',
              'Rapid repetition of a single syllable: "pa-pa-pa" (or "ka-ka-ka").\n\n'
              '"pa" primarily targets labial (lip) closure. AMR is sensitive to labial motor weakness '
              'and imprecise articulatory movements. It is the most commonly used DDK measure in clinical practice.',
              Icons.arrow_forward_rounded, AppTheme.amr),
            _card('SMR — Sequential Motion Rate',
              'Rapid repetition of the trisyllabic sequence: "pa-ta-ka".\n\n'
              'Requires sequential coordination of labial (pa), lingual-alveolar (ta), and velar (ka) contacts. '
              'SMR is more demanding and may reveal deficits not captured by AMR alone — particularly '
              'motor sequencing and tri-syllabic coordination.',
              Icons.arrow_forward_rounded, AppTheme.smr),
          ]),

          _section('Normal Values', Icons.table_chart_outlined, AppTheme.success, [
            _normTable(),
          ]),

          _section('Interpretation', Icons.analytics_outlined, AppTheme.warning, [
            _card('Normal',
              'Rate is within age-appropriate norms. Oral motor function is adequate for speech '
              'production. No further DDK-specific intervention is indicated at this time.',
              Icons.check_circle_rounded, AppTheme.success),
            _card('Borderline',
              'Rate is mildly reduced. Repeat assessment and clinical correlation are recommended. '
              'Consider fatigue, anxiety, or unfamiliarity with the task. Compare with connected speech findings.',
              Icons.warning_amber_rounded, AppTheme.warning),
            _card('Possible Dysarthria',
              'Rate is significantly below norms. This pattern is consistent with motor speech disorders. '
              'Recommend: comprehensive motor speech evaluation, oral mechanism exam, connected speech analysis, '
              'and — if aetiology is unclear — neurological referral.',
              Icons.error_rounded, AppTheme.danger),
          ]),

          _section('Rhythm Regularity', Icons.graphic_eq_rounded, const Color(0xFF06B6D4), [
            _card('IOI Standard Deviation (IOI SD)',
              'The engine calculates the standard deviation of inter-onset intervals (time between '
              'detected syllable onsets) in milliseconds.\n\n'
              '• SD < 20 ms → Regular (intact motor timing)\n'
              '• SD 20–40 ms → Slightly Irregular (monitor; may reflect fatigue)\n'
              '• SD > 40 ms → Irregular (significant timing variability — correlate clinically)\n\n'
              'Increased IOI SD at normal rates may suggest subtle motor timing issues not captured '
              'by rate alone.',
              Icons.show_chart_rounded, const Color(0xFF06B6D4)),
          ]),

          _section('Clinical Tips', Icons.lightbulb_outlined, AppTheme.warning, [
            _card('Patient Instructions',
              'Demonstrate the target sequence before recording. Say: "Repeat pa-pa-pa (or pa-ta-ka) '
              'as fast and as clearly as you can for [X] seconds." Allow 1–2 practice trials. '
              'Ensure the patient understands the task is about speed AND accuracy.',
              Icons.person_outlined, AppTheme.warning),
            _card('Recording Environment',
              'In Auto mode: use a quiet room; position the device 20–30 cm from the patient\'s mouth. '
              'Avoid rooms with strong echo. Background noise raises the amplitude floor and may '
              'cause missed detections or false positives.',
              Icons.room_outlined, AppTheme.warning),
            _card('Multiple Trials',
              'For diagnostic purposes, conduct 2–3 trials per syllable type and average results. '
              'DDK rates can vary between trials due to warm-up effects or fatigue — particularly '
              'in older or neurologically impaired patients.',
              Icons.repeat_rounded, AppTheme.warning),
            _card('Differential Considerations',
              '• Reduced AMR with normal SMR → primarily labial weakness\n'
              '• Reduced SMR with normal AMR → motor sequencing or coordination deficit\n'
              '• Both reduced → consider dysarthria, MND, Parkinsonism, cerebellar disorder\n'
              '• High IOI SD despite normal rate → subtle timing dysfunction',
              Icons.account_tree_outlined, AppTheme.warning),
          ]),

          _section('References', Icons.book_outlined, AppTheme.textMuted, [
            _refBox([
              'Duffy, J.R. (2013). Motor Speech Disorders. 3rd ed. Elsevier.',
              'Kent, R.D. et al. (1987). Maximum performance tests of speech production. JSHD, 52(4).',
              'Fletcher, S.G. (1972). Time-by-count measurement of DDK syllable rate. JSR, 15(4).',
              'Yorkston, K.M. et al. (2010). Management of Motor Speech Disorders in Children and Adults.',
            ]),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, Color color, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 9),
          Text(title.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: color, letterSpacing: 1)),
        ]),
      ),
      ...children,
      const SizedBox(height: 22),
    ]);
  }

  Widget _card(String title, String body, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Text(body,
            style: GoogleFonts.inter(
              fontSize: 12, color: AppTheme.textSecondary, height: 1.55)),
        ])),
      ]),
    );
  }

  Widget _normTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        // Header
        _NormHeaderRow(),
        const Divider(height: 1, color: AppTheme.border),
        _NormDataRow('Child',     '≥4.5', '3.5–4.5', '≥4.0', '3.0–4.0', false),
        const Divider(height: 1, color: AppTheme.border),
        _NormDataRow('Adult',     '≥5.5', '4.5–5.5', '≥5.0', '4.0–5.0', true),
        const Divider(height: 1, color: AppTheme.border),
        _NormDataRow('Geriatric', '≥4.8', '3.8–4.8', '≥4.2', '3.2–4.2', false),
      ]),
    );
  }

  Widget _refBox(List<String> refs) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: refs.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(margin: const EdgeInsets.only(top: 5),
              width: 3, height: 3,
              decoration: const BoxDecoration(
                color: AppTheme.textMuted, shape: BoxShape.circle)),
            const SizedBox(width: 9),
            Expanded(child: Text(r,
              style: GoogleFonts.inter(
                fontSize: 11, color: AppTheme.textSecondary, height: 1.5))),
          ]),
        )).toList(),
      ),
    );
  }
}

class _NormHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        const SizedBox(width: 72),
        Expanded(child: Text('AMR', textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.amr))),
        Expanded(child: Text('SMR', textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.smr))),
      ]),
    );
  }
}

class _NormDataRow extends StatelessWidget {
  const _NormDataRow(this.group,
    this.amrN, this.amrB, this.smrN, this.smrB, this.highlight);
  final String group, amrN, amrB, smrN, smrB; final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: highlight ? AppTheme.accent.withOpacity(0.05) : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(children: [
        SizedBox(width: 72,
          child: Text(group,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
        Expanded(child: Column(children: [
          Text(amrN, style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.success)),
          Text(amrB, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.warning)),
        ])),
        Expanded(child: Column(children: [
          Text(smrN, style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.success)),
          Text(smrB, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.warning)),
        ])),
      ]),
    );
  }
}
