import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profileImage;
  final String dob;
  
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImage,
    required this.dob,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'],
      dob: map['dob'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'dob': dob,
    };
  }
}

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // GoogleSignIn with Web Client ID configuration
  // For your project: facebook-clone-6cca4
  // Your Firebase project number: 556331607467
  // Web Client ID typically looks like: 556331607467-xxxxxxxxxxxx.apps.googleusercontent.com
  // For now, I'll add the configuration but you need to enable Google Sign-In in Firebase Console
  
  // IMPORTANT: You need to get the actual Web Client ID from Firebase Console
  // Go to: Firebase Console -> Your Project -> Authentication -> Sign-in method -> Google -> Web SDK configuration
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // This is a placeholder. You need to replace it with your actual Web Client ID
    // For testing on localhost, you can try using just the project number
    clientId: kIsWeb ? '556331607467.apps.googleusercontent.com' : null,
    scopes: ['email', 'profile'],
  );
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  
  AuthProvider() {
    print("🌍 Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
    print("🔑 GoogleSignIn configured for web: ${kIsWeb}");
    
    // Initialize user on startup
    _initializeUser();
    
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? firebaseUser) async {
      print("🔄 Auth state changed: ${firebaseUser?.uid}");
      await _handleAuthStateChange(firebaseUser);
    });
  }
  
  Future<void> _initializeUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _loadUserData(currentUser.uid);
    }
  }
  
  Future<void> _handleAuthStateChange(User? firebaseUser) async {
    if (firebaseUser != null) {
      await _loadUserData(firebaseUser.uid);
    } else {
      _user = null;
    }
    notifyListeners();
  }
  
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!);
        print("✅ User data loaded: ${_user?.email}");
      } else {
        print("⚠️ User document doesn't exist for uid: $uid");
        await _createUserDocument(uid);
      }
    } catch (e) {
      print("❌ Error loading user data: $e");
    }
  }
  
  Future<void> _createUserDocument(String uid) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        final userData = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'New User',
          email: firebaseUser.email ?? '',
          profileImage: firebaseUser.photoURL,
          dob: '1990-01-01',
        );
        
        await _firestore.collection('users').doc(uid).set(
          userData.toMap()
        );
        
        _user = userData;
        print("✅ Created new user document");
      }
    } catch (e) {
      print("❌ Error creating user document: $e");
    }
  }
  
  // Google Sign In Method with better error handling
  Future<void> signInWithGoogle() async {
    setLoading(true);
    
    try {
      print("🔄 Starting Google Sign In");
      print("📱 Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
      
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign in
        print("❌ Google sign in cancelled by user");
        setLoading(false);
        return;
      }
      
      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      print("✅ Google authentication successful");
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with Google credentials
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      
      print("✅ Firebase Google Sign In successful: ${userCredential.user?.uid}");
      
      // Check if user is new or existing
      if (userCredential.additionalUserInfo!.isNewUser) {
        print("👤 New Google user, creating document...");
        final User? firebaseUser = userCredential.user;
        
        if (firebaseUser != null) {
          // Create user document in Firestore
          final userData = UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Google User',
            email: firebaseUser.email ?? '',
            profileImage: firebaseUser.photoURL,
            dob: '1990-01-01',
          );
          
          await _firestore.collection('users').doc(firebaseUser.uid).set(
            userData.toMap()
          );
          
          _user = userData;
          print("✅ Created new user document for Google user");
        }
      } else {
        // Existing user, load their data
        if (userCredential.user != null) {
          await _loadUserData(userCredential.user!.uid);
        }
      }
      
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Google Sign In error: ${e.code} - ${e.message}");
      throw _handleAuthError(e);
    } catch (e) {
      print("❌ Google Sign In error: $e");
      
      // Provide more helpful error message
      if (kIsWeb) {
        throw 'Google Sign-In needs Web Client ID setup. Please configure it in Firebase Console.';
      } else {
        throw 'Error signing in with Google. Please try again.';
      }
    } finally {
      setLoading(false);
    }
  }
  
  // Update logout to also sign out from Google
  Future<void> logout() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Firebase
      await _auth.signOut();
      
      _user = null;
      print("✅ Logout successful from both Firebase and Google");
    } catch (e) {
      print("❌ Logout error: $e");
      throw 'Error signing out. Please try again.';
    }
  }
  
  Future<void> login(String email, String password) async {
    setLoading(true);
    
    try {
      print("🔄 Attempting login for: $email");
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      print("✅ Firebase login successful: ${userCredential.user?.uid}");
      
      // Manually load user data immediately after login
      if (userCredential.user != null) {
        await _loadUserData(userCredential.user!.uid);
      }
      
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase auth error: ${e.code} - ${e.message}");
      throw _handleAuthError(e);
    } catch (e) {
      print("❌ General login error: $e");
      throw 'An error occurred. Please try again.';
    } finally {
      setLoading(false);
    }
  }
  
  Future<void> signup(String name, String email, String password, String dob) async {
    setLoading(true);
    
    try {
      print("🔄 Starting signup for: $email");
      
      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      print("✅ Firebase Auth user created: ${userCredential.user?.uid}");
      
      final User? firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        // Create user document in Firestore
        final userData = UserModel(
          uid: firebaseUser.uid,
          name: name.trim(),
          email: email.trim(),
          profileImage: firebaseUser.photoURL,
          dob: dob,
        );
        
        await _firestore.collection('users').doc(firebaseUser.uid).set(
          userData.toMap()
        );
        
        print("✅ Firestore document created");
        
        // Set the user immediately
        _user = userData;
        
        // Send email verification (optional)
        await firebaseUser.sendEmailVerification();
        print("✅ Verification email sent");
      }
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase signup error: ${e.code} - ${e.message}");
      throw _handleAuthError(e);
    } catch (e) {
      print("❌ General signup error: $e");
      throw 'An error occurred. Please try again.';
    } finally {
      setLoading(false);
    }
  }
  
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'invalid-email':
        return 'Email is invalid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/password signup is not enabled. Contact support.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}