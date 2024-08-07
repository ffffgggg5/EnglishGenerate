import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audio_play.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const DetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.PLAYING;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          totalDuration = newDuration;
        });
      }
    });

    _audioPlayer.onAudioPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          currentPosition = newPosition;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play(widget.item['audioPath'], isLocal: true);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                Text(
                  'テーマ: ${widget.item['theme'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '語数: ${widget.item['length'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'レベル: ${widget.item['level'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'スタイル: ${widget.item['style'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SelectableText(
                      widget.item['englishText'] ?? 'N/A',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    SelectableText(
                      widget.item['japaneseText'] ?? 'N/A',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            AudioPlayerWidget(audioFilePath: widget.item['audioPath']),
          ],
        ),
      ),
    );
  }
}
