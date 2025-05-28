import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_sender.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final CollectionReference otpCollection = _firestore.collection('otps');

  // ✅ Check if username and email are available
  static Future<bool> checkUsernameAndEmailAvailable(String username, String email) async {
    print('[checkUsernameAndEmailAvailable] Checking availability...');
    final emailExists = await _firestore.collection('users').where('email', isEqualTo: email).get();
    final usernameExists = await _firestore.collection('users').where('name', isEqualTo: username).get();
    final available = emailExists.docs.isEmpty && usernameExists.docs.isEmpty;
    print('[checkUsernameAndEmailAvailable] Available: $available');
    return available;
  }

  // ✅ Send OTP to user's email
  static Future<bool> sendOtpToEmail(String email) async {
    print('[sendOtpToEmail] Generating OTP...');
    final otp = (100000 + Random().nextInt(900000)).toString();
    final expirationTime = DateTime.now().add(const Duration(minutes: 5));

    try {
      await otpCollection.doc(email).set({
        'otp': otp,
        'expirationTime': expirationTime,
      });

      final result = await EmailSender.sendEmail(
        email,
        "Your OTP Code",
        "Your OTP is: $otp. It is valid for 5 minutes.",
      );

      print('[sendOtpToEmail] OTP sent: $result');
      return result;
    } catch (e) {
      print('[sendOtpToEmail] Error: $e');
      return false;
    }
  }

  // ✅ Verify OTP entered by user
  static Future<bool> verifyOtp(String email, String enteredOtp) async {
    print('[verifyOtp] Verifying OTP...');
    final otpDoc = await otpCollection.doc(email).get();

    if (!otpDoc.exists) {
      print('[verifyOtp] No OTP found for email.');
      return false;
    }

    final storedOtp = otpDoc['otp'];
    final expirationTime = (otpDoc['expirationTime'] as Timestamp).toDate();

    if (DateTime.now().isAfter(expirationTime)) {
      print('[verifyOtp] OTP expired.');
      await otpCollection.doc(email).delete();
      return false;
    }

    final match = storedOtp == enteredOtp;

    if (match) {
      print('[verifyOtp] OTP verified successfully.');
      await otpCollection.doc(email).delete();
      return true;
    } else {
      print('[verifyOtp] Incorrect OTP.');
      return false;
    }
  }

  // ✅ Register user with Firebase Auth and save to Firestore
  static Future<void> registerUser(String username, String email, String password, String pushToken) async {
    print('[registerUser] Starting registration...');
    try {
      // Check if email is already registered
      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      final emailAlreadyExists = signInMethods.isNotEmpty;

      if (emailAlreadyExists) {
        print('[registerUser] Email already in use. Skipping registration.');
        return;
      }

      // Create Firebase Auth user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      print('[registerUser] Saving user to Firestore...');
      await _firestore.collection('users').doc(uid).set({
        'name': username,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
        'about': 'Hey! I am using MS-Intouch',
        'image': 'https://example.com/default_profile_image.png',
        'is_online': false,
        'last_active': FieldValue.serverTimestamp(),
        'push_token': pushToken,
        'permission': 'simple',
      });

      print('[registerUser] Registration complete.');
    } catch (e) {
      print('[registerUser] Error during registration: $e');
      rethrow;
    }
  }

  // ✅ Login user with Firebase Auth
  static Future<bool> loginUser(String email, String password) async {
    print('[loginUser] Attempting to login...');
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('[loginUser] Login successful.');
      await otpCollection.doc(email).delete(); // Clean up OTP after login
      return true;
    } catch (e) {
      print('[loginUser] Login failed: $e');
      return false;
    }
  }

  // ✅ Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
    print('[signOut] User signed out.');
  }

  // ✅ Send Password Reset Email
  static Future<bool> sendPasswordResetEmail(String email) async {
    print('[sendPasswordResetEmail] Sending password reset email...');
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('[sendPasswordResetEmail] Password reset email sent successfully.');
      return true;
    } catch (e) {
      print('[sendPasswordResetEmail] Error: $e');
      return false;
    }
  }

  // ✅ Confirm Password Reset (when user sets a new password)
  static Future<bool> confirmPasswordReset(String code, String newPassword) async {
    print('[confirmPasswordReset] Confirming password reset...');
    try {
      await _auth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      print('[confirmPasswordReset] Password reset successful.');
      return true;
    } catch (e) {
      print('[confirmPasswordReset] Error: $e');
      return false;
    }
  }
}
