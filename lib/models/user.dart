import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String image;
  final bool isOnline;
  final String? about;
  final String? permission;
  final String? pushToken;
  final List<String> friends;
  final DateTime createdAt;
  final DateTime? lastActive;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    required this.isOnline,
    this.about,
    this.permission,
    this.pushToken,
    required this.friends,
    required this.createdAt,
    this.lastActive,
  });

  /// Convert this object to a map for saving in Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'name': name,
      'email': email,
      'image': image,
      'isOnline': isOnline,
      'about': about,
      'permission': permission,
      'pushToken': pushToken,
      'friends': friends,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
    };
  }

  /// Create a UserModel object from Firestore map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      isOnline: json['isOnline'] ?? false,
      about: json['about'],
      permission: json['permission'],
      pushToken: json['pushToken'],
      friends: List<String>.from(json['friends'] ?? []),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // Fallback to current time if null
      lastActive: json['lastActive'] != null
          ? (json['lastActive'] as Timestamp).toDate()
          : null,
    );
  }

  /// Update user's online status in Firestore
  static Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
        'isOnline': isOnline,
        'lastActive': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  /// Get a user by ID from Firestore
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  /// Get all friends of a user
  static Future<List<UserModel>> getFriends(String userId) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        final user = UserModel.fromJson(doc.data()!);
        final friendIds = user.friends;

        if (friendIds.isEmpty) return [];

        final friendDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('id', whereIn: friendIds)
            .get();

        return friendDocs.docs
            .map((doc) => UserModel.fromJson(doc.data()))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
  }
}
