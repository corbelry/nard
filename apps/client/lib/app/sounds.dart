import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

enum Sfx {
  dice('dice'),
  checker('checker'),
  hit('hit'),
  bearOff('bear_off'),
  double('double');

  const Sfx(this.file);
  final String file;
}

/// Plays short effects from `assets/sounds/` when the sound setting is on.
/// Files that are not bundled yet are skipped silently.
class SoundService {
  SoundService(this._ref);

  final Ref _ref;
  final _players = <Sfx, AudioPlayer>{};
  final _available = <Sfx, bool>{};
  bool _contextSet = false;

  Future<bool> _exists(Sfx sfx) async {
    final known = _available[sfx];
    if (known != null) return known;
    try {
      await rootBundle.load('assets/sounds/${sfx.file}.ogg');
      return _available[sfx] = true;
    } on Object {
      return _available[sfx] = false;
    }
  }

  void play(Sfx sfx) {
    if (!_ref.read(currentSettingsProvider).sound) return;
    unawaited(_play(sfx));
  }

  Future<void> _play(Sfx sfx) async {
    if (!await _exists(sfx)) return;
    if (!_contextSet) {
      _contextSet = true;
      // Effects mix with the player's music instead of taking audio focus.
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build(),
      );
    }
    var player = _players[sfx];
    if (player == null) {
      player = _players[sfx] = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
    }
    await player.stop();
    await player.play(AssetSource('sounds/${sfx.file}.ogg'));
  }

  Future<void> dispose() async {
    for (final p in _players.values) {
      await p.dispose();
    }
  }
}

final soundProvider = Provider<SoundService>((ref) {
  final service = SoundService(ref);
  ref.onDispose(service.dispose);
  return service;
});
