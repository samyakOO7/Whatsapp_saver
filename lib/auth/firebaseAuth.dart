import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';


class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn= new GoogleSignIn();
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = authResult.user;
      return user;
    } catch (e) {
      print('Email Sign-In Error: $e');
      return null;
    }
  }

  Future<dynamic> createUserWithEmailAndPassword(String email, String password, String firstName, String lastName) async {
    try {
      // Check if the user already exists with the provided email
      final existingUser = await _auth.fetchSignInMethodsForEmail(email);
      if (existingUser.isNotEmpty) {
        return 'User already exists. Please sign in instead.';
      }

      final UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = authResult.user;
      if (user != null) {
        // Store the user's firstName and lastName in Firebase Realtime Database
        final DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users').child(user.uid);
        userRef.set({
          'firstName': firstName,
          'lastName': lastName,
          'email':email,
        });
      }
      return user;
    } catch (e) {
      print('Email Sign-Up Error: $e');
      return 'An error occurred during sign-up.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled Google Sign-In
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        // Store user information in Firebase Realtime Database if needed
        final DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users').child(user.uid);
        userRef.set({
          'displayName': user.displayName,
          'email': user.email,
          // Add other user information as needed
        });
      }

      return user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }
  Future<bool> checkUserExistence(String email) async {
    try {
      final existingUser = await _auth.fetchSignInMethodsForEmail(email);
      return existingUser.isNotEmpty;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

}
