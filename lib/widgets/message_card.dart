import 'package:flutter/material.dart';
import '../../models/message.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final String currentUserId;

  const MessageCard({super.key, required this.message, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: _getMessageWidget(message, isMe),
      ),
    );
  }

  Widget _getMessageWidget(Message message, bool isMe) {
    switch (message.type) {
      case MessageType.text:
        return _TextMessage(content: message.content, isMe: isMe);
      case MessageType.image:
        return _ImageMessage(content: message.content);
      case MessageType.video:
        return _VideoMessage(content: message.content);
      case MessageType.audio:
        return _AudioMessage(content: message.content);
      case MessageType.file:
        return _FileMessage(content: message.content);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TextMessage extends StatelessWidget {
  final String content;
  final bool isMe;

  const _TextMessage({required this.content, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? Colors.blueAccent : Colors.grey.shade300,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
          bottomRight: isMe ? Radius.zero : const Radius.circular(12),
        ),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 16,
          color: isMe ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class _ImageMessage extends StatelessWidget {
  final String content;

  const _ImageMessage({required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement full screen image viewer
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          content,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 200,
              height: 200,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: 200,
            height: 200,
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 50),
          ),
        ),
      ),
    );
  }
}

class _VideoMessage extends StatelessWidget {
  final String content;

  const _VideoMessage({required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement video player screen
      },
      child: Container(
        width: 200,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.play_circle_fill, size: 50, color: Colors.blue),
      ),
    );
  }
}

class _AudioMessage extends StatelessWidget {
  final String content;

  const _AudioMessage({required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement audio playback
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.volume_up, size: 30, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "Audio Message",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileMessage extends StatelessWidget {
  final String content;

  const _FileMessage({required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Open or download file
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.file_present, size: 30, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "File Message",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
