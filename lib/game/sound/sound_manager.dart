import 'package:flame_audio/flame_audio.dart';

class SoundManager {
  static int _lastHitMs = 0;
  static int _lastSkillMs = 0;
  static bool _initialized = false;
  static AudioPool? _hitPool;
  static AudioPool? _skillPool;

  static Future<void> init() async {
    if (_initialized) return;
    FlameAudio.audioCache.prefix = 'assets/';
    _hitPool = await AudioPool.createFromAsset(
      path: 'audio/hit.wav',
      maxPlayers: 4,
      audioCache: FlameAudio.audioCache,
    );
    _skillPool = await AudioPool.createFromAsset(
      path: 'audio/skill.wav',
      maxPlayers: 3,
      audioCache: FlameAudio.audioCache,
    );
    _initialized = true;
  }

  static void playHit() {
    _playThrottled(minIntervalMs: 80, pool: _hitPool, lastRef: _LastRef.hit);
  }

  static void playSkill() {
    _playThrottled(minIntervalMs: 140, pool: _skillPool, lastRef: _LastRef.skill);
  }

  static void _playThrottled({
    required int minIntervalMs,
    required AudioPool? pool,
    required _LastRef lastRef,
  }) {
    if (pool == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (lastRef == _LastRef.hit) {
      if (now - _lastHitMs < minIntervalMs) return;
      _lastHitMs = now;
    } else {
      if (now - _lastSkillMs < minIntervalMs) return;
      _lastSkillMs = now;
    }
    pool.start();
  }
}

enum _LastRef { hit, skill }
