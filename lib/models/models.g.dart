// Hand-written Hive adapters — no build_runner required.
part of 'models.dart';

// ── TestTypeAdapter ───────────────────────────────────────────────────────────
class TestTypeAdapter extends TypeAdapter<TestType> {
  @override final int typeId = 0;
  @override TestType read(BinaryReader r) => r.readByte() == 0 ? TestType.amr : TestType.smr;
  @override void write(BinaryWriter w, TestType o) => w.writeByte(o == TestType.amr ? 0 : 1);
}

// ── PatientTypeAdapter ────────────────────────────────────────────────────────
class PatientTypeAdapter extends TypeAdapter<PatientType> {
  @override final int typeId = 1;
  @override PatientType read(BinaryReader r) {
    switch (r.readByte()) {
      case 0: return PatientType.child;
      case 2: return PatientType.geriatric;
      default: return PatientType.adult;
    }
  }
  @override void write(BinaryWriter w, PatientType o) {
    switch (o) {
      case PatientType.child:     w.writeByte(0); break;
      case PatientType.adult:     w.writeByte(1); break;
      case PatientType.geriatric: w.writeByte(2); break;
    }
  }
}

// ── InputModeAdapter ──────────────────────────────────────────────────────────
class InputModeAdapter extends TypeAdapter<InputMode> {
  @override final int typeId = 2;
  @override InputMode read(BinaryReader r) => r.readByte() == 0 ? InputMode.auto : InputMode.manual;
  @override void write(BinaryWriter w, InputMode o) => w.writeByte(o == InputMode.auto ? 0 : 1);
}

// ── DDKResultAdapter ──────────────────────────────────────────────────────────
class DDKResultAdapter extends TypeAdapter<DDKResult> {
  @override final int typeId = 3;
  @override DDKResult read(BinaryReader r) {
    switch (r.readByte()) {
      case 1: return DDKResult.borderline;
      case 2: return DDKResult.possibleDysarthria;
      default: return DDKResult.normal;
    }
  }
  @override void write(BinaryWriter w, DDKResult o) {
    switch (o) {
      case DDKResult.normal:             w.writeByte(0); break;
      case DDKResult.borderline:         w.writeByte(1); break;
      case DDKResult.possibleDysarthria: w.writeByte(2); break;
    }
  }
}

// ── AssessmentModelAdapter ────────────────────────────────────────────────────
class AssessmentModelAdapter extends TypeAdapter<AssessmentModel> {
  @override final int typeId = 4;

  @override
  AssessmentModel read(BinaryReader r) {
    final n = r.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) r.readByte(): r.read()};
    return AssessmentModel(
      id:             f[0]  as String?,
      firstName:      f[1]  as String?,
      lastName:       f[2]  as String?,
      age:            f[3]  as int?,
      gender:         f[4]  as String?,
      clinicalNotes:  f[5]  as String?,
      patientType:    f[6]  as PatientType,
      testType:       f[7]  as TestType,
      inputMode:      f[8]  as InputMode,
      duration:       f[9]  as double,
      totalSyllables: f[10] as int,
      rate:           f[11] as double,
      amplitudePct:   f[12] as double,
      result:         f[13] as DDKResult,
      timestamp:      f[14] as DateTime,
      isEmergency:    f[15] as bool,
      rhythmSD:       (f[16] as double?) ?? 0.0,
      rhythmLabel:    f[17] as String?,
    );
  }

  @override
  void write(BinaryWriter w, AssessmentModel o) {
    w
      ..writeByte(18)
      ..writeByte(0)  ..write(o.id)
      ..writeByte(1)  ..write(o.firstName)
      ..writeByte(2)  ..write(o.lastName)
      ..writeByte(3)  ..write(o.age)
      ..writeByte(4)  ..write(o.gender)
      ..writeByte(5)  ..write(o.clinicalNotes)
      ..writeByte(6)  ..write(o.patientType)
      ..writeByte(7)  ..write(o.testType)
      ..writeByte(8)  ..write(o.inputMode)
      ..writeByte(9)  ..write(o.duration)
      ..writeByte(10) ..write(o.totalSyllables)
      ..writeByte(11) ..write(o.rate)
      ..writeByte(12) ..write(o.amplitudePct)
      ..writeByte(13) ..write(o.result)
      ..writeByte(14) ..write(o.timestamp)
      ..writeByte(15) ..write(o.isEmergency)
      ..writeByte(16) ..write(o.rhythmSD)
      ..writeByte(17) ..write(o.rhythmLabel);
  }
}
