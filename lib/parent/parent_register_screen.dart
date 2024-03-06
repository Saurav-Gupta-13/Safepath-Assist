import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safepath_assist/utils/constants.dart';
import 'package:safepath_assist/child/child_login_screen.dart';

import '../components/PrimaryButton.dart';
import '../components/SecondaryButton.dart';
import '../components/custom_textfield.dart';
import '../model/user_model.dart';

class RegisterParentScreen extends StatefulWidget {
  @override
  State<RegisterParentScreen> createState() => _RegisterParentScreenState();
}

class _RegisterParentScreenState extends State<RegisterParentScreen> {
  bool isPasswordShown = true;
  bool isReEnterPasswordShown = true;

  final _formKey = GlobalKey<FormState>();

  final _formData = Map<String, Object>();

  bool isLoading = false;

  _onSumbit() async {
    _formKey.currentState!.save();
    if (_formData['password'] != _formData['rpassword']) {
      dialogBox(context, 'Password & Re-Enter Password should be same.');
    } else {
      progressIndicator(context);
      try {
        setState(() {
          isLoading = true;
        });
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _formData['email'].toString(),
                password: _formData['password'].toString());
        if (userCredential.user != null) {
          final v = userCredential.user!.uid;
          DocumentReference<Map<String, dynamic>> db =
              FirebaseFirestore.instance.collection('users').doc(v);
          final user = UserModel(
            Id: v,
            Name: _formData['name'].toString(),
            mobileNumber: _formData['phone'].toString(),
            childEmail: _formData['cemail'].toString(),
            parentEmail: _formData['email'].toString(),
            type: 'Parent',
          );
          final jsonData = user.toJson();
          await db.set(jsonData).whenComplete(() {
            goTO(context, LoginScreen());
            setState(() {
              isLoading = false;
            });
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
          dialogBox(context, 'The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
          dialogBox(context, 'The account already exists for that email.');
        }
      } catch (e) {
        print(e);
        setState(() {
          isLoading = false;
        });
        dialogBox(context, e.toString());
      }
    }
    //print(_formData['email']);
    //print(_formData['password']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                "REGISTER AS PARENT",
                                textAlign: TextAlign.center,
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
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CustomTextField(
                                  hintText: 'Enter Name',
                                  textInputAction: TextInputAction.next,
                                  keyboardtype: TextInputType.name,
                                  prefix: Icon(Icons.person),
                                  onsave: (name) {
                                    _formData['name'] = name ?? "";
                                  },
                                  validate: (name) {
                                    if (name!.isEmpty) {
                                      return 'Name is a mandatory field';
                                    }
                                    return null;
                                  },
                                ),
                                CustomTextField(
                                  hintText: 'Enter Mobile Number',
                                  textInputAction: TextInputAction.next,
                                  keyboardtype: TextInputType.phone,
                                  prefix: Icon(Icons.phone),
                                  onsave: (phone) {
                                    _formData['phone'] = phone ?? "";
                                  },
                                  validate: (phone) {
                                    if (phone!.isEmpty ||
                                        phone.length < 10 ||
                                        phone.length > 10) {
                                      return 'Enter a valid number';
                                    }
                                    return null;
                                  },
                                ),
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
                                  hintText: 'Enter Child E-Mail',
                                  textInputAction: TextInputAction.next,
                                  keyboardtype: TextInputType.emailAddress,
                                  prefix: Icon(Icons.person),
                                  onsave: (cemail) {
                                    _formData['cemail'] = cemail ?? "";
                                  },
                                  validate: (cemail) {
                                    if (cemail!.isEmpty ||
                                        cemail.length < 3 ||
                                        !cemail.contains("@")) {
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
                                CustomTextField(
                                  hintText: 'Re-Enter Password',
                                  isPassword: isReEnterPasswordShown,
                                  prefix: Icon(Icons.vpn_key_rounded),
                                  onsave: (password) {
                                    _formData['rpassword'] = password ?? "";
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
                                          isReEnterPasswordShown =
                                              !isReEnterPasswordShown;
                                        });
                                      },
                                      icon: isReEnterPasswordShown
                                          ? Icon(Icons.visibility_off)
                                          : Icon(Icons.visibility)),
                                ),
                                PrimaryButton(
                                    title: 'LOGIN',
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _onSumbit();
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ),
                        SecondaryButton(
                            title: 'Already have an account? Login',
                            onPressed: () {
                              goTO(context, LoginScreen());
                            }),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    ));
  }
}
