import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    key:
    const Key("forgot_password_screen_key");
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(height: 0.1*height,),
                Image.asset('assets/images/teste2.png', height: 200, width: 200),
                SizedBox(height: height*0.1),
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
                        borderSide: BorderSide.none
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    } else if (!EmailValidator.validate(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                )),
                SizedBox(height: height*0.05),
                SizedBox(
                    height: 50,
                    width: width*0.6,
                    child: ElevatedButton(
                      onPressed: () async {
                        String emailtext = _emailController.text;
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: emailtext);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Password reset email sent'),
                                content: Text('A password reset email has been sent to $emailtext.'),
                                actions: [
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } on FirebaseAuthException {
                          print("An error ocurred.");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(55, 176, 202, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          )),
                      child: const Text('Reset Password',
                          style: TextStyle(fontSize: 25, fontFamily: 'Lato')),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
