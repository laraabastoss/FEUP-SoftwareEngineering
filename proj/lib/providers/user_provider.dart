import 'package:firebase_database/firebase_database.dart';

class CurrUser {
  CurrUser(
      {required this.username,
      required this.email,
      required this.phone,
      required this.bio,
        required this.isAdmin,
      });
  final String username;
  final String email;
  final String phone;
  final String bio;
  final bool isAdmin;

  static CurrUser fromUDB(String us, String em, String ph, String b, bool a) {
    CurrUser user;

    user = CurrUser(username: us, email: em, phone: ph, bio: b, isAdmin: a);

    return user;
  }
}

class UserProvider {
  static Future<CurrUser> getUserData(String? userkey, FirebaseDatabase db) async {
    final snapshot =
        await db.ref().child('users/$userkey').get();
    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
    return CurrUser.fromUDB(
        values['username'], values['email'], values['phone'], values['bio'], values['isAdmin'] ?? false);
  }
}
