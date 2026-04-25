import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/audio_engine.dart';
import '../services/storage_service.dart';

// ── Session state machine ─────────────────────────────────────────────────────
enum SessionState { idle, countdown, recording, processing, done, error }

class AssessmentProvider extends ChangeNotifier {
  AssessmentProvider(this._store);

  final StorageService _store;
  final AudioEngine _engine = AudioEngine();

  // ── Patient form fields ───────────────────────────────────────────────────────
  String firstName   = '';
  String lastName    = '';
  int?   age;
  String gender      = 'Male';
  String notes       = '';
  PatientType patientType = PatientType.adult;

  // ── Test config ───────────────────────────────────────────────────────────────
  TestType  testType   = TestType.amr;
  InputMode inputMode  = InputMode.manual;
  double    targetSecs = 10.0;
  bool      isEmergency = false;

  // ── Live session data ─────────────────────────────────────────────────────────
  SessionState  sessionState  = SessionState.idle;
  int           syllableCount = 0;
  double        elapsedSecs   = 0.0;
  double        liveRms       = 0.0;
  int           countdown     = 3;
  String        errorMsg      = '';

  /// Rolling RMS values for waveform (max 400 points).
  List<double> waveform = [];

  // ── Result ────────────────────────────────────────────────────────────────────
  AssessmentModel? result;

  // ── Timers ────────────────────────────────────────────────────────────────────
  Timer? _cdTimer;
  Timer? _elTimer;
  Timer? _stopTimer;

  // ── Computed ─────────────────────────────────────────────────────────────────
  double get liveRate => elapsedSecs > 0 ? syllableCount / elapsedSecs : 0.0;

  String get instruction => testType == TestType.amr
      ? '"pa-pa-pa" as fast and clearly as possible'
      : '"pa-ta-ka" as fast and clearly as possible';

  bool get canStart =>
      sessionState == SessionState.idle ||
      sessionState == SessionState.done  ||
      sessionState == SessionState.error;

  // ── Setters (for form + config) ───────────────────────────────────────────────
  void setFirstName(String v)       { firstName = v; notifyListeners(); }
  void setLastName(String v)        { lastName  = v; notifyListeners(); }
  void setAge(int? v)               { age       = v; notifyListeners(); }
  void setGender(String v)          { gender    = v; notifyListeners(); }
  void setNotes(String v)           { notes     = v; notifyListeners(); }
  void setPatientType(PatientType v){ patientType = v; notifyListeners(); }
  void setTestType(TestType v)      { testType  = v; notifyListeners(); }
  void setInputMode(InputMode v)    { inputMode = v; notifyListeners(); }
  void setTargetSecs(double v)      { targetSecs = v; notifyListeners(); }

  void setEmergency(bool v) {
    isEmergency = v;
    if (v) { firstName = ''; lastName = ''; age = null; notes = ''; }
    notifyListeners();
  }

  // ── Full reset ────────────────────────────────────────────────────────────────
  void resetSession() {
    _cancelTimers();
    sessionState  = SessionState.idle;
    syllableCount = 0;
    elapsedSecs   = 0;
    liveRms       = 0;
    countdown     = 3;
    errorMsg      = '';
    waveform      = [];
    result        = null;
    notifyListeners();
  }

  void resetAll() {
    resetSession();
    firstName = ''; lastName = ''; age = null;
    gender = 'Male'; notes = '';
    patientType  = PatientType.adult;
    testType     = TestType.amr;
    inputMode    = InputMode.manual;
    targetSecs   = 10.0;
    isEmergency  = false;
    notifyListeners();
  }

  // ── Start with countdown 3-2-1 ───────────────────────────────────────────────
  Future<void> start() async {
    if (!canStart) return;
    resetSession();
    sessionState = SessionState.countdown;
    countdown    = 3;
    notifyListeners();

    _cdTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      countdown--;
      notifyListeners();
      if (countdown <= 0) {
        t.cancel();
        await _beginRecording();
      }
    });
  }

  // ── Actual recording start ────────────────────────────────────────────────────
  Future<void> _beginRecording() async {
    if (inputMode == InputMode.auto) {
      // Check permission first
      if (!await _engine.hasPermission()) {
        if (!await _engine.requestPermission()) {
          sessionState = SessionState.error;
          errorMsg = 'Microphone permission denied.\nPlease enable it in device Settings → Apps → DDKinetics → Permissions.';
          notifyListeners();
          return;
        }
      }

      final ok = await _engine.startStream(
        // ── onFrame: fires ~every 10 ms ──────────────────────────────────────
        // Raw RMS value from the 160-sample PCM frame.
        // Used only for waveform display — does NOT affect syllable count.
        onFrame: (rms) {
          liveRms = rms;
          waveform = [...waveform, rms];
          if (waveform.length > 400) {
            waveform = waveform.sublist(waveform.length - 400);
          }
          notifyListeners();
        },
        // ── onSyllable: fires when refractory window clears ──────────────────
        // The engine has already applied the 130 ms refractory window.
        // This is the live syllable count update.
        onSyllable: (count) {
          syllableCount = count;
          notifyListeners();
        },
      );

      if (!ok) {
        sessionState = SessionState.error;
        errorMsg = 'Could not open microphone. Check permissions and try again.';
        notifyListeners();
        return;
      }
    }

    sessionState = SessionState.recording;
    notifyListeners();

    // Elapsed ticker — 100 ms resolution for smooth display
    _elTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      elapsedSecs = (elapsedSecs + 0.1).clamp(0, targetSecs + 0.1);
      notifyListeners();
    });

    // Auto-stop at target duration
    _stopTimer = Timer(Duration(seconds: targetSecs.round()), stop);
  }

  // ── Manual tap ────────────────────────────────────────────────────────────────
  void tap() {
    if (sessionState != SessionState.recording) return;
    syllableCount++;
    notifyListeners();
  }

  // ── Stop + finalise ───────────────────────────────────────────────────────────
  Future<void> stop() async {
    if (sessionState != SessionState.recording) return;
    _cancelTimers();
    final dur = elapsedSecs > 0.1 ? elapsedSecs : targetSecs;

    double rhythmSD    = 0;
    String rhythmLabel = '';
    double ampPct      = (liveRms * 100).clamp(0, 100);

    if (inputMode == InputMode.auto) {
      sessionState = SessionState.processing;
      notifyListeners();

      final res = await _engine.stopStream();

      if (res.syllableCount == 0) {
        sessionState = SessionState.error;
        errorMsg = 'No speech detected.\nPlease speak clearly into the microphone and try again.';
        notifyListeners();
        return;
      }

      syllableCount = res.syllableCount;
      ampPct        = (res.meanRms * 100).clamp(0, 100);
      rhythmSD      = res.ioisd;
      rhythmLabel   = res.rhythmLabel;
      if (res.envelope.isNotEmpty) waveform = res.envelope;
    }

    final rate = dur > 0 ? syllableCount / dur : 0.0;
    final ddkResult = DDKNorms.interpret(
      rate: rate,
      patientType: patientType,
      testType: testType,
    );

    final model = AssessmentModel(
      firstName:      isEmergency ? null : firstName.trim().isEmpty ? null : firstName.trim(),
      lastName:       isEmergency ? null : lastName.trim().isEmpty  ? null : lastName.trim(),
      age:            isEmergency ? null : age,
      gender:         isEmergency ? null : gender,
      clinicalNotes:  isEmergency ? null : notes.trim().isEmpty ? null : notes.trim(),
      patientType:    patientType,
      testType:       testType,
      inputMode:      inputMode,
      duration:       double.parse(dur.toStringAsFixed(2)),
      totalSyllables: syllableCount,
      rate:           double.parse(rate.toStringAsFixed(3)),
      amplitudePct:   double.parse(ampPct.toStringAsFixed(1)),
      result:         ddkResult,
      isEmergency:    isEmergency,
      rhythmSD:       rhythmSD,
      rhythmLabel:    rhythmLabel.isEmpty ? null : rhythmLabel,
    );

    await _store.save(model);
    result       = model;
    elapsedSecs  = dur;
    sessionState = SessionState.done;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  void _cancelTimers() {
    _cdTimer?.cancel();
    _elTimer?.cancel();
    _stopTimer?.cancel();
    _cdTimer = _elTimer = _stopTimer = null;
  }

  @override
  void dispose() {
    _cancelTimers();
    _engine.dispose();
    super.dispose();
  }
}
