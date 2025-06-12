import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/message.dart';
import '../models/user.dart';
import '../services/cloudinary_service.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static UserModel? user;

  // Initialize user data
  static Future<void> init() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final userDoc = await firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        user = UserModel.fromJson(userDoc.data()!);
      } else {
        user = UserModel(
          uid: currentUser.uid,
          name: currentUser.displayName ?? 'Unknown',
          email: currentUser.email ?? '',
          image: currentUser.photoURL ?? '',
          isOnline: true,
          friends: [],
          createdAt: DateTime.now(),
        );
        await firestore.collection('users').doc(currentUser.uid).set(user!.toJson());
      }
    }
  }

  // Send message
  static Future<void> sendMessage(String chatId, String recipientId, Message message) async {
    try {
      final senderId = user?.uid ?? auth.currentUser?.uid ?? 'unknown';
      message.senderId = senderId;

      final chatRef = firestore.collection('chats').doc(chatId);
      final messageRef = chatRef.collection('messages').doc(message.id);

      await messageRef.set(message.toJson());

      // Update last message in user documents
      await firestore.collection('users').doc(senderId).update({
        'last_message': message.toJson(),
        'last_message_time': message.timestamp
      });

      await firestore.collection('users').doc(recipientId).update({
        'last_message': message.toJson(),
        'last_message_time': message.timestamp
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Get all messages in a chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(String chatId) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Send media or file message
  static Future<void> sendFileMessage(String chatId, String recipientId, String fileUrl, MessageType type) async {
    try {
      final message = Message(
        id: const Uuid().v4(),
        senderId: user?.uid ?? auth.currentUser?.uid ?? 'unknown',
        content: fileUrl,
        type: type,
        timestamp: DateTime.now(),
        seen: false,
        delivered: false,
      );

      await sendMessage(chatId, recipientId, message);
    } catch (e) {
      print('Error sending file message: $e');
    }
  }

  // Upload file to Cloudinary
  static Future<String> uploadFile(File file) async {
    try {
      return await CloudinaryService.uploadFile(file);
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  // Get user by ID
  static Future<UserModel> getUserById(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      return UserModel.fromJson(userDoc.data()!);
    } catch (e) {
      print('Error fetching user info: $e');
      rethrow;
    }
  }

  // Create a chat between two users
  static Future<String> createChat(String userId, String friendId) async {
    try {
      final chatRef = firestore.collection('chats').doc();
      final chatId = chatRef.id;

      await chatRef.set({
        'user_ids': [userId, friendId],
        'created_at': DateTime.now(),
      });

      return chatId;
    } catch (e) {
      print('Error creating chat: $e');
      rethrow;
    }
  }

  // Check if user exists
  static Future<bool> isUserExist(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      return userDoc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // Add friend in both users' friend lists
  static Future<void> addFriend(String userId, String friendId) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'friends': FieldValue.arrayUnion([friendId])
      });
      await firestore.collection('users').doc(friendId).update({
        'friends': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      print('Error adding friend: $e');
    }
  }

  // Remove friend in both users' friend lists
  static Future<void> removeFriend(String userId, String friendId) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'friends': FieldValue.arrayRemove([friendId])
      });
      await firestore.collection('users').doc(friendId).update({
        'friends': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

  // Delete a single message
  static Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).delete();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  // Delete entire conversation between two users
  static Future<void> deleteConversation(String chatId, String userId, String friendId) async {
    try {
      // Delete all messages in the chat
      final messages = await firestore.collection('chats').doc(chatId).collection('messages').get();
      for (final doc in messages.docs) {
        await doc.reference.delete();
      }

      // Delete the chat document itself
      await firestore.collection('chats').doc(chatId).delete();

      // Remove each other from friends list
      await removeFriend(userId, friendId);
    } catch (e) {
      print('Error deleting conversation: $e');
    }
  }

  // Update message status (seen/delivered)
  static Future<void> updateMessageStatus(String chatId, String messageId, bool seen, bool delivered) async {
    try {
      final msgRef = firestore.collection('chats').doc(chatId).collection('messages').doc(messageId);

      await msgRef.update({
        'seen': seen,
        'delivered': delivered,
      });
    } catch (e) {
      print('Error updating message status: $e');
    }
  }
}