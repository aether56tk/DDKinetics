import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

// ── Engine Constants ──────────────────────────────────────────────────────────

/// Sample rate for raw PCM stream.
/// 16 kHz captures the sharp /p/ /t/ /k/ bursts without excessive data.
const int kSampleRate = 16000;

/// PCM samples per processing frame.
/// 160 samples @ 16 kHz = exactly 10 ms per frame.
const int kFrameSamples = 160;

/// Default RMS sensitivity threshold (0.0–1.0).
/// 0.08 is empirically the sweet spot for DDK at 20–30 cm mic distance.
const double kDefaultSensitivity = 0.08;

/// Refractory period in milliseconds.
/// A single "pa" has a plosive burst + vowel phase (~50–80 ms apart).
/// 130 ms freezes the counter after each onset so the vowel tail is never
/// counted as a second syllable. Physiological max DDK ≈ 9/sec → min gap
/// ≈ 111 ms, so 130 ms also safely separates consecutive syllables.
const int kRefractoryMs = 130;

// ── Result type returned by stopStream() ─────────────────────────────────────

class AudioEngineResult {
  /// Syllable count as counted by the refractory-window detector.
  final int syllableCount;

  /// Mean RMS across the entire recording (0.0–1.0).
  final double meanRms;

  /// Downsampled RMS envelope (max 400 points) for waveform drawing.
  final List<double> envelope;

  /// Standard deviation of inter-onset intervals in milliseconds.
  /// 0.0 when there are fewer than 3 onsets (no meaningful calculation).
  final double ioisd;

  /// Rhythm label derived from IOI SD.
  final String rhythmLabel;

  const AudioEngineResult({
    required this.syllableCount,
    required this.meanRms,
    required this.envelope,
    required this.ioisd,
    required this.rhythmLabel,
  });

  static const AudioEngineResult empty = AudioEngineResult(
    syllableCount: 0,
    meanRms: 0,
    envelope: [],
    ioisd: 0,
    rhythmLabel: 'No audio',
  );
}

// ── AudioEngine ───────────────────────────────────────────────────────────────

class AudioEngine {
  AudioEngine({double sensitivity = kDefaultSensitivity})
      : _sensitivity = sensitivity;

  final double _sensitivity;
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _sub;
  bool _running = false;

  // Live counters — updated in real time
  int _syllableCount = 0;
  int _lastOnsetMs   = -9999;

  // Accumulated for final analysis
  final List<double> _rmsFrames   = [];   // one per 10ms frame
  final List<int>    _onsetTimes  = [];   // wall-clock ms per accepted onset
  List<int>          _carry       = [];   // partial frame carry-over

  bool get isRunning => _running;

  // ── Permission ───────────────────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    final s = await Permission.microphone.request();
    return s == PermissionStatus.granted;
  }
  Future<bool> hasPermission() async => Permission.microphone.isGranted;

  // ── startStream ──────────────────────────────────────────────────────────────
  /// Opens raw PCM stream and begins real-time syllable detection.
  ///
  /// [onFrame]     — called every ~10 ms with current frame RMS (0–1).
  ///                 Use this to drive the waveform painter.
  /// [onSyllable]  — called each time an onset clears the refractory window.
  ///                 Receives the cumulative syllable count.
  Future<bool> startStream({
    required void Function(double rms) onFrame,
    required void Function(int count) onSyllable,
  }) async {
    if (_running) return false;
    if (!await requestPermission()) return false;

    // Reset all state
    _syllableCount = 0;
    _lastOnsetMs   = -9999;
    _rmsFrames.clear();
    _onsetTimes.clear();
    _carry.clear();

    try {
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: kSampleRate,
          numChannels: 1,
        ),
      );

      _running = true;

      _sub = stream.listen((Uint8List raw) {
        if (!_running) return;

        // ── Convert bytes → signed int16 samples ──────────────────────────────
        // PCM16 LE: each sample is 2 bytes, little-endian, signed.
        final samples = _decodePCM16(raw);

        // Prepend carry-over from previous buffer
        final buf = [..._carry, ...samples];
        int offset = 0;

        while (offset + kFrameSamples <= buf.length) {
          final frame = buf.sublist(offset, offset + kFrameSamples);
          offset += kFrameSamples;

          // ── Step A: RMS ────────────────────────────────────────────────────
          // Normalize int16 → [-1,1] then compute sqrt(mean of squares).
          // This measures acoustic energy — stable even when raw signal is noisy.
          final rms = _rms(frame);
          _rmsFrames.add(rms);
          onFrame(rms);  // drive waveform

          // ── Step B: Onset detection + refractory window ────────────────────
          if (rms >= _sensitivity) {
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - _lastOnsetMs >= kRefractoryMs) {
              // Valid new syllable onset
              _syllableCount++;
              _lastOnsetMs = now;
              _onsetTimes.add(now);

              // Haptic pulse — clinician hears + feels every detected syllable.
              HapticFeedback.lightImpact();

              onSyllable(_syllableCount);
            }
            // else: inside refractory window — vowel tail of current syllable; ignore.
          }
        }

        // Keep leftover samples for the next buffer
        _carry = buf.sublist(offset);
      });

      return true;
    } catch (_) {
      _running = false;
      return false;
    }
  }

  // ── stopStream ───────────────────────────────────────────────────────────────
  /// Stops the stream and returns the final processed result.
  Future<AudioEngineResult> stopStream() async {
    if (!_running) return AudioEngineResult.empty;

    await _sub?.cancel();
    _sub = null;
    try { await _recorder.stop(); } catch (_) {}
    _running = false;

    if (_rmsFrames.isEmpty || _syllableCount == 0) {
      return AudioEngineResult.empty;
    }

    // Mean RMS → amplitude percentage (0–100)
    final mean = _rmsFrames.reduce((a, b) => a + b) / _rmsFrames.length;

    // Downsample RMS history → waveform envelope
    final env = _downsample(_rmsFrames, 400);

    // IOI SD for rhythm regularity
    final (sd, label) = _rhythmRegularity(_onsetTimes);

    return AudioEngineResult(
      syllableCount: _syllableCount,
      meanRms: mean,
      envelope: env,
      ioisd: sd,
      rhythmLabel: label,
    );
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    if (_running) try { await _recorder.stop(); } catch (_) {}
    await _recorder.dispose();
  }

  // ── Signal Processing ─────────────────────────────────────────────────────────

  /// Decode raw bytes from the PCM16-LE stream into a list of signed int16 values.
  List<int> _decodePCM16(Uint8List bytes) {
    final out = <int>[];
    for (int i = 0; i + 1 < bytes.length; i += 2) {
      int s = bytes[i] | (bytes[i + 1] << 8);
      if (s >= 0x8000) s -= 0x10000;  // sign-extend
      out.add(s);
    }
    return out;
  }

  /// Root Mean Square of a PCM16 frame.
  /// Each int16 is normalised to [-1.0, 1.0] by dividing by 32768.
  double _rms(List<int> frame) {
    if (frame.isEmpty) return 0.0;
    double sum = 0;
    for (final s in frame) {
      final n = s / 32768.0;
      sum += n * n;
    }
    return math.sqrt(sum / frame.length);
  }

  /// Downsample a list to at most [maxPts] points by averaging adjacent bins.
  List<double> _downsample(List<double> src, int maxPts) {
    if (src.length <= maxPts) return List.of(src);
    final binSize = src.length / maxPts;
    return List.generate(maxPts, (i) {
      final s = (i * binSize).floor();
      final e = ((i + 1) * binSize).ceil().clamp(0, src.length);
      final bin = src.sublist(s, e);
      return bin.reduce((a, b) => a + b) / bin.length;
    });
  }

  /// Computes standard deviation of inter-onset intervals (IOI) in ms and
  /// maps it to a rhythm label.
  ///
  /// Interpretation:
  ///   SD < 20 ms  → Regular         (intact motor timing)
  ///   20–40 ms    → Slightly Irregular
  ///   > 40 ms     → Irregular       (motor timing variability)
  (double sd, String label) _rhythmRegularity(List<int> onsets) {
    if (onsets.length < 3) return (0.0, 'Insufficient data');

    final iois = <double>[];
    for (int i = 1; i < onsets.length; i++) {
      iois.add((onsets[i] - onsets[i - 1]).toDouble());
    }

    final mean = iois.reduce((a, b) => a + b) / iois.length;
    final variance = iois.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / iois.length;
    final sd = math.sqrt(variance);

    final label = sd < 20 ? 'Regular' : sd < 40 ? 'Slightly Irregular' : 'Irregular';
    return (sd, label);
  }
}
