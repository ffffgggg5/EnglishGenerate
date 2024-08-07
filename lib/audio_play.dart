import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioFilePath;

  const AudioPlayerWidget({Key? key, required this.audioFilePath})
      : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with SingleTickerProviderStateMixin {
  final AudioPlayer audioPlayer = AudioPlayer();
  double playbackSpeed = 1.0;
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  late AnimationController _controller;
  bool isFirstPlay = true;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100))
          ..addListener(() {
            setState(() {});
          });
  }

  void _setupAudioPlayer() {
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        totalDuration = newDuration;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        currentPosition = newPosition;
        _controller.value = currentPosition.inSeconds / totalDuration.inSeconds;
      });
    });
  }

  void _togglePlayPause() {
    if (isPlaying) {
      audioPlayer.pause();
    } else {
      if (isFirstPlay) {
        audioPlayer.play(widget.audioFilePath, isLocal: true);
        isFirstPlay = false;
      } else {
        audioPlayer.resume();
      }
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  Future<void> _seekForward() async {
    int newPosition = currentPosition.inMilliseconds + 3000;
    audioPlayer.seek(Duration(milliseconds: newPosition));
  }

  Future<void> _seekBackward() async {
    int newPosition = currentPosition.inMilliseconds - 3000;
    audioPlayer.seek(Duration(milliseconds: newPosition));
  }

  void _reset() {
    audioPlayer.seek(Duration.zero);
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      playbackSpeed = speed;
      audioPlayer.setPlaybackRate(playbackSpeed);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Slider(
              value: currentPosition.inSeconds.toDouble(),
              max: totalDuration.inSeconds.toDouble(),
              onChanged: (value) {
                final newPosition = Duration(seconds: value.toInt());
                audioPlayer.seek(newPosition);
              },
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(currentPosition)),
            Text(_formatDuration(totalDuration)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.skip_previous),
              onPressed: _reset,
            ),
            IconButton(
              icon: Icon(Icons.replay_10),
              onPressed: _seekBackward,
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _togglePlayPause,
            ),
            IconButton(
              icon: Icon(Icons.forward_10),
              onPressed: _seekForward,
            ),
            DropdownButton<double>(
              value: playbackSpeed,
              items: [0.5, 1.0, 1.5, 2.0].map((double value) {
                return DropdownMenuItem<double>(
                  value: value,
                  child: Text("${value}x"),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _setPlaybackSpeed(value);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }
}
