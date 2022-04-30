import 'dart:io';

import 'package:be_inspired/helpers/UserSimplePreferences.dart';
import 'package:be_inspired/helpers/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController name = TextEditingController();
  PickedFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool updating = false;

  void dispose() {
    super.dispose();
  }

  update(String name, BuildContext context) async {
    try {
      if (_imageFile != null) {
        final firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child("profilePictures/${FirebaseAuth.instance.currentUser!.uid}");
        await firebaseStorageRef.delete().onError((error, stackTrace) => null);
        UploadTask uploadTask =
            firebaseStorageRef.putFile(File(_imageFile!.path));
        FirebaseAuth.instance.currentUser!.updateDisplayName(name);
        final _ = await uploadTask.whenComplete(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Profile successfully updated",
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.purple,
            ),
          );
          Navigator.pop(context);
        });
        FirebaseAuth.instance.currentUser!
            .updatePhotoURL(await _.ref.getDownloadURL());
        Database.saveUserData(FirebaseAuth.instance.currentUser!, {
          "name": name.trim(),
          "photoUrl": await _.ref.getDownloadURL(),
        });
      }
      setState(() {
        updating = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          updating = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Something went wrong went updating",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        elevation: 20,
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),
            Container(
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 3.3,
                      width: MediaQuery.of(context).size.height / 3.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: UserSimplePreferences.getUserImage() == null
                          ? (FirebaseAuth.instance.currentUser!.photoURL != null
                              ? CachedNetworkImage(
                                  imageUrl: FirebaseAuth
                                      .instance.currentUser!.photoURL!,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.purple),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Text(
                                        "Unable to load picture, no internet"),
                                  ),
                                )
                              : Image.asset("assets/defaultProfile.png"))
                          : Image.file(
                              File(UserSimplePreferences.getUserImage()!),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: ((builder) => bottomSheet(context)));
                        },
                        icon: Icon(Icons.camera_alt),
                        iconSize: 35,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              FirebaseAuth.instance.currentUser!.displayName!,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 17),
                child: Text(
                  "username",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextFormField(
                    controller: name,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Enter new username",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.person,
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
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: InkWell(
                onTap: () async {
                  if (name.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please enter new username",
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (name.text.trim() ==
                      FirebaseAuth.instance.currentUser!.displayName) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "This username is already used",
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    setState(() {
                      updating = true;
                    });
                    update(name.text, context);
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: updating
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            "Update profile",
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

  Widget bottomSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 6.5,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(children: [
        Text("Profile picture", style: TextStyle(fontSize: 20)),
        SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          TextButton.icon(
              onPressed: () {
                takePhoto(ImageSource.camera, context);
                Navigator.pop(context);
              },
              icon: Icon(Icons.camera),
              label: Text("Camera")),
          TextButton.icon(
              onPressed: () {
                takePhoto(ImageSource.gallery, context);
                Navigator.pop(context);
              },
              icon: Icon(Icons.image),
              label: Text("Gallery")),
        ])
      ]),
    );
  }

  void takePhoto(ImageSource source, BuildContext context) async {
    final pickedFile = await _picker.getImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });
    if (pickedFile != null) {
      await UserSimplePreferences.setUserImage(_imageFile!.path);
    }
  }
}
