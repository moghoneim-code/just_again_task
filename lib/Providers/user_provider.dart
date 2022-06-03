import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/user.dart';

class AppUserProvider extends ChangeNotifier {
  UserModel? _appUser;

  AppUserProvider() {
    _init();
  }

  void _init() async {
    if (FirebaseAuth.instance.currentUser != null) {
      // verify login
      final _instance = FirebaseAuth.instance;
      final _currentUser = _instance.currentUser;
      final _uid = _currentUser!.uid;
      DocumentReference userRef = FirebaseFirestore.instance.doc('users/$_uid');
      final _snapshot = await userRef.get();
      if (_snapshot.data() != null) {
        appUser = UserModel.fromSnapshot(_snapshot);
      }
    }
  }

  UserModel? get appUser => _appUser;

  set appUser(UserModel? value) {
    _appUser = value;
    notifyListeners();
  }
}
