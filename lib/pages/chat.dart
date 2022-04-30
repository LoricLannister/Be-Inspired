import 'package:be_inspired/helpers/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as us;
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  final User? receiverUser;
  const Chat({Key? key, this.receiverUser}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  QuerySnapshot? users;
  Future<QuerySnapshot?> getUsers() async {
    QuerySnapshot? allFoundUsers =
        await FirebaseFirestore.instance.collection('users').get();
    if (mounted) {
      setState(() {
        users = allFoundUsers;
      });
    }
    return allFoundUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.receiverUser != null
          ? AppBar(
              title: Text(
                widget.receiverUser!.name!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              elevation: 20,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: CircleAvatar(
                    backgroundColor: Colors.white60,
                    backgroundImage: widget.receiverUser!.photoUrl != ''
                        ? CachedNetworkImageProvider(
                            widget.receiverUser!.photoUrl!)
                        : null,
                  ),
                )
              ],
              backgroundColor: Colors.purple,
            )
          : AppBar(
              title: Text("Discussions"),
              centerTitle: true,
              elevation: 20,
              backgroundColor: Colors.purple,
            ),
      body: widget.receiverUser != null
          ? ChatScreen(receiverUser: widget.receiverUser)
          : availableDiscussions(),
    );
  }

  Widget availableDiscussions() {
    // We need to load last started discussions.
    return FutureBuilder<QuerySnapshot?>(
      future: getUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Unable to load recent discussion",
              style: TextStyle(color: Colors.black),
            ),
          );
        } else if (snapshot.hasData) {
          List<UserResult> users = [];
          snapshot.data!.docs.forEach((document) {
            User oneUser = User.fromDocument(document);
            UserResult userResult = UserResult(oneUser: oneUser);
            if (us.FirebaseAuth.instance.currentUser!.uid != document.id) {
              users.add(userResult);
            }
          });
          return users.isEmpty
              ? Center(
                  child: Text(
                    "There are actually no discussion to display",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              : ListView(
                  children: users,
                );
        } else {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.purple),
            ),
          );
        }
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  final User? receiverUser;
  const ChatScreen({Key? key, this.receiverUser}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController message = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  us.User? user = us.FirebaseAuth.instance.currentUser;
  String chatId = "";
  var listMessage;

  @override
  void initState() {
    super.initState();
    if (widget.receiverUser != null) {
      if (user!.uid.hashCode <= widget.receiverUser!.idUser.hashCode) {
        chatId = '${user!.uid}-${widget.receiverUser!.idUser}';
      } else {
        chatId = '${widget.receiverUser!.idUser}-${user!.uid}';
      }
      FirebaseFirestore.instance.collection("users").doc(user!.uid).set(
          {'chattingWith': widget.receiverUser!.idUser},
          SetOptions(merge: true));
      setState(() {});
    }
  }

  sendMessage(String msg) {
    message.clear();
    var docRef = FirebaseFirestore.instance
        .collection("messages")
        .doc(chatId)
        .collection(chatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());
    FirebaseFirestore.instance.runTransaction((transaction) async {
      await transaction.set(
        docRef,
        {
          "idFrom": user!.uid,
          "idTo": widget.receiverUser!.idUser,
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "content": msg,
        },
      );
    });
    scrollController.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  bool isLastMsgLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idFrom"] == user!.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMsgRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idFrom"] != user!.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Stack(
          children: [
            Column(
              children: [
                createListMessages(),
                createInput(),
              ],
            ),
          ],
        ),
        onWillPop: null);
  }

  Widget createListMessages() {
    return Flexible(
      child: chatId == ""
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.purpleAccent),
              ),
            )
          : StreamBuilder<QuerySnapshot?>(
              stream: FirebaseFirestore.instance
                  .collection("messages")
                  .doc(chatId)
                  .collection(chatId)
                  .orderBy(
                    "timestamp",
                    descending: true,
                  )
                  .limit(30)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.purpleAccent),
                    ),
                  );
                } else {
                  listMessage = snapshot.data!.docs;
                  return listMessage == []
                      ? Center(
                          child: Text(
                            "Internet connection problem",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          controller: scrollController,
                          padding: EdgeInsets.all(10),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) => createItem(
                            index,
                            snapshot.data!.docs[index],
                          ),
                        );
                }
              }),
    );
  }

  Widget createItem(int index, DocumentSnapshot documentSnapshot) {
    if (documentSnapshot['idFrom'] == user!.uid) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            child: Text(
              documentSnapshot['content'],
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            width: 200,
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.only(
                bottom: isLastMsgRight(index) ? 20 : 10, right: 10),
          ),
        ],
      );
    } else {
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                isLastMsgLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.purple),
                              ),
                            ),
                            height: 35,
                            width: 35,
                            padding: EdgeInsets.all(10),
                          ),
                          imageUrl: widget.receiverUser!.photoUrl!,
                          height: 35,
                          width: 35,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: 35,
                      ),
                Container(
                  child: Text(
                    documentSnapshot['content'],
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w400),
                  ),
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.only(left: 10),
                ),
              ],
            ),
            isLastMsgLeft(index)
                ? Container(
                    child: Text(
                      DateTime.fromMillisecondsSinceEpoch(
                              int.tryParse(documentSnapshot["timestamp"])!)
                          .toString(),
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                    margin: EdgeInsets.only(top: 50, left: 50, bottom: 5),
                  )
                : Container(),
          ],
        ),
      );
    }
  }

  Widget createInput() {
    return Container(
      child: Row(
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 15),
              child: TextField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
                controller: message,
                decoration: InputDecoration.collapsed(
                  hintText: "Type your message here ...",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                onPressed: () {
                  if (message.text.isNotEmpty) {
                    sendMessage(message.text);
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
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
          color: Colors.white),
    );
  }
}

class UserResult extends StatelessWidget {
  final User oneUser;
  const UserResult({Key? key, required this.oneUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Chat(receiverUser: oneUser),
                  ),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple,
                  radius: 25,
                  backgroundImage: oneUser.photoUrl != ''
                      ? CachedNetworkImageProvider(oneUser.photoUrl!)
                      : null,
                ),
                title: Text(
                  oneUser.name!,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(oneUser.email!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
