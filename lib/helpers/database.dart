import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _userCollection = _firestore.collection('users');
final CollectionReference _postCoCollection = _firestore.collection('posts');

class Database {
  static String? userUid;

  static saveUserData(User? user, Map<String, dynamic> data) {
    _userCollection
        .doc(user!.uid)
        .set(data, SetOptions(merge: true))
        .then((_) => debugPrint("Data saved"))
        .catchError((onError) {
      print("Data unsaved because of error " + onError.toString());
    });
  }

  static saveUserPost(User? user, Map<String, dynamic> data) {
    _postCoCollection
        .doc(data['id'])
        .set(data, SetOptions(merge: true))
        .then((_) => debugPrint("New post saved"))
        .catchError((onError) {
      print("post unsaved because of " + onError.toString());
    });
  }

  static getUserData(User? user) async {
    final docUser = _userCollection.doc(user!.uid);
    final snapshot = await docUser.get();
    if (snapshot.exists) {
      print("Data get" + snapshot.data().toString());
      return snapshot.data();
    }
    return null;
  }

  static UploadTask uploadPostToFirebase(String destination, XFile file) {
    final ref = FirebaseStorage.instance.ref(destination);
    return ref.putFile(File(file.path));
  }

  /*static Future<List<String>> _getDownloadLinks(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  static Future<List<PostModel>> listAll(String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    final result = await ref.listAll();

    final urls = await _getDownloadLinks(result.items);
    return urls
        .asMap()
        .map((index, url) {
          final ref = result.items[index];
          final name = ref.name;
          final file = PostModel(ref: ref, name: name, url: url);

          return MapEntry(index, file);
        })
        .values
        .toList();
  }*/
}
