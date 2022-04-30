import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:be_inspired/helpers/UserSimplePreferences.dart';
import 'package:be_inspired/helpers/database.dart';
import 'package:be_inspired/pages/connexion.dart';
import 'package:be_inspired/pages/selecteurDePages.dart';

class Inscription extends StatefulWidget {
  const Inscription({Key? key}) : super(key: key);

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password1 = TextEditingController();
  final TextEditingController password2 = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool showPassword = false;
  bool loading = false;

  inscription(String email, String password) async {
    try {
      setState(() {
        loading = true;
      });
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _auth.currentUser!.updateDisplayName(name.text);
      Database.saveUserData(_auth.currentUser, {
        "name": name.text,
        "e-mail": email,
        "password": password,
        "photoUrl": '',
      });
      await UserSimplePreferences.setNom(name.text);
      await UserSimplePreferences.setEmail(email);
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 500),
          child: const SelecteurDePage(index: 2),
        ),
      );
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
      } else if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Too weak password",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "This email is already in use, please login",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Text(
              "Welcome on Be Inspired",
              style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
            Text(
              "Create a new account",
              style: TextStyle(
                  color: Colors.purple.withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                  fontSize: 15),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
              child: TextFormField(
                controller: name,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: "Name",
                  prefixIcon: Icon(Icons.person_outline,
                      color: Colors.purple.shade300, size: 20),
                  suffixIcon: name.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              name.text = "";
                            });
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.purple.withOpacity(0.5),
                            size: 20,
                          ),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: TextFormField(
                controller: email,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon:
                    Icon(Icons.email, color: Colors.purple.shade300, size: 20),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: TextFormField(
                controller: password1,
                obscureText: true,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline,
                      color: Colors.purple.shade300, size: 20),
                  suffixIcon: password1.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              password1.text = "";
                            });
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.purple.withOpacity(0.5),
                            size: 20,
                          ),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: TextFormField(
                controller: password2,
                obscureText: !showPassword,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: "Confirm password",
                  prefixIcon: Icon(Icons.lock_outline,
                      color: Colors.purple.shade300, size: 20),
                  suffixIcon: password2.text.isEmpty
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
                            color: Colors.purple,
                            size: 20,
                          ),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: InkWell(
                onTap: () {
                  if (name.text.isEmpty ||
                      email.text.isEmpty ||
                      password1.text.isEmpty ||
                      password2.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please, fill all fields",
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    if (name.text.length < 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Your name is too short",
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (password1.text != password2.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "different passwords",
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      inscription(email.text, password2.text);
                    }
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
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            "Create account",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
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
                        child: const Connexion(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text(
                    "login",
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
