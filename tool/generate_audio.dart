import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  // 1. Pistol Shoot (Sharp crisp pop)
  _generateWav('assets/audio/pistol_shoot.wav', (t, duration) {
    final freq = 900.0 * exp(-t * 25.0);
    final tone = sin(2 * pi * freq * t);
    final noise = (Random().nextDouble() - 0.5) * exp(-t * 30.0);
    final env = exp(-t * 15.0);
    return (tone * 0.6 + noise * 0.4) * env;
  }, duration: 0.18);

  // 2. Shotgun Shoot (Heavy booming bass blast)
  _generateWav('assets/audio/shotgun_shoot.wav', (t, duration) {
    final freq = 220.0 * exp(-t * 10.0);
    final subBass = sin(2 * pi * freq * t);
    final noise = (Random().nextDouble() - 0.5) * exp(-t * 8.0);
    final env = exp(-t * 6.0);
    return (subBass * 0.5 + noise * 0.5) * env;
  }, duration: 0.45);

  // 3. Rifle Shoot (Rapid punchy metallic report)
  _generateWav('assets/audio/rifle_shoot.wav', (t, duration) {
    final freq = 600.0 * exp(-t * 35.0);
    final tone = sin(2 * pi * freq * t);
    final noise = (Random().nextDouble() - 0.5) * exp(-t * 40.0);
    final env = exp(-t * 22.0);
    return (tone * 0.7 + noise * 0.3) * env;
  }, duration: 0.12);

  // Fallback shoot.wav
  File('assets/audio/pistol_shoot.wav').copySync('assets/audio/shoot.wav');

  // 4. Reload (Double metallic click)
  _generateWav('assets/audio/reload.wav', (t, duration) {
    double click = 0.0;
    if (t > 0.02 && t < 0.06) {
      click += sin(2 * pi * 1200 * t) * exp(-(t - 0.02) * 80);
    }
    if (t > 0.15 && t < 0.19) {
      click += sin(2 * pi * 1500 * t) * exp(-(t - 0.15) * 80);
    }
    return click.clamp(-1.0, 1.0);
  }, duration: 0.25);

  // 5. Zombie Attack (Low growl)
  _generateWav('assets/audio/zombie_attack.wav', (t, duration) {
    final freq = 110.0 + sin(2 * pi * 8 * t) * 30.0;
    final noise = (Random().nextDouble() - 0.5) * 0.3;
    final env = sin(pi * t / duration);
    return (sin(2 * pi * freq * t) + noise) * env * 0.7;
  }, duration: 0.3);

  // 6. Zombie Death (Groan pitch drop)
  _generateWav('assets/audio/zombie_death.wav', (t, duration) {
    final freq = 200.0 * exp(-t * 5.0);
    final noise = (Random().nextDouble() - 0.5) * 0.2;
    final env = exp(-t * 4.0);
    return (sin(2 * pi * freq * t) + noise) * env * 0.8;
  }, duration: 0.35);

  // 7. Pickup (High chime)
  _generateWav('assets/audio/pickup.wav', (t, duration) {
    final freq = t < 0.1 ? 880.0 : 1320.0;
    final env = exp(-t * 12.0);
    return sin(2 * pi * freq * t) * env * 0.6;
  }, duration: 0.2);

  // 8. Level Up (Ascending fanfare)
  _generateWav('assets/audio/levelup.wav', (t, duration) {
    double freq = 523.25; // C5
    if (t > 0.15) freq = 659.25; // E5
    if (t > 0.30) freq = 783.99; // G5
    if (t > 0.45) freq = 1046.50; // C6
    final env = exp(-(t % 0.15) * 10.0);
    return sin(2 * pi * freq * t) * env * 0.7;
  }, duration: 0.6);

  // 9. Game Over (Descending sting)
  _generateWav('assets/audio/gameover.wav', (t, duration) {
    final freq = 300.0 * exp(-t * 2.0);
    final env = exp(-t * 2.0);
    return (sin(2 * pi * freq * t) + sin(2 * pi * (freq * 0.5) * t)) * env * 0.5;
  }, duration: 0.8);

  // 10. Dark Atmospheric Zombie Survival Background Music (10.0s seamless synth loop)
  _generateWav('assets/audio/bgm.wav', (t, duration) {
    final beat = (t / 0.5) % 8.0;

    // Deep Dark Pulsing Bass (A1 -> F1 -> C1 -> G1)
    double bassFreq = 55.0;
    if (beat >= 2.0 && beat < 4.0) bassFreq = 43.65;
    if (beat >= 4.0 && beat < 6.0) bassFreq = 32.70;
    if (beat >= 6.0) bassFreq = 49.0;

    final bass = sin(2 * pi * bassFreq * t) * 0.35 +
        sin(2 * pi * (bassFreq * 2) * t) * 0.15;

    // Atmospheric Arpeggio Synth Notes
    final arpStep = (t / 0.125).floor() % 8;
    final arpNotes = [220.0, 261.63, 329.63, 440.0, 329.63, 261.63, 220.0, 196.0];
    final arpFreq = arpNotes[arpStep];
    final arpEnv = exp(-((t / 0.125) % 1.0) * 10.0);
    final arp = sin(2 * pi * arpFreq * t) * arpEnv * 0.15;

    // Heartbeat Kick Drum
    final beatTime = t % 0.5;
    double kick = 0.0;
    if (beatTime < 0.08) {
      final kickFreq = 120.0 * exp(-beatTime * 40.0);
      kick = sin(2 * pi * kickFreq * beatTime) * exp(-beatTime * 20.0) * 0.4;
    }

    // Tension Drone Pad
    final pad = sin(2 * pi * (bassFreq * 1.5) * t) * 0.1;

    final mix = (bass + arp + kick + pad).clamp(-1.0, 1.0);
    return mix;
  }, duration: 10.0);

  // Copy bgm.wav as bgm.mp3 for fallback
  File('assets/audio/bgm.wav').copySync('assets/audio/bgm.mp3');
}

void _generateWav(String path, double Function(double t, double duration) synth, {double duration = 0.2, int sampleRate = 22050}) {
  final numSamples = (sampleRate * duration).toInt();
  final dataSize = numSamples * 2; // 16-bit mono
  final fileSize = 44 + dataSize;

  final buffer = Uint8List(fileSize);
  final bd = ByteData.view(buffer.buffer);

  // RIFF header
  buffer.setRange(0, 4, 'RIFF'.codeUnits);
  bd.setUint32(4, fileSize - 8, Endian.little);
  buffer.setRange(8, 12, 'WAVE'.codeUnits);

  // fmt subchunk
  buffer.setRange(12, 16, 'fmt '.codeUnits);
  bd.setUint32(16, 16, Endian.little); // Subchunk1Size
  bd.setUint16(20, 1, Endian.little); // PCM
  bd.setUint16(22, 1, Endian.little); // Mono
  bd.setUint32(24, sampleRate, Endian.little); // SampleRate
  bd.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
  bd.setUint16(32, 2, Endian.little); // BlockAlign
  bd.setUint16(34, 16, Endian.little); // BitsPerSample

  // data subchunk
  buffer.setRange(36, 40, 'data'.codeUnits);
  bd.setUint32(40, dataSize, Endian.little);

  // Generate PCM samples
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final sampleValue = synth(t, duration).clamp(-1.0, 1.0);
    final int16Value = (sampleValue * 32767).toInt().clamp(-32768, 32767);
    bd.setInt16(44 + i * 2, int16Value, Endian.little);
  }

  File(path).writeAsBytesSync(buffer);
}
