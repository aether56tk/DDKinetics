import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/history_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../assessment/patient_info_screen.dart';
import '../assessment/emergency_screen.dart';
import '../history/history_screen.dart';
import '../help/help_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = context.watch<HistoryProvider>().totalCount;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(total).animate().fadeIn(duration: 350.ms).slideY(begin: -.06, end: 0),
              const SizedBox(height: 28),
              _emergencyBtn(context).animate().fadeIn(delay: 60.ms, duration: 350.ms).slideY(begin: .06, end: 0),
              const SizedBox(height: 14),
              _mainGrid(context).animate().fadeIn(delay: 120.ms, duration: 350.ms),
              const SizedBox(height: 28),
              _statsRow(context).animate().fadeIn(delay: 200.ms, duration: 350.ms),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _header(int total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 7, height: 7,
                  decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
                const SizedBox(width: 7),
                Text('SLP CLINICAL TOOL',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: AppTheme.accent, letterSpacing: 1.8,
                  )),
              ]),
              const SizedBox(height: 5),
              Text('DDKinetics',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 38, fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary, height: 1.05, letterSpacing: -1.5,
                )),
              Text('Diadochokinesis Assessment',
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.card, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Text('$total',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              Text('tests',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Emergency ────────────────────────────────────────────────────────────────
  Widget _emergencyBtn(BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        ctx.read<AssessmentProvider>().resetAll();
        ctx.read<AssessmentProvider>().setEmergency(true);
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => const EmergencyScreen()))
            .then((_) => ctx.read<HistoryProvider>().refresh());
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppTheme.emergency.withOpacity(0.18),
            AppTheme.emergency.withOpacity(0.07),
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.emergency.withOpacity(0.45)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppTheme.emergency.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt_rounded, color: AppTheme.emergency, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Emergency Assessment',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.emergency)),
                Text('Start immediately — no patient info needed',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.emergency.withOpacity(0.65))),
              ]),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.emergency, size: 13),
          ],
        ),
      ),
    );
  }

  // ── Main grid ────────────────────────────────────────────────────────────────
  Widget _mainGrid(BuildContext ctx) {
    return Column(children: [
      Row(children: [
        Expanded(child: _NavCard(
          title: 'New Assessment',
          sub: 'Full clinical workflow',
          icon: Icons.add_circle_outline_rounded,
          color: AppTheme.accent,
          onTap: () {
            ctx.read<AssessmentProvider>().resetAll();
            Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PatientInfoScreen()))
                .then((_) => ctx.read<HistoryProvider>().refresh());
          },
        )),
        const SizedBox(width: 12),
        Expanded(child: _NavCard(
          title: 'History',
          sub: 'All records',
          icon: Icons.history_rounded,
          color: AppTheme.smr,
          onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const HistoryScreen())),
        )),
      ]),
      const SizedBox(height: 12),
      _NavCard(
        title: 'Clinical Help',
        sub: 'DDK reference, norms, and clinical tips',
        icon: Icons.menu_book_rounded,
        color: AppTheme.success,
        horizontal: true,
        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const HelpScreen())),
      ),
    ]);
  }

  // ── Stats row ─────────────────────────────────────────────────────────────────
  Widget _statsRow(BuildContext ctx) {
    final hp = ctx.watch<HistoryProvider>();
    if (hp.totalCount == 0) return const SizedBox.shrink();
    final all = hp.all;
    final n = all.where((a) => a.result == DDKResult.normal).length;
    final b = all.where((a) => a.result == DDKResult.borderline).length;
    final d = all.where((a) => a.result == DDKResult.possibleDysarthria).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('OVERVIEW',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: AppTheme.textMuted, letterSpacing: 1.4,
        )),
      const SizedBox(height: 10),
      Row(children: [
        _StatPill('Normal', n, AppTheme.success),
        const SizedBox(width: 8),
        _StatPill('Borderline', b, AppTheme.warning),
        const SizedBox(width: 8),
        _StatPill('Dysarthria', d, AppTheme.danger),
      ]),
    ]);
  }
}

// ── NavCard ───────────────────────────────────────────────────────────────────
class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.title, required this.sub,
    required this.icon,  required this.color,
    required this.onTap, this.horizontal = false,
  });
  final String title, sub;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: horizontal
            ? Row(children: [
                _icon(), const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _title(), const SizedBox(height: 2), _sub(),
                ])),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textMuted),
              ])
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _icon(), const SizedBox(height: 12), _title(), const SizedBox(height: 3), _sub(),
              ]),
      ),
    );
  }

  Widget _icon() => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
    child: Icon(icon, color: color, size: 18),
  );
  Widget _title() => Text(title,
    style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary));
  Widget _sub() => Text(sub,
    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary));
}

class _StatPill extends StatelessWidget {
  const _StatPill(this.label, this.count, this.color);
  final String label; final int count; final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Text('$count',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label,
            style: GoogleFonts.inter(fontSize: 10, color: color.withOpacity(0.65))),
        ]),
      ),
    );
  }
}
