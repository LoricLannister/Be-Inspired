import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:be_inspired/helpers/UserSimplePreferences.dart';
import 'package:be_inspired/helpers/database.dart';
import 'package:be_inspired/pages/inscription.dart';
import 'package:be_inspired/pages/selecteurDePages.dart';

import 'MotDePasseOublie.dart';

class Connexion extends StatefulWidget {
  final bool? launch;
  const Connexion({Key? key, this.launch}) : super(key: key);

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool showPassword = false;
  bool loading = false;
  bool isEmailVerified = false;
  bool canResend = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null && _auth.currentUser!.emailVerified) {
      isEmailVerified = _auth.currentUser!.emailVerified;
      if (widget.launch == true) {
        sendVerificationMail();
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  sendVerificationMail() async {
    await _auth.currentUser!.sendEmailVerification();
  }

  connexion(String email, String password) async {
    try {
      setState(() {
        loading = true;
      });
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final data = await Database.getUserData(_auth.currentUser);
      await UserSimplePreferences.setNom(data['name']);
      await UserSimplePreferences.setEmail(email);
      if (!_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
        timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
          await _auth.currentUser!.reload();
          setState(() {
            loading = false;
            isEmailVerified = _auth.currentUser!.emailVerified;
          });
          if (isEmailVerified) timer.cancel();
          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 500),
              child: const SelecteurDePage(index: 2),
            ),
            (route) => false,
          );
        });
      } else {
        setState(() {
          loading = false;
        });
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            duration: const Duration(milliseconds: 500),
            child: const SelecteurDePage(index: 2),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      if (e.code == 'network-request-failed') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Network request failed, check internet connection",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid email",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "wrong password",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "User not found, please create account",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Something went wrong",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  resetPassword() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 500),
        child: const MotDePasseOublie(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _auth.currentUser != null && !isEmailVerified
          ? AppBar(
              title: const Text(
                "Email Verification",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20),
              ),
              backgroundColor: Colors.purple,
              centerTitle: true,
            )
          : null,
      body: _auth.currentUser != null && !isEmailVerified
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "A verification email have been sent to your email address, please open it to acces the application.",
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  canResend
                      ? InkWell(
                          onTap: () async {
                            try {
                              await _auth.currentUser!.sendEmailVerification();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Error:" + e.toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            setState(() {
                              canResend = false;
                            });
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.email,
                                    size: 30, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  "Send new e-mail",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      _auth.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          duration: const Duration(milliseconds: 500),
                          child: const Connexion(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Image.asset("assets/logo2.jpg",
                      fit: BoxFit.cover, height: 230, width: 230),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 28),
                  ),
                  Text(
                    "Sign to continue",
                    style: TextStyle(
                        color: Colors.purple.withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextFormField(
                          controller: email,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: "Email",
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.mail,
                                color: Colors.purple.shade300, size: 20),
                            suffixIcon: email.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      setState(() {
                                        email.text = "";
                                      });
                                    },
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.purple.withOpacity(0.5),
                                      size: 20,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextFormField(
                          controller: password,
                          onChanged: (value) {
                            setState(() {});
                          },
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            hintText: "Password",
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.purple.shade300,
                              size: 20,
                            ),
                            suffixIcon: password.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                    icon: Icon(
                                      showPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.purple.shade300,
                                      size: 20,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: InkWell(
                        onTap: () {
                          resetPassword();
                        },
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 12.5,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: InkWell(
                      onTap: () async {
                        if (email.text.isEmpty || password.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please fill all fields",
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          connexion(email.text, password.text);
                        }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: loading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have account?",
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              duration: const Duration(milliseconds: 500),
                              child: const Inscription(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          "Create anew account",
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
