library mb_noise_meter;

import 'dart:core';
import 'dart:math';

import 'package:mb_audio_streamer/mb_audio_streamer.dart';

/// Holds a decibel value for a noise level reading.
class MBNoiseReading {
  late double _meanDecibel, _maxDecibel;

  MBNoiseReading(List<double> volumes) {
    // sort volumes such that the last element is max amplitude
    volumes.sort();

    // compute average peak-amplitude using the min and max amplitude
    double min = volumes.first;
    double max = volumes.last;
    double mean = 0.5 * (min.abs() + max.abs());

    // max amplitude is 2^15
    double maxAmp = pow(2, 15) + 0.0;

    _maxDecibel = 20 * log(maxAmp * max) * log10e;
    _meanDecibel = 20 * log(maxAmp * mean) * log10e;
  }

  /// Maximum measured decibel reading.
  double get maxDecibel => _maxDecibel;

  /// Mean decibel across readings.
  double get meanDecibel => _meanDecibel;

  @override
  String toString() =>
      '$runtimeType - mean (dB): $meanDecibel, max (dB): $maxDecibel';
}

/// A [MBNoiseMeter] provides continuous access to noise reading via the [noise]
/// stream.
class MBNoiseMeter {
  Stream<MBNoiseReading>? _stream;

  /// Create a [MBNoiseMeter].
  MBNoiseMeter();

  /// The actual sampling rate.
  Future<int> get sampleRate => MBAudioStreamer().actualSampleRate;

  /// The stream of noise readings.
  ///
  /// Remember to obtain permission to use the microphone **BEFORE**
  /// using this stream.
  Stream<MBNoiseReading> get noise => _stream ??=
      MBAudioStreamer().audioStream.map((buffer) => MBNoiseReading(buffer));
}
