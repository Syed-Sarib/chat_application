import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const AudioMessagePlayer({
    Key? key,
    required this.audioUrl,
    required this.isMe,
  }) : super(key: key);

  @override
  _AudioMessagePlayerState createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);
      
      _audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          setState(() {
            _duration = duration;
            _isLoading = false;
          });
        }
      });

      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() => _position = position);
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
        
        if (state.processingState == ProcessingState.completed) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _position = Duration.zero;
            });
          }
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.pause();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading audio: $e')),
      );
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isMe ? Colors.white : Colors.black;
    
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: widget.isMe ? Colors.blueAccent : Colors.grey[300],
      ),
      child: _isLoading
          ? Center(child: CircularProgressIndicator(color: color))
          : Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: color,
                  ),
                  onPressed: _togglePlayPause,
                ),
                Expanded(
                  child: ProgressBar(
                    progress: _position,
                    total: _duration,
                    onSeek: (duration) {
                      _audioPlayer.seek(duration);
                    },
                    progressBarColor: color,
                    baseBarColor: color.withOpacity(0.24),
                    bufferedBarColor: color.withOpacity(0.24),
                    thumbColor: color,
                    barHeight: 3,
                    thumbRadius: 6,
                    timeLabelLocation: TimeLabelLocation.none, // Remove seconds display
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}