import 'package:be_inspired/helpers/UserSimplePreferences.dart';
import 'package:be_inspired/pages/connexion.dart';
import 'package:be_inspired/pages/selecteurDePages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPreferences.getInstance();
  await UserSimplePreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Be Inspired',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _auth.currentUser != null
          ? (_auth.currentUser!.emailVerified
          ? const SelecteurDePage(index: 2)
          : const Connexion(launch: true))
          : const Connexion(launch: false),
    );
  }
}