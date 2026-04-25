import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'models.g.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

@HiveType(typeId: 0)
enum TestType {
  @HiveField(0) amr,
  @HiveField(1) smr,
}

@HiveType(typeId: 1)
enum PatientType {
  @HiveField(0) child,
  @HiveField(1) adult,
  @HiveField(2) geriatric,
}

@HiveType(typeId: 2)
enum InputMode {
  @HiveField(0) auto,
  @HiveField(1) manual,
}

@HiveType(typeId: 3)
enum DDKResult {
  @HiveField(0) normal,
  @HiveField(1) borderline,
  @HiveField(2) possibleDysarthria,
}

// ── DDK Norms ─────────────────────────────────────────────────────────────────

class DDKNorm {
  final double normalMin;
  final double borderlineMin;
  const DDKNorm({required this.normalMin, required this.borderlineMin});
}

class DDKNorms {
  static const Map<PatientType, Map<TestType, DDKNorm>> norms = {
    PatientType.adult: {
      TestType.amr: DDKNorm(normalMin: 5.5, borderlineMin: 4.5),
      TestType.smr: DDKNorm(normalMin: 5.0, borderlineMin: 4.0),
    },
    PatientType.child: {
      TestType.amr: DDKNorm(normalMin: 4.5, borderlineMin: 3.5),
      TestType.smr: DDKNorm(normalMin: 4.0, borderlineMin: 3.0),
    },
    PatientType.geriatric: {
      TestType.amr: DDKNorm(normalMin: 4.8, borderlineMin: 3.8),
      TestType.smr: DDKNorm(normalMin: 4.2, borderlineMin: 3.2),
    },
  };

  static DDKNorm getNorm(PatientType pt, TestType tt) => norms[pt]![tt]!;

  static DDKResult interpret({
    required double rate,
    required PatientType patientType,
    required TestType testType,
  }) {
    final norm = getNorm(patientType, testType);
    if (rate >= norm.normalMin) return DDKResult.normal;
    if (rate >= norm.borderlineMin) return DDKResult.borderline;
    return DDKResult.possibleDysarthria;
  }
}

// ── AssessmentModel ───────────────────────────────────────────────────────────

@HiveType(typeId: 4)
class AssessmentModel extends HiveObject {
  @HiveField(0)  final String id;
  @HiveField(1)  final String? firstName;
  @HiveField(2)  final String? lastName;
  @HiveField(3)  final int? age;
  @HiveField(4)  final String? gender;
  @HiveField(5)  final String? clinicalNotes;
  @HiveField(6)  final PatientType patientType;
  @HiveField(7)  final TestType testType;
  @HiveField(8)  final InputMode inputMode;
  @HiveField(9)  final double duration;
  @HiveField(10) final int totalSyllables;
  @HiveField(11) final double rate;
  @HiveField(12) final double amplitudePct;  // 0–100
  @HiveField(13) final DDKResult result;
  @HiveField(14) final DateTime timestamp;
  @HiveField(15) final bool isEmergency;
  @HiveField(16) final double rhythmSD;      // IOI SD in ms; 0 if manual
  @HiveField(17) final String? rhythmLabel;  // "Regular" / "Slightly Irregular" / "Irregular"

  AssessmentModel({
    String? id,
    this.firstName,
    this.lastName,
    this.age,
    this.gender,
    this.clinicalNotes,
    required this.patientType,
    required this.testType,
    required this.inputMode,
    required this.duration,
    required this.totalSyllables,
    required this.rate,
    required this.amplitudePct,
    required this.result,
    DateTime? timestamp,
    this.isEmergency = false,
    this.rhythmSD = 0.0,
    this.rhythmLabel,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  // ── Derived getters ──────────────────────────────────────────────────────────
  String get displayName {
    if (isEmergency) return 'Emergency';
    final parts = [firstName, lastName].whereType<String>().join(' ').trim();
    return parts.isEmpty ? 'Unknown' : parts;
  }

  String get testLabel => testType == TestType.amr ? 'AMR' : 'SMR';
  String get patientLabel {
    switch (patientType) {
      case PatientType.child: return 'Child';
      case PatientType.adult: return 'Adult';
      case PatientType.geriatric: return 'Geriatric';
    }
  }
  String get resultLabel {
    switch (result) {
      case DDKResult.normal: return 'Normal';
      case DDKResult.borderline: return 'Borderline';
      case DDKResult.possibleDysarthria: return 'Possible Dysarthria';
    }
  }
  bool get hasRhythm =>
      inputMode == InputMode.auto &&
      rhythmLabel != null &&
      rhythmLabel != 'Insufficient data';
}
