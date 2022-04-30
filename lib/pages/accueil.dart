import 'package:be_inspired/helpers/post_model.dart';
import 'package:be_inspired/helpers/shimmer_widget.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class Accueil extends StatefulWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController message = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String? postId;
  Stream<List<PostModel>> readPost() => FirebaseFirestore.instance
      .collection('posts')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => PostModel.fromJson(doc.data())).toList());

  likes(PostModel post) {
    try {
      if (post.likers!.contains(user!.displayName) == false) {
        post.likers!.add(user!.displayName);
        FirebaseFirestore.instance.collection('posts').doc(post.id!).set(
            {"likes": post.likes! + 1, "likers": post.likers},
            SetOptions(merge: true));
      } else if (post.likers!.contains(user!.displayName) == true) {
        post.likers!.remove(user!.displayName);
        FirebaseFirestore.instance.collection('posts').doc(post.id).set(
            {"likes": post.likes! - 1, "likers": post.likers},
            SetOptions(merge: true));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No internet connection, unable to like or dislike",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  sendMessage(PostModel post, String msg) {
    message.clear();
    post.commentModel!.add({
      "comment": msg,
      "originUrl": post.originUrl,
      "originName": post.originName,
    });
    FirebaseFirestore.instance.collection('posts').doc(postId).set(
      {"comments": post.commentModel},
      SetOptions(merge: true),
    );
  }

  addComment(BuildContext context, PostModel post) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          postId = post.id;
          return Container(
            height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 5,
                    ),
                    child: Text(
                      "Add comment",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            padding: EdgeInsets.only(left: 15),
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade200,
                            ),
                            child: Center(
                              child: TextField(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                                controller: message,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Type your comment here ...",
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                focusNode: focusNode,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: IconButton(
                            onPressed: () {
                              if (message.text.isNotEmpty) {
                                sendMessage(post, message.text);
                              }
                            },
                            icon: Icon(Icons.send),
                            color: Colors.purpleAccent,
                          ),
                        ),
                        color: Colors.white,
                      ),
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 2 - 80,
                    child: post.commentModel!.isEmpty
                        ? Center(
                            child: Text(
                                "There are actually no comments to display"),
                          )
                        : ListView(
                            children: buildComment(post.commentModel!)!,
                          ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    readPost();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Be Inspired"),
        centerTitle: true,
        elevation: 20,
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: readPost(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Unable to load posts"));
          } else if (snapshot.hasData) {
            final posts = snapshot.data;
            return posts!.isEmpty
                ? Center(
                    child: Text(
                      "There are actually no post to display",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  )
                : ListView(
                    children: posts.map(buildPost).toList(),
                  );
          } else {
            return buildPostShimmer();
          }
        },
      ),
    );
  }

  List<Widget>? buildComment(List<dynamic> comments) {
    List<Widget>? commentsList = [];
    for (var comment in comments) {
      commentsList.add(
        Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 30),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              color: Colors.purple.shade100,
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 10, right: 10, bottom: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple,
                    radius: 24,
                    backgroundImage: comment['originUrl'] != ''
                        ? CachedNetworkImageProvider(comment['originUrl']!)
                        : null,
                  ),
                  title: Text(comment['comment']),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return commentsList;
  }

  Widget buildPost(PostModel post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Container(
        height: 315,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.purple,
                backgroundImage: post.originUrl != null
                    ? NetworkImage(post.originUrl!)
                    : null,
              ),
              horizontalTitleGap: 10,
              title: Text(
                post.originName!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                post.text == null ? post.about! : "Have published this text",
                maxLines: 1,
              ),
              trailing: Text(
                post.createdOn.toString().substring(0, 10),
                style: TextStyle(fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: post.video == true
                  ? AspectRatio(
                      aspectRatio: 16 / 10,
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
                        child: BetterPlayer.network(
                          post.postUrl!,
                          betterPlayerConfiguration: BetterPlayerConfiguration(
                            aspectRatio: 16 / 10,
                          ),
                        ),
                      ),
                    )
                  : (post.photo == true
                      ? Image.network(
                          post.postUrl!,
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext, Object, StackTrace) {
                            return Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Center(
                                  child: Text(
                                      "Unable to load image, check internet connection."),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Text(post.about!),
                            ),
                          ),
                        )),
            ),
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      likes(post);
                    },
                    icon: Icon(
                      Icons.favorite,
                      color: post.likers!.contains(user!.displayName)
                          ? Colors.purple
                          : Colors.grey,
                    ),
                    label: Text(
                      post.likers!.length > 1
                          ? "${post.likers!.length} Likes"
                          : "${post.likers!.length} Like",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      addComment(context, post);
                    },
                    icon: Icon(
                      Icons.add_comment,
                      color: Colors.grey,
                    ),
                    label: Text(
                      "Comments",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      if (post.photo != null || post.video != null) {
                        Share.share(post.postUrl!);
                      } else {
                        Share.share(post.about!);
                      }
                    },
                    icon: Icon(
                      Icons.share,
                      color: Colors.grey,
                    ),
                    label: Text(
                      "Share",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPostShimmer() {
    return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            height: 290,
            child: Column(
              children: [
                ListTile(
                  leading: ShimmerWidget.circular(height: 50, width: 50),
                  horizontalTitleGap: 10,
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: ShimmerWidget.rectangular(
                        width: MediaQuery.of(context).size.width / 3,
                        height: 18),
                  ),
                  subtitle: ShimmerWidget.rectangular(height: 14),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                  child: ShimmerWidget.rectangular(height: 180),
                ),
              ],
            ),
          );
        });
  }
}
