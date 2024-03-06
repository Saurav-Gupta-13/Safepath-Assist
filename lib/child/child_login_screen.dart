import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safepath_assist/components/SecondaryButton.dart';
import 'package:safepath_assist/components/custom_textfield.dart';
import 'package:safepath_assist/components/PrimaryButton.dart';
import 'package:safepath_assist/child/register_child.dart';
import 'package:safepath_assist/db/share_pref.dart';
import 'package:safepath_assist/parent/parent_home_screen.dart';
import 'package:safepath_assist/parent/parent_register_screen.dart';
import 'package:safepath_assist/utils/constants.dart';
import 'package:safepath_assist/child/bottom_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordShown = true;
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool isLoading = false;

  _onSumbit() async {
    _formKey.currentState!.save();
    try {
      setState(() {
        isLoading = true;
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _formData['email'].toString(),
              password: _formData['password'].toString());
      if (userCredential.user != null) {
        setState(() {
          isLoading = false;
        });
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get()
            .then((value) {
          if (value['Type'] == 'Parent') {
            print(value['Type']);
            MySharedPrefference.saveUserType('Parent');
            goTO(context, ParentHomeScreen());
          } else {
            MySharedPrefference.saveUserType('Child');
            goTO(context, BottomPage());
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'user-not-found') {
        dialogBox(context, 'No user found for that email.');
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        dialogBox(context, 'Wrong password provided for that user.');
        print('Wrong password provided for that user.');
      }
    }
    //progressIndicator(context);
    //print(_formData['email']);
    //print(_formData['password']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              isLoading
                  ? progressIndicator(context)
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "USER LOGIN",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Image.asset(
                                  'assets/logo.png',
                                  height: 100,
                                  width: 100,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomTextField(
                                    hintText: 'Enter E-Mail',
                                    textInputAction: TextInputAction.next,
                                    keyboardtype: TextInputType.emailAddress,
                                    prefix: Icon(Icons.person),
                                    onsave: (email) {
                                      _formData['email'] = email ?? "";
                                    },
                                    validate: (email) {
                                      if (email!.isEmpty ||
                                          email.length < 3 ||
                                          !email.contains("@")) {
                                        return 'Enter a valid E-Mail';
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomTextField(
                                    hintText: 'Enter Password',
                                    isPassword: isPasswordShown,
                                    prefix: Icon(Icons.vpn_key_rounded),
                                    onsave: (password) {
                                      _formData['password'] = password ?? "";
                                    },
                                    validate: (password) {
                                      if (password!.isEmpty ||
                                          password.length < 7) {
                                        return 'Enter correct password';
                                      }
                                      return null;
                                    },
                                    suffix: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isPasswordShown = !isPasswordShown;
                                          });
                                        },
                                        icon: isPasswordShown
                                            ? Icon(Icons.visibility_off)
                                            : Icon(Icons.visibility)),
                                  ),
                                  PrimaryButton(
                                      title: 'LOGIN',
                                      onPressed: () {
                                        //progressIndicator(context);
                                        if (_formKey.currentState!.validate()) {
                                          _onSumbit();
                                        }
                                      }),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Forgot Password?",
                                  style: TextStyle(fontSize: 18),
                                ),
                                SecondaryButton(
                                    title: 'Click Here!', onPressed: () {}),
                              ],
                            ),
                          ),
                          SecondaryButton(
                              title: 'Register As Child',
                              onPressed: () {
                                goTO(context, RegisterChildScreen());
                              }),
                          SecondaryButton(
                              title: 'Register As Parent',
                              onPressed: () {
                                goTO(context, RegisterParentScreen());
                              }),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
