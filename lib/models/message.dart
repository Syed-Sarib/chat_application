import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing the type of message
enum MessageType { text, image, video, audio, file }

/// Model class for chat messages
class Message {
  String id;
  String senderId;
  String content;
  MessageType type;
  DateTime timestamp;
  bool seen;
  bool delivered;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.seen = false,
    this.delivered = false,
  });

  /// Create a Message object from Firestore document data
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',  // Ensure 'id' exists
      senderId: json['senderId'] ?? '',  // Ensure 'senderId' exists
      content: json['content'] ?? '',  // Ensure 'content' exists
      type: _parseMessageType(json['type']),  // Enum parsing
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      seen: json['seen'] ?? false,
      delivered: json['delivered'] ?? false,
    );
  }

  /// Convert a Message object to Firestore document data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'type': type.toString().split('.').last,  // Serializing MessageType enum
      'timestamp': Timestamp.fromDate(timestamp),
      'seen': seen,
      'delivered': delivered,
    };
  }

  /// Helper to parse string to MessageType
  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }

  /// Helper to convert MessageType to string (for serialization)
  static String messageTypeToString(MessageType type) {
    return type.toString().split('.').last;
  }

  /// Helper to convert string to MessageType (for deserialization)
  static MessageType messageTypeFromString(String type) {
    return MessageType.values.firstWhere((e) => e.toString().split('.').last == type);
  }
}
