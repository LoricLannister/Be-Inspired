import 'package:be_inspired/helpers/user_model.dart' as us;
import 'package:be_inspired/pages/chat.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListOfUsers extends StatefulWidget {
  const ListOfUsers({Key? key}) : super(key: key);

  @override
  State<ListOfUsers> createState() => _ListOfUsersState();
}

class _ListOfUsersState extends State<ListOfUsers> {
  final TextEditingController username = TextEditingController();
  QuerySnapshot? searchResults;
  String? search;

  Future<QuerySnapshot?> startSearching(String name) async {
    QuerySnapshot? allFoundUsers = await FirebaseFirestore.instance
        .collection('users')
        .where("name", isLessThanOrEqualTo: name.trim())
        .get();
    if (mounted) {
      setState(() {
        searchResults = allFoundUsers;
      });
    }
    return allFoundUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: EdgeInsets.only(bottom: 4),
          child: TextFormField(
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            controller: username,
            decoration: InputDecoration(
              hintText: "Find an app member",
              hintStyle: TextStyle(
                color: Colors.white70,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              filled: true,
              prefixIcon: Icon(
                Icons.person_pin,
                color: Colors.white,
                size: 30,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  username.clear();
                },
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
              ),
            ),
            onFieldSubmitted: (v) {
              if (v.isNotEmpty) {
                setState(() {
                  search = v;
                });
                startSearching(v);
              }
            },
          ),
        ),
        centerTitle: true,
        elevation: 20,
        backgroundColor: Colors.purple,
      ),
      body: search != null ? usersFoundResults() : noSearchResult(),
    );
  }

  Widget usersFoundResults() {
    return FutureBuilder<QuerySnapshot?>(
        future: startSearching(search!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.purple),
              ),
            );
          }
          List<UserResult> users = [];
          snapshot.data!.docs.forEach((document) {
            us.User oneUser = us.User.fromDocument(document);
            UserResult userResult = UserResult(oneUser: oneUser);
            if (FirebaseAuth.instance.currentUser!.uid != document.id) {
              users.add(userResult);
            }
          });
          return ListView(
            children: users,
          );
        });
  }

  Widget noSearchResult() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(
              Icons.group,
              size: 200,
              color: Colors.purpleAccent,
            ),
            Text(
              "Search members",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.purpleAccent,
                  fontSize: 40,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  final us.User oneUser;
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
