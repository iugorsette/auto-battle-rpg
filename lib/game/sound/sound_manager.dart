import 'package:flame_audio/flame_audio.dart';

class SoundManager {
  static bool _initialized = false;
  static Future<void>? _initFuture;
  static final Map<_Sfx, AudioPool> _pools = {};
  static final Map<_Sfx, int> _lastPlayMs = {};
  static _MusicTrack? _currentMusic;
  static double _musicVolume = 0.6;
  static double _sfxVolume = 0.9;
  static bool _muted = false;

  static const List<_PoolConfig> _poolConfigs = [
    _PoolConfig(_Sfx.hit, 'audio/hit.wav', 6),
    _PoolConfig(_Sfx.skill, 'audio/skill.wav', 4),
    _PoolConfig(_Sfx.click, 'audio/click-button.mp3', 3),
    _PoolConfig(_Sfx.gameOver, 'audio/game-over.mp3', 1),
    _PoolConfig(_Sfx.swordAttack, 'audio/combo/sword-attack.mp3', 5),
    _PoolConfig(_Sfx.swordSkill, 'audio/combo/sword-attack-skill.mp3', 4),
    _PoolConfig(_Sfx.superComboSword, 'audio/combo/super-combo-sword.mp3', 3),
    _PoolConfig(_Sfx.arrow, 'audio/combo/arrow.mp3', 6),
    _PoolConfig(_Sfx.fireBall, 'audio/combo/fire-ball.mp3', 4),
    _PoolConfig(_Sfx.frozenIce, 'audio/combo/frozen-ice.mp3', 4),
    _PoolConfig(_Sfx.igniteFire, 'audio/combo/ignite-fire.mp3', 4),
    _PoolConfig(_Sfx.ignite, 'audio/combo/ignite.mp3', 4),
    _PoolConfig(_Sfx.voidMagic, 'audio/combo/void-magic.mp3', 4),
    _PoolConfig(_Sfx.warScream, 'audio/combo/war-scream.mp3', 3),
    _PoolConfig(_Sfx.witchSpell, 'audio/combo/witch-spell.mp3', 3),
    _PoolConfig(_Sfx.orcAttack, 'audio/combo/orc-attack.mp3', 4),
    _PoolConfig(_Sfx.goblinGrowl, 'audio/combo/goblin-growl.mp3', 4),
    _PoolConfig(_Sfx.healSpell, 'audio/combo/heal-spell.mp3', 3),
  ];

  static Future<void> init() {
    if (_initialized) return Future.value();
    if (_initFuture != null) return _initFuture!;
    _initFuture = _initInternal();
    return _initFuture!;
  }

  static Future<void> _initInternal() async {
    FlameAudio.audioCache.prefix = 'assets/';
    await FlameAudio.bgm.initialize();
    for (final config in _poolConfigs) {
      _pools[config.sfx] = await AudioPool.createFromAsset(
        path: config.assetPath,
        maxPlayers: config.maxPlayers,
        audioCache: FlameAudio.audioCache,
      );
    }
    _initialized = true;
  }

  static double get musicVolume => _musicVolume;
  static double get sfxVolume => _sfxVolume;
  static bool get muted => _muted;

  static Future<void> setMusicVolume(double value) async {
    _musicVolume = value.clamp(0.0, 1.0);
    if (_muted) return;
    if (_currentMusic == null) return;
    await FlameAudio.bgm.audioPlayer.setVolume(_musicVolume);
  }

  static void setSfxVolume(double value) {
    _sfxVolume = value.clamp(0.0, 1.0);
  }

  static Future<void> setMuted(bool value) async {
    if (_muted == value) return;
    _muted = value;
    if (_muted) {
      await FlameAudio.bgm.pause();
      return;
    }
    if (_currentMusic != null) {
      await FlameAudio.bgm.play(
        _currentMusic!.assetPath,
        volume: _musicVolume,
      );
    }
  }

  static Future<void> playIntro() async {
    await init();
    await _playMusic(_MusicTrack.intro);
  }

  static Future<void> stopMusic() async {
    _currentMusic = null;
    if (!_initialized) return;
    await FlameAudio.bgm.stop();
  }

  static void playHit() {
    _play(_Sfx.hit, minIntervalMs: 80);
  }

  static void playSkill() {
    _play(_Sfx.skill, minIntervalMs: 140);
  }

  static void playClick() {
    _play(_Sfx.click, minIntervalMs: 120);
  }

  static void playGameOver() {
    _play(_Sfx.gameOver, minIntervalMs: 1200);
  }

  static void playSwordAttack() {
    _play(_Sfx.swordAttack, minIntervalMs: 90);
  }

  static void playSwordSkill() {
    _play(_Sfx.swordSkill, minIntervalMs: 140);
  }

  static void playSuperComboSword() {
    _play(_Sfx.superComboSword, minIntervalMs: 220);
  }

  static void playArrow() {
    _play(_Sfx.arrow, minIntervalMs: 70);
  }

  static void playFireBall() {
    _play(_Sfx.fireBall, minIntervalMs: 140);
  }

  static void playFrozenIce() {
    _play(_Sfx.frozenIce, minIntervalMs: 140);
  }

  static void playIgniteFire() {
    _play(_Sfx.igniteFire, minIntervalMs: 140);
  }

  static void playIgnite() {
    _play(_Sfx.ignite, minIntervalMs: 140);
  }

  static void playVoidMagic() {
    _play(_Sfx.voidMagic, minIntervalMs: 140);
  }

  static void playWarScream() {
    _play(_Sfx.warScream, minIntervalMs: 200);
  }

  static void playWitchSpell() {
    _play(_Sfx.witchSpell, minIntervalMs: 160);
  }

  static void playOrcAttack() {
    _play(_Sfx.orcAttack, minIntervalMs: 120);
  }

  static void playGoblinGrowl() {
    _play(_Sfx.goblinGrowl, minIntervalMs: 140);
  }

  static void playHealSpell() {
    _play(_Sfx.healSpell, minIntervalMs: 160);
  }

  static void _play(
    _Sfx sfx, {
    required int minIntervalMs,
  }) {
    if (!_initialized) return;
    final pool = _pools[sfx];
    if (pool == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _lastPlayMs[sfx] ?? 0;
    if (now - last < minIntervalMs) return;
    _lastPlayMs[sfx] = now;
    final volume = _muted ? 0.0 : _sfxVolume;
    if (volume <= 0) return;
    pool.start(volume: volume);
  }

  static Future<void> _playMusic(_MusicTrack track) async {
    if (!_initialized) return;
    if (_currentMusic == track && FlameAudio.bgm.isPlaying) return;
    _currentMusic = track;
    if (_muted) return;
    await FlameAudio.bgm.play(track.assetPath, volume: _musicVolume);
  }
}

enum _Sfx {
  hit,
  skill,
  click,
  gameOver,
  swordAttack,
  swordSkill,
  superComboSword,
  arrow,
  fireBall,
  frozenIce,
  igniteFire,
  ignite,
  voidMagic,
  warScream,
  witchSpell,
  orcAttack,
  goblinGrowl,
  healSpell,
}

enum _MusicTrack {
  intro('audio/intro.mp3');

  final String assetPath;

  const _MusicTrack(this.assetPath);
}

class _PoolConfig {
  final _Sfx sfx;
  final String assetPath;
  final int maxPlayers;

  const _PoolConfig(this.sfx, this.assetPath, this.maxPlayers);
}
