import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import 'test_config_screen.dart';

class PatientInfoScreen extends StatefulWidget {
  const PatientInfoScreen({super.key});
  @override State<PatientInfoScreen> createState() => _State();
}

class _State extends State<PatientInfoScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _fnCtrl   = TextEditingController();
  final _lnCtrl   = TextEditingController();
  final _ageCtrl  = TextEditingController();
  final _notesCtrl= TextEditingController();
  String _gender  = 'Male';

  @override
  void dispose() {
    _fnCtrl.dispose(); _lnCtrl.dispose();
    _ageCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('New Assessment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProgressBar(step: 1),
              const SizedBox(height: 24),
              Text('Patient Information',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('Fill in the patient details for this assessment',
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 28),

              // Name row
              Row(children: [
                Expanded(child: _field(ctrl: _fnCtrl, label: 'First Name',
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null)),
                const SizedBox(width: 12),
                Expanded(child: _field(ctrl: _lnCtrl, label: 'Last Name',
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null)),
              ]),
              const SizedBox(height: 14),

              _field(
                ctrl: _ageCtrl, label: 'Age',
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final n = int.tryParse(v);
                  if (n == null || n < 1 || n > 120) return 'Enter a valid age';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const SectionLabel('Gender'),
              PillToggle<String>(
                values: const ['Male', 'Female', 'Other'],
                labels: const ['Male', 'Female', 'Other'],
                selected: _gender,
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 16),

              _field(ctrl: _notesCtrl, label: 'Clinical Notes (optional)', maxLines: 3),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: const Text('Continue → Test Configuration'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(labelText: label),
    );
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    final ap = context.read<AssessmentProvider>();
    ap.setFirstName(_fnCtrl.text.trim());
    ap.setLastName(_lnCtrl.text.trim());
    ap.setAge(int.tryParse(_ageCtrl.text));
    ap.setGender(_gender);
    ap.setNotes(_notesCtrl.text.trim());
    Navigator.push(context, MaterialPageRoute(builder: (_) => const TestConfigScreen()));
  }
}

// ── 2-step progress bar ───────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(2, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < 1 ? 6 : 0),
          height: 4,
          decoration: BoxDecoration(
            color: i + 1 <= step ? AppTheme.accent : AppTheme.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      )),
    );
  }
}
