import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String fullName;
  String email;
  String role;

  UserModel({
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory UserModel.empty() {
    return UserModel(
      email: '__email__',
      fullName: '__fullName__',
      role: '__role__',
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final Map<String, dynamic> _data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      fullName: _data['fullName'],
      email: _data['email'],
      role: _data['role'],
    );
  }
}
