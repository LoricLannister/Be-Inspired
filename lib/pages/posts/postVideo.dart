import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:be_inspired/helpers/UserSimplePreferences.dart';
import 'package:be_inspired/helpers/database.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class PostVideo extends StatefulWidget {
  const PostVideo({Key? key}) : super(key: key);

  @override
  State<PostVideo> createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo> {
  final TextEditingController about = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool posting = false;
  UploadTask? task;

  postVideo(BuildContext context) async {
    posting = true;
    final fileName = basename(_imageFile!.path);
    final destination = "posts/$fileName";
    task = Database.uploadPostToFirebase(destination, _imageFile!);
    setState(() {});
    Timer.periodic(Duration(seconds: 8), (timer) async {
      timer.cancel();
      if (task!.snapshot.bytesTransferred == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "An error occured while adding new post",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          posting = false;
        });
        await task!.cancel();
      } else {
        timer.cancel();
      }
    });
    await task!.whenComplete(() async {
      Database.saveUserPost(FirebaseAuth.instance.currentUser, {
        "about": about.text.trim(),
        "originName": FirebaseAuth.instance.currentUser!.displayName,
        "originUrl": FirebaseAuth.instance.currentUser!.photoURL,
        "postUrl": await task!.snapshot.ref.getDownloadURL(),
        "createdOn": Timestamp.now(),
        "video": true,
        "likes": 0,
        "likers": [],
        "id": (Random().nextInt(1000000) - Random().nextInt(100000)).toString(),
        "comments": [],
      });
      if (mounted) {
        setState(() {
          posting = false;
        });
      }
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
    });
  }

  cancel() async {
    await task!.cancel();
  }

  @override
  void dispose() {
    if (task != null) cancel();
    about.dispose();
    BetterPlayer.file(_imageFile!.path).controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Video"),
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
                subtitle: Text("Is adding a new video"),
                dense: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: TextFormField(
                controller: about,
                minLines: 1,
                maxLines: 10,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final pickedFile =
                        await _picker.pickVideo(source: ImageSource.gallery);
                    setState(() {
                      _imageFile = pickedFile;
                    });
                  },
                  child: Text("Add Video"),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 15, left: 15),
              child: AspectRatio(
                aspectRatio: 16 / 14,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(5, 5),
                          blurRadius: 8),
                    ],
                    color: Colors.black54,
                  ),
                  child: _imageFile != null
                      ? BetterPlayer.file(
                          _imageFile!.path,
                          betterPlayerConfiguration: BetterPlayerConfiguration(
                            aspectRatio: 16 / 14,
                          ),
                        )
                      : Container(),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(right: 30, left: 30),
              child: InkWell(
                onTap: () {
                  if (_imageFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please, select a video",
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (about.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please, talk about this post",
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    postVideo(context);
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
                        ? Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                                SizedBox(width: 10),
                                buildUploadStatus(task!),
                              ],
                            ),
                          )
                        : const Text(
                            "Post this video",
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
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildUploadStatus(UploadTask uploadTask) =>
      StreamBuilder<TaskSnapshot>(
          stream: uploadTask.snapshotEvents,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final snap = snapshot.data;
              final progress = snap!.bytesTransferred / snap.totalBytes;
              final percentage = (progress * 100).toStringAsFixed(2);
              return Text(
                "$percentage%",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            } else {
              return Container();
            }
          });
}
