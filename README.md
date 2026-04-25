# DDKinetics v3
### Professional Diadochokinesis (DDK) Assessment App for Speech-Language Pathologists
**Built from scratch with production PCM/RMS/refractory audio engine**

---

## Quick Start

```bash
cd ddkinetics_v3
flutter pub get
flutter run                   # debug on connected device
flutter build apk --release   # release APK
```

---

## Architecture

```
lib/
├── main.dart                          Entry point, providers, theme init
│
├── theme/
│   └── app_theme.dart                 Dark clinical design system
│
├── models/
│   ├── models.dart                    Enums, DDKNorms, AssessmentModel
│   └── models.g.dart                  Hand-written Hive adapters (no build_runner)
│
├── services/
│   ├── audio_engine.dart              ★ Core PCM/RMS/refractory engine
│   └── storage_service.dart           Hive CRUD
│
├── providers/
│   ├── assessment_provider.dart       Session state machine (MVVM)
│   └── history_provider.dart          History + filter state
│
├── widgets/
│   └── widgets.dart                   TestChip, ResultBadge, MetricTile,
│                                      PillToggle, WaveformPainter, SectionLabel
│
└── screens/
    ├── home/
    │   └── home_screen.dart           Dashboard, emergency btn, nav grid, stats
    ├── assessment/
    │   ├── patient_info_screen.dart   Step 1: patient form
    │   ├── test_config_screen.dart    Step 2: type/mode/duration
    │   ├── emergency_screen.dart      Immediate start, no patient info
    │   ├── recording_screen.dart      Live recording + tap/waveform UI
    │   └── result_screen.dart         Metrics, norm comparison, rhythm, interpretation
    ├── history/
    │   └── history_screen.dart        Filtered list, swipe-to-delete
    └── help/
        └── help_screen.dart           DDK reference, norms table, clinical tips
```

---

## Audio Engine — Technical Detail

**File:** `lib/services/audio_engine.dart`

### Pipeline

```
Microphone
  └─ record.startStream()                    Raw PCM16-LE stream
       └─ _decodePCM16(bytes)                2 bytes → signed int16
            └─ chunk into 160-sample frames  160 samples @ 16kHz = 10ms/frame
                 └─ _rms(frame)              normalize to [-1,1] → √(mean(x²))
                      │
                      ├─ onFrame(rms)        → waveform display (~every 10ms)
                      │
                      └─ if rms ≥ 0.08:
                           if Δt ≥ 130ms:   refractory window check
                             syllableCount++
                             HapticFeedback.lightImpact()
                             onSyllable(count)
                           else: ignore      ← vowel tail suppression
```

### Constants

| Constant | Value | Rationale |
|---|---|---|
| `kSampleRate` | 16,000 Hz | Sufficient for /p/ /t/ /k/ bursts; minimises data |
| `kFrameSamples` | 160 | 160 ÷ 16000 = exactly 10 ms per frame |
| `kDefaultSensitivity` | 0.08 | Empirical sweet spot at 20–30 cm mic distance |
| `kRefractoryMs` | 130 ms | Clears plosive burst + vowel phase (50–80 ms); safe below max DDK gap (~111 ms at 9/sec) |

### Rhythm Regularity (IOI SD)

After recording, the engine computes the standard deviation of inter-onset intervals:

| IOI SD | Label | Clinical meaning |
|---|---|---|
| < 20 ms | Regular | Intact motor timing circuitry |
| 20–40 ms | Slightly Irregular | Monitor; may reflect fatigue |
| > 40 ms | Irregular | Significant timing variability — correlate clinically |

---

## DDK Norms

| Patient Type | Test | Normal | Borderline | Possible Dysarthria |
|---|---|---|---|---|
| **Adult** | AMR | ≥ 5.5/s | 4.5–5.5/s | < 4.5/s |
| **Adult** | SMR | ≥ 5.0/s | 4.0–5.0/s | < 4.0/s |
| **Child** | AMR | ≥ 4.5/s | 3.5–4.5/s | < 3.5/s |
| **Child** | SMR | ≥ 4.0/s | 3.0–4.0/s | < 3.0/s |
| **Geriatric** | AMR | ≥ 4.8/s | 3.8–4.8/s | < 3.8/s |
| **Geriatric** | SMR | ≥ 4.2/s | 3.2–4.2/s | < 3.2/s |

*Sources: Duffy (2013), Kent et al. (1987), Fletcher (1972)*

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.1 | MVVM state management |
| `hive` + `hive_flutter` | ^2.2.3 | Offline local storage |
| `record` | ^5.1.0 | `startStream()` for raw PCM16 |
| `permission_handler` | ^11.2.0 | Runtime mic permission |
| `google_fonts` | ^6.1.0 | Space Grotesk + Inter |
| `flutter_animate` | ^4.5.0 | Entrance animations |
| `gap` | ^3.0.1 | Spacing utility |
| `intl` | ^0.19.0 | Date formatting |
| `uuid` | ^4.3.3 | Unique assessment IDs |

---

## Android Requirements

- **minSdk:** 21 (Android 5.0+)
- **Kotlin:** 1.9.22
- **AGP:** 8.1.0
- **Gradle:** 8.3

---

## Known Limitations

- Auto mode accuracy is affected by room acoustics. Manual tap mode is recommended for noisy environments.
- iOS support requires entitlements in `Info.plist` (microphone usage description + background audio if needed).
- The sensitivity constant (0.08) may need calibration for very quiet or very loud speakers.

---

## References

- Duffy, J.R. (2013). *Motor Speech Disorders*. 3rd ed. Elsevier.
- Kent, R.D. et al. (1987). Maximum performance tests of speech production. *JSHD*, 52(4).
- Fletcher, S.G. (1972). Time-by-count measurement of DDK syllable rate. *JSR*, 15(4).
- Yorkston, K.M. et al. (2010). *Management of Motor Speech Disorders in Children and Adults*.

---

*DDKinetics v3 · Built for SLPs · Fully offline*
