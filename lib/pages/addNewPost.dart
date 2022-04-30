import 'package:be_inspired/pages/posts/postPhoto.dart';
import 'package:be_inspired/pages/posts/postText.dart';
import 'package:be_inspired/pages/posts/postVideo.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class AddNewPost extends StatefulWidget {
  const AddNewPost({Key? key}) : super(key: key);

  @override
  State<AddNewPost> createState() => _AddNewPostState();
}

class _AddNewPostState extends State<AddNewPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adding new post"),
        centerTitle: true,
        elevation: 20,
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Text(
                'Express who\nyou are!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
              child: Text(
                'Share your images, videos, testimonies and let others know what God has done for you.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
              child: Text(
                'What do you want to talk about today?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    duration: const Duration(milliseconds: 800),
                    child: const PostPhoto(),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(
                  Icons.add_photo_alternate,
                  color: Colors.purple,
                ),
                title: Text("Add a photo"),
                horizontalTitleGap: 0,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    duration: const Duration(milliseconds: 800),
                    child: const PostVideo(),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(
                  Icons.video_call,
                  color: Colors.purple,
                ),
                title: Text("Add a Video"),
                horizontalTitleGap: 0,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    duration: const Duration(milliseconds: 800),
                    child: const PostText(),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(
                  Icons.text_snippet,
                  color: Colors.purple,
                ),
                title: Text("Post Text"),
                horizontalTitleGap: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Be informed that whatever you post should be christian related and must uphold christian virtues.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
