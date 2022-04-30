import 'dart:io';
import 'dart:math';

import 'package:be_inspired/helpers/UserSimplePreferences.dart';
import 'package:be_inspired/helpers/database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostText extends StatefulWidget {
  const PostText({Key? key}) : super(key: key);

  @override
  State<PostText> createState() => _PostTextState();
}

class _PostTextState extends State<PostText> {
  final TextEditingController about = TextEditingController();
  bool posting = false;

  postText() async {
    Database.saveUserPost(FirebaseAuth.instance.currentUser, {
      "about": about.text.trim(),
      "originName": FirebaseAuth.instance.currentUser!.displayName,
      "originUrl": FirebaseAuth.instance.currentUser!.photoURL,
      "createdOn": Timestamp.now(),
      "text": true,
      "likes": 0,
      "likers": [],
      "id": (Random().nextInt(1000000) - Random().nextInt(100000)).toString(),
      "comments": [],
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Your post have being published!",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.purple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Text"),
        centerTitle: true,
        elevation: 20,
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 15, 20),
              child: ListTile(
                leading: Container(
                  height: 50,
                  width: 50,
                  child: UserSimplePreferences.getUserImage() == null
                      ? (FirebaseAuth.instance.currentUser!.photoURL != null
                          ? CachedNetworkImage(
                              imageUrl:
                                  FirebaseAuth.instance.currentUser!.photoURL!,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.purple),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child:
                                    Text("Unable to load picture, no internet"),
                              ),
                            )
                          : Image.asset("assets/defaultProfile.png"))
                      : Image.file(
                          File(UserSimplePreferences.getUserImage()!),
                        ),
                ),
                title: Text(FirebaseAuth.instance.currentUser!.displayName!),
                horizontalTitleGap: 10,
                subtitle: Text("Is adding a new text"),
                dense: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
              child: TextFormField(
                controller: about,
                minLines: 1,
                maxLines: 15,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30, left: 30),
              child: InkWell(
                onTap: () {
                  if (about.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please, write the text to post",
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    postText();
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: posting
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            "Post this text",
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
          ],
        ),
      ),
    );
  }
}
