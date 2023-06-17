import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../providers/auth.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String _username = '';

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    key:
    const Key("register_screen_key");
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(height: 0.03*height),
                Image.asset('assets/images/teste2.png', height: 140, width: 140),
                Container(height: 0.04*height),
                SizedBox(
                  width: 0.8*width,
                  child: TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    filled: true,
                    fillColor: const Color.fromRGBO(241, 240, 240, 1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _username = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                )),
                SizedBox(height: height*0.03),
                SizedBox(
                  width: 0.8*width,
                  child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: const Color.fromRGBO(241, 240, 240, 1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    } else if (!EmailValidator.validate(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                )),
                SizedBox(height: height*0.03),
              SizedBox(
                width: 0.8*width,
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: const Color.fromRGBO(241, 240, 240, 1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),),
                SizedBox(height: height*0.03),
                SizedBox(
                  width: 0.8*width,
                  child: TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    filled: true,
                    fillColor: const Color.fromRGBO(241, 240, 240, 1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                )),
                SizedBox(height: height*0.05),
                SizedBox(
                    height: 50,
                    width: 0.6*width,
                    child: SizedBox(
                      width: width*0.6,
                      child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String email = _emailController.text.trim();
                          String password = _passwordController.text;
                          try {
                            await signUpWithEmailAndPassword(
                                email, password, _username);
                            Navigator.pushReplacementNamed(context, 'main');
                          } catch (e) {
                            print('Error registering: $e');
                            // Show an error message to the user
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(55, 176, 202, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          )),
                      child: const Text('Register',
                          style: TextStyle(fontSize: 30, fontFamily: 'Lato')),
                    ))),
                SizedBox(height: height*0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already a member?",
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Lato',)),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black, textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lato'),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                      child: const Text(
                        'Login',
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    FirebaseAuth.instance.signInAnonymously();
                    Navigator.pushReplacementNamed(context, 'main');
                  },
                  child: const Text(
                    'Sign in without account',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontFamily: 'Lato'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
