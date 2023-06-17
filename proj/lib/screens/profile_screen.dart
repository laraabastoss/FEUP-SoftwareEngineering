import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';

import '../data_modifiers/place_confirmer.dart';
import '../providers/location_provider.dart';
import '../providers/user_provider.dart';

class ProfileMenu extends StatefulWidget {
  const ProfileMenu({super.key});

  @override
  _ProfileMenuState createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  bool _isEditing = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    CurrUser user =
        await UserProvider.getUserData(uid, FirebaseDatabase.instance);
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _bioController.text = user.bio;
    _phoneController.text = user.phone;
    _isAdmin = user.isAdmin;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: Key('profile_page'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Container(
                  height: height * 0.05,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(
                    Icons.person,
                    color: Colors.blueGrey,
                    size: 100,
                  ),
                  Container(
                    width: width * 0.02,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<CurrUser>(
                        future: UserProvider.getUserData(
                            uid, FirebaseDatabase.instance),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (!snapshot.hasData) {
                            return const Text('Error fetching data');
                          }
                          CurrUser user = snapshot.data!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.username, // Display the user's name
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Lato',
                                ),
                              ),
                              Text(user.bio,
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Lato',
                                  ))
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  Container(
                    width: width * 0.06,
                  ),
                  GestureDetector(
                    onTap: (){
                      Restart.restartApp();
                    },
                    child: Icon(Icons.logout, size: 30, color: Colors.black),
                  ),
                ]),
                Container(
                  height: height * 0.03,
                ),
                Container(height: height * 0.035),
                if (!_isEditing)
                  Container(
                    height: height * 0.035,
                  ),
                if (!_isEditing)
                  Row(children: [
                    const Icon(Icons.person, color: Colors.cyan),
                    Container(
                      width: 0.03 * width,
                    ),
                    Text(_usernameController.text,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Lato',
                            color: Colors.black),
                        textAlign: TextAlign.right)
                  ]),
                if (!_isEditing) Container(height: height * 0.035),
                if (!_isEditing)
                  Row(children: [
                    const Icon(Icons.book, color: Colors.cyan),
                    Container(
                      width: 0.03 * width,
                    ),
                    Text(_bioController.text,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Lato',
                            color: Colors.black),
                        textAlign: TextAlign.right),
                  ]),
                if (!_isEditing) Container(height: height * 0.035),
                if (!_isEditing)
                  Row(children: [
                    const Icon(Icons.email_rounded, color: Colors.cyan),
                    Container(
                      width: 0.03 * width,
                    ),
                    Text(_emailController.text,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Lato',
                            color: Colors.black),
                        textAlign: TextAlign.right)
                  ]),
                if (!_isEditing) Container(height: height * 0.035),
                if (!_isEditing)
                  Row(children: [
                    const Icon(Icons.phone, color: Colors.cyan),
                    Container(
                      width: 0.03 * width,
                    ),
                    Text(_phoneController.text,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Lato',
                            color: Colors.black),
                        textAlign: TextAlign.right),
                  ]),
                if (_isEditing) ...[
                  SizedBox(height: height * 0.02),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      filled: true,
                      fillColor: const Color.fromRGBO(241, 240, 240, 1),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: const Color.fromRGBO(241, 240, 240, 1),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      hintText: 'Bio',
                      filled: true,
                      fillColor: const Color.fromRGBO(241, 240, 240, 1),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Phone',
                      filled: true,
                      fillColor: const Color.fromRGBO(241, 240, 240, 1),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ],
                Container(
                  height: 0.05 * height,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )),
                      onPressed: () async {
                        if (_isEditing &&
                            _emailController.text !=
                                FirebaseAuth.instance.currentUser?.email) {
                          List<String> methods = await FirebaseAuth.instance
                              .fetchSignInMethodsForEmail(
                                  _emailController.text);
                          if (methods.isNotEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'This email address is already in use'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }
                        }

                        if (_isEditing) {
                          if (_emailController.text !=
                              FirebaseAuth.instance.currentUser?.email) {
                            try {
                              await FirebaseAuth.instance.currentUser!
                                  .updateEmail(_emailController.text);
                              print("Email updated");
                            } catch (e) {
                              print(
                                  "Error updating email in firebase authentication");
                            }
                          }
                          CurrUser user = await UserProvider.getUserData(
                              uid, FirebaseDatabase.instance);
                          await FirebaseDatabase.instance
                              .ref()
                              .child('users')
                              .child(uid!)
                              .set({
                            'username': _usernameController.text,
                            'email': _emailController.text,
                            'phone': _phoneController.text,
                            'bio': _bioController.text,
                            'isAdmin': user.isAdmin
                          });
                          setState(() {
                            _usernameController.text = _usernameController.text;
                            _bioController.text = _bioController.text;
                            _emailController.text = _emailController.text;
                            _phoneController.text = _phoneController.text;
                          });
                        }

                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            _isEditing ? 'Save' : 'Edit',
                            style: const TextStyle(color: Colors.black, fontSize: 20),
                          ),
                          Icon(
                              _isEditing
                                  ? Icons.save
                                  : Icons.mode_edit_outlined,
                              size: 22,
                              color: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isAdmin) ...[
                  // Display admin-specific content here
                  SizedBox(height: height * 0.02),
                  const Text(
                    "Suggested Places from Users",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.cyan,
                      fontFamily: 'Lato',
                    ),
                  ),
                  ChangeNotifierProvider<LocationModel>(
                    create: (_) => LocationModel(),
                    child: Consumer<LocationModel>(
                      builder: (context, model, child) {
                        return Column(
                            children: model.suggestedPlaces.map((item) {
                          PlaceConfirmer confirmer = PlaceConfirmer(
                              placeKey: item.key,
                              db: FirebaseDatabase.instance);
                          return Row(
                            children: [
                              Text(item.name),
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () async {
                                  await confirmer.acceptPlace();
                                  setState(() {});
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () async {
                                  await confirmer.declinePlace();
                                  setState(() {});
                                },
                              ),
                            ],
                          );
                        }).toList());
                      },
                    ),
                  ),
                  // Additional widgets for admin users
                  // Add your admin-specific content here
                ],
              ],
            )),
      ),
    );

  }
}
