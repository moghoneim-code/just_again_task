import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:justagain_task/Screens/main_page_screen/main_page_screen.dart';
import 'package:provider/provider.dart';
import '../../Models/user.dart';
import '../../Providers/user_provider.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const String id = "Login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Login already existing Users
  Future<String?> _loginUser(LoginData data) async {
    User? user;
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: data.name.trim(),
        password: data.password.trim(),
      );

      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      return e.toString();
    }

    if (user != null) {
      // verify login
      DocumentReference userRef =
          FirebaseFirestore.instance.doc('users/${user.uid}');
      userRef.get().then((DocumentSnapshot snapshot) {
        if (snapshot.data() != null) {
          // Set data to provider after log in.
          Provider.of<AppUserProvider>(context, listen: false).appUser =
              UserModel.fromSnapshot(snapshot);
        }
      });
    }
    return null;
  }

  /// signup New Users \\\
  Future<String?> _signupUser(SignupData data) async {
    User? user;
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: data.name!.trim(),
        password: data.password!.trim(),
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      return e.toString();
    }
    if (user != null) {
      DocumentReference newUserRef =
          FirebaseFirestore.instance.doc('users/${user.uid}');

      ///Prepare data to be saved on users table\\\

      Map<String, dynamic> userMap = {
        'fullName': data.name!.substring(0, data.name!.indexOf("@")),
        'email': data.name,
        'created_at': Timestamp.now(),
        'role': "student",
        'exams_taken': [],
      };
      newUserRef.set(userMap);
      Provider.of<AppUserProvider>(context, listen: false).appUser =
          UserModel.fromSnapshot(await newUserRef.get());
      Navigator.pushNamedAndRemoveUntil(
          context, MainPageScreen.id, (route) => false);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FlutterLogin(
      title: "Just again",
      logo: const AssetImage('assets/logo.png'),
      navigateBackAfterRecovery: true,
      loginAfterSignUp: false,
      termsOfService: [
        TermOfService(
            id: 'general-term',
            mandatory: true,
            text: 'Term of services',
            linkUrl: 'https://justagain.com/'),
      ],
      initialAuthMode: AuthMode.login,
      userValidator: (value) {
        if (!value!.contains('@') || !value.endsWith('.com')) {
          return "Email must contain '@' and end with '.com'";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value!.isEmpty) {
          return 'Password is empty';
        }
        return null;
      },
      onLogin: (loginData) {
        debugPrint('Login info');
        debugPrint('Name: ${loginData.name}');
        debugPrint('Password: ${loginData.password}');
        return _loginUser(loginData);
      },
      onSignup: (signupData) {
        debugPrint('Signup info');
        debugPrint('Name: ${signupData.name}');
        debugPrint('Password: ${signupData.password}');

        signupData.additionalSignupData?.forEach((key, value) {
          debugPrint('$key: $value');
        });
        if (signupData.termsOfService.isNotEmpty) {
          debugPrint('Terms of service: ');
          for (var element in signupData.termsOfService) {
            debugPrint(
                ' - ${element.term.id}: ${element.accepted == true ? 'accepted' : 'rejected'}');
          }
        }
        return _signupUser(signupData);
      },
      onSubmitAnimationCompleted: () {
        Navigator.pushNamedAndRemoveUntil(
            context, MainPageScreen.id, (route) => false);
      },

      ///sending reset password email by Firebase Auth Service

      onRecoverPassword: (email) {
        _auth.sendPasswordResetEmail(email: email);
        return null;
        // Show new password dialog
      },
      showDebugButtons: false,
    ));
  }
}
