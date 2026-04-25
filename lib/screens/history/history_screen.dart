import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/history_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../assessment/result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HistoryProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (hp.totalCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(child: Text('${hp.totalCount} records',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted))),
            ),
        ],
      ),
      body: Column(children: [
        _filterBar(hp),
        Expanded(
          child: hp.filtered.isEmpty
              ? _empty(hp.filter)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: hp.filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) => _AssessmentTile(hp.filtered[i]),
                ),
        ),
      ]),
    );
  }

  // ── Filter bar ───────────────────────────────────────────────────────────────
  Widget _filterBar(HistoryProvider hp) {
    final all = hp.all;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _FilterChip('All', all.length,
            hp.filter == HistoryFilter.all, AppTheme.accent,
            () => hp.setFilter(HistoryFilter.all)),
          const SizedBox(width: 7),
          _FilterChip('Normal',
            all.where((a) => a.result == DDKResult.normal).length,
            hp.filter == HistoryFilter.normal, AppTheme.success,
            () => hp.setFilter(HistoryFilter.normal)),
          const SizedBox(width: 7),
          _FilterChip('Borderline',
            all.where((a) => a.result == DDKResult.borderline).length,
            hp.filter == HistoryFilter.borderline, AppTheme.warning,
            () => hp.setFilter(HistoryFilter.borderline)),
          const SizedBox(width: 7),
          _FilterChip('Dysarthria',
            all.where((a) => a.result == DDKResult.possibleDysarthria).length,
            hp.filter == HistoryFilter.dysarthria, AppTheme.danger,
            () => hp.setFilter(HistoryFilter.dysarthria)),
        ]),
      ),
    );
  }

  Widget _empty(HistoryFilter f) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.history_rounded, size: 48, color: AppTheme.textMuted),
        const SizedBox(height: 14),
        Text(f == HistoryFilter.all ? 'No assessments yet' : 'No matching records',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        Text(f == HistoryFilter.all
            ? 'Complete an assessment to see records here'
            : 'Try a different filter',
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
      ]),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip(this.label, this.count, this.selected, this.color, this.onTap);
  final String label; final int count;
  final bool selected; final Color color; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.14) : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? color.withOpacity(0.4) : AppTheme.border),
        ),
        child: Row(children: [
          Text(label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: selected ? color : AppTheme.textSecondary)),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: selected ? color.withOpacity(0.2) : AppTheme.border,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('$count',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: selected ? color : AppTheme.textMuted)),
          ),
        ]),
      ),
    );
  }
}

// ── Assessment tile ───────────────────────────────────────────────────────────
class _AssessmentTile extends StatelessWidget {
  const _AssessmentTile(this.model);
  final AssessmentModel model;

  Color get _rc => AppTheme.resultColor(model.resultLabel);

  @override
  Widget build(BuildContext context) {
    final hp = context.read<HistoryProvider>();
    return Dismissible(
      key: Key(model.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          color: AppTheme.danger.withOpacity(0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 22),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: AppTheme.card,
          title: Text('Delete Record?',
            style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary)),
          content: Text('This assessment will be permanently deleted.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
            TextButton(onPressed: () => Navigator.pop(c, true),
              child: const Text('Delete', style: TextStyle(color: AppTheme.danger))),
          ],
        ),
      ),
      onDismissed: (_) => hp.delete(model.id),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => ResultScreen(model: model))),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(children: [
            // Left accent bar
            Container(width: 4, height: 44,
              decoration: BoxDecoration(
                color: _rc, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(model.displayName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (model.isEmergency)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.emergency.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('EMRG',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 8, fontWeight: FontWeight.w700,
                          color: AppTheme.emergency, letterSpacing: 0.5)),
                    ),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  TestChip(model.testType),
                  const SizedBox(width: 6),
                  Text(DateFormat('dd MMM, hh:mm a').format(model.timestamp),
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                ]),
              ]),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${model.rate.toStringAsFixed(2)}/s',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15, fontWeight: FontWeight.w800, color: _rc)),
              const SizedBox(height: 4),
              ResultBadge(model.result),
            ]),
          ]),
        ),
      ),
    );
  }
}
