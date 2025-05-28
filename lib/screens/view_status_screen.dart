import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewStatusScreen extends StatefulWidget {
  final List<Map<String, dynamic>> statuses;
  final void Function(String statusId)? onStatusDeleted;
  final String currentUserId;

  const ViewStatusScreen({
    super.key,
    required this.statuses,
    required this.onStatusDeleted,
    required this.currentUserId,
  });

  @override
  State<ViewStatusScreen> createState() => _ViewStatusScreenState();
}

class _ViewStatusScreenState extends State<ViewStatusScreen> with TickerProviderStateMixin {
  int currentIndex = 0;
  VideoPlayerController? _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isVideoPlaying = false;
  bool isAudioPlaying = false;
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _setupMedia();
  }

  void _setupMedia() {
    _disposeMedia();
    setState(() => isLoading = true);

    final current = widget.statuses[currentIndex];
    final mediaType = current['mediaType'];
    final mediaUrl = current['mediaUrl'];

    if (mediaType == 'video' && mediaUrl != null) {
      _videoController = VideoPlayerController.network(mediaUrl)
        ..initialize().then((_) {
          setState(() {
            isVideoPlaying = true;
            _videoController!.play();
            isLoading = false;
          });
        });
    } else if (mediaType == 'audio' && mediaUrl != null) {
      _audioPlayer.play(UrlSource(mediaUrl));
      _audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          isAudioPlaying = (state == PlayerState.playing);
          isLoading = false;
        });
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _disposeMedia() {
    _videoController?.dispose();
    _videoController = null;
    _audioPlayer.stop();
  }

  @override
  void dispose() {
    _disposeMedia();
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleVideoPlayback() {
    if (_videoController != null) {
      if (isVideoPlaying) {
        _videoController?.pause();
      } else {
        _videoController?.play();
      }
      setState(() {
        isVideoPlaying = !isVideoPlaying;
      });
    }
  }

  void _toggleAudioPlayback() {
    if (isAudioPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
    setState(() {
      isAudioPlaying = !isAudioPlaying;
    });
  }

  Future<void> _deleteCurrentStatus() async {
    try {
      final current = widget.statuses[currentIndex];
      final docId = current['docId'];

      if (docId != null) {
        await FirebaseFirestore.instance.collection('statuses').doc(docId).delete();

        if (widget.onStatusDeleted != null) {
          widget.onStatusDeleted!(docId); // ✅ Pass docId to callback
        }

        setState(() {
          widget.statuses.removeAt(currentIndex);
          if (currentIndex >= widget.statuses.length && currentIndex > 0) {
            currentIndex--;
          }
        });

        if (widget.statuses.isNotEmpty) {
          _setupMedia();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Error deleting status: $e");
    }
  }

  void _onSwipe(DragEndDetails details) {
    if (details.primaryVelocity! < 0 && currentIndex < widget.statuses.length - 1) {
      setState(() => currentIndex++);
      _setupMedia();
    } else if (details.primaryVelocity! > 0 && currentIndex > 0) {
      setState(() => currentIndex--);
      _setupMedia();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.statuses.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("No more statuses", style: TextStyle(color: Colors.white))),
      );
    }

    final current = widget.statuses[currentIndex];
    final hasText = current['text'] != null && current['text'].toString().isNotEmpty;
    final bool isCurrentUserStatus = current['userId'] == widget.currentUserId;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: _onSwipe,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: Container(
                  color: Colors.black,
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      if (isLoading)
                        const Center(child: CircularProgressIndicator(color: Colors.white))
                      else if (current['mediaUrl'] != null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: current['mediaType'] == "image"
                                  ? Image.network(
                                      current['mediaUrl'],
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                    )
                                  : current['mediaType'] == "video" &&
                                          _videoController != null &&
                                          _videoController!.value.isInitialized
                                      ? AspectRatio(
                                          aspectRatio: _videoController!.value.aspectRatio,
                                          child: VideoPlayer(_videoController!),
                                        )
                                      : current['mediaType'] == "audio"
                                          ? Column(
                                              children: [
                                                const Icon(Icons.audiotrack, size: 80, color: Colors.blueAccent),
                                                IconButton(
                                                  icon: Icon(
                                                    isAudioPlaying ? Icons.pause : Icons.play_arrow,
                                                    size: 40,
                                                    color: Colors.blueAccent,
                                                  ),
                                                  onPressed: _toggleAudioPlayback,
                                                ),
                                              ],
                                            )
                                          : const Text("Unsupported media type", style: TextStyle(color: Colors.white)),
                            ),
                            if (current['mediaType'] == "video" && _videoController != null)
                              IconButton(
                                icon: Icon(
                                  isVideoPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 40,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: _toggleVideoPlayback,
                              ),
                            if (hasText)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  current['text'],
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        )
                      else if (hasText)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              current['text'],
                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      Positioned(
                        top: 20,
                        left: 16,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      if (isCurrentUserStatus)
                        Positioned(
                          bottom: 24,
                          child: FloatingActionButton(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            onPressed: _deleteCurrentStatus,
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
