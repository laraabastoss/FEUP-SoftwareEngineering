import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../providers/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(height: 0.03*height),
                Image.asset('assets/images/teste2.png', height: 200, width: 200),
                Container(height: 0.07*height),
                SizedBox(
                  width: 0.8*width,
                  child: TextFormField(
                  key: const Key('email'),
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: const Color.fromRGBO(241, 240, 240, 1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none
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
                ),),
                SizedBox(height: height*0.05),
                SizedBox(
                    width: 0.8*width,
                    child: TextFormField(
                  key: const Key('password'),
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: const Color.fromRGBO(241, 240, 240, 1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,),
                    ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),),
                if (errorMessage != "") Text(errorMessage),
                SizedBox(height: height*0.05),
                SizedBox(
                  height: 50,
                  width: width*0.6,
                  child: ElevatedButton(
                    key: const Key('login'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String email = _emailController.text.trim();
                        String password = _passwordController.text;
                        try {
                          await signInWithEmailAndPassword(email, password);
                          Navigator.pushReplacementNamed(context, 'main');
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            setState(() {
                              errorMessage = 'No user found!';
                            });
                          } else if (e.code == 'wrong-password') {
                            setState(() {
                              errorMessage =
                                  'Wrong password!';
                            });
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(55, 176, 202, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        )),
                    child: const Text('Login',
                        style: TextStyle(fontSize: 30, fontFamily: 'Lato')),
                  ),
                ),
                SizedBox(height: height*0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No account?",
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Lato',
                              color: Colors.black)),
                      TextButton(
                        key: const Key('register'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black, textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Lato'),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, 'register');
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                          color: Colors.black,),
                        ),
                      ),
                    ]),
                TextButton(
                  key: const Key('anonymous_sign_in'),
                  onPressed: () async {
                    await signInAnonymously();
                    Navigator.pushReplacementNamed(context, 'main');
                  },
                  child: const Text(
                    'Sign in without account',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Lato',
                    color: Colors.black),
                  ),
                ),
                TextButton(
                  key: const Key('forgot-password'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, textStyle: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Lato'),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, 'forgot-password');
                  },
                  child: const Text(
                    'Forgot password',
                  ),
                ),
            ],
            ),
          ),
        ),
    ));
  }
}
