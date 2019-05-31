import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import 'blurOverlay.dart';
import 'nonNegativeTween.dart';

enum PlayerState { stopped, playing, paused }

class PlaybackButton extends StatefulWidget {
  const PlaybackButton(
      {@required this.url,
      this.isLocal = false,
      this.mode = PlayerMode.MEDIA_PLAYER,
      @required this.isBlurred});

  final String url;
  final bool isLocal;
  final PlayerMode mode;
  final bool isBlurred;

  @override
  _PlaybackButtonState createState() => _PlaybackButtonState();
}

class _PlaybackButtonState extends State<PlaybackButton>
    with TickerProviderStateMixin {
  AudioPlayer _audioPlayer;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription<Duration> _durationSubscription;
  StreamSubscription<Duration> _positionSubscription;
  StreamSubscription<void> _playerCompleteSubscription;
  StreamSubscription<String> _playerErrorSubscription;

  AnimationController _playController;
  Animation<double> _playAnim;
  AnimationController _scaleController;
  Animation<double> _scale;

  bool get _isPlaying => _playerState == PlayerState.playing;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _playController = AnimationController(
        vsync: this, duration: Constants.durationAnimationShort);
    _playAnim =
        CurvedAnimation(parent: _playController, curve: Curves.easeInOut);
    _playController.value = 0.0;
    _scaleController = AnimationController(
        duration: Constants.durationAnimationMedium +
            Constants.durationAnimationRoute,
        vsync: this);
    _scale = NonNegativeTween<double>(begin: animationStart, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut));
    _scaleController.forward();
  }

  double get animationStart =>
      0 -
      (Constants.durationAnimationRoute.inMilliseconds /
          Constants.durationAnimationMedium.inMilliseconds);

  @override
  void dispose() {
    _audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double playbackProportion = _position != null && _duration != null
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;
    final Color color = Theme.of(context).colorScheme.onPrimary;
    return ScaleTransition(
        scale: _scale,
        child: Material(
          color: Colors.transparent,
          elevation: 16.0,
          child: BlurOverlay.roundedRect(
            radius: 80,
            enabled: widget.isBlurred,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: widget.isBlurred
                          ? <Color>[
                              Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withAlpha(150),
                              Theme.of(context).primaryColor.withAlpha(150)
                            ]
                          : <Color>[
                              Theme.of(context).colorScheme.error,
                              Theme.of(context).primaryColor
                            ],
                      stops: <double>[
                    -0.1 + playbackProportion,
                    0.1 + playbackProportion
                  ])),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      child: Center(
                          child: _playerState == PlayerState.stopped
                              ? Icon(
                                  playbackProportion == 0.0
                                      ? Icons.play_arrow
                                      : Icons.refresh,
                                  color: color)
                              : playbackProportion == 0.0
                                  ? Container(
                                      height: 28,
                                      width: 28,
                                      child: Theme(
                                          data: Theme.of(context).copyWith(
                                              accentColor: color),
                                          child: const CircularProgressIndicator()))
                                  : AnimatedIcon(
                                      icon: AnimatedIcons.play_pause,
                                      progress: _playAnim,
                                      color: color)),
                      onTap: _isPlaying ? _pause : _play,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AbsorbPointer(child: Container(height: 15)),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          height: 15,
                          child: SliderTheme(
                            data: Theme.of(context).sliderTheme.copyWith(
                                trackHeight: 15.0,
                                activeTrackColor: Colors.transparent,
                                inactiveTrackColor: Colors.transparent,
                                thumbColor: color),
                            child: Slider(
                              max: _duration?.inMilliseconds?.toDouble() ?? 1.0,
                              value: (_position != null &&
                                      _duration != null &&
                                      _position.inMilliseconds > 0 &&
                                      _position.inMilliseconds <
                                          _duration.inMilliseconds)
                                  ? _position.inMilliseconds.toDouble()
                                  : 0.0,
                              onChanged: (double value) => _audioPlayer
                                  .seek(Duration(milliseconds: value.round())),
                            ),
                          ))),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void deactivate() {
    _audioPlayer.stop();
    super.deactivate();
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: widget.mode);

    _durationSubscription = _audioPlayer.onDurationChanged
        .listen((Duration duration) => setState(() {
              _duration = duration;
            }));

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((Duration p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription = _audioPlayer.onPlayerCompletion.listen((_) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((String msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });
  }

  Future<int> _play() async {
    HapticFeedback.selectionClick();
    final Duration playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    _playController.forward();
    final int result = await _audioPlayer.play(widget.url,
        isLocal: widget.isLocal, position: playPosition);
    if (result == 1)
      setState(() => _playerState = PlayerState.playing);
    return result;
  }

  Future<int> _pause() async {
    HapticFeedback.selectionClick();
    _playController.reverse();
    final int result = await _audioPlayer.pause();
    if (result == 1)
      setState(() => _playerState = PlayerState.paused);
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}
