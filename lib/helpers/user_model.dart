import 'package:cloud_firestore/cloud_firestore.dart';

class UserField {
  static final String lastMessage = 'lastMessage';
}

class User {
  final String? idUser;
  final String? name;
  final String? email;
  final String? photoUrl;

  User({this.idUser, this.name, this.email, this.photoUrl});

  User copyWith({
    String? idUser,
    String? name,
    String? email,
    String? photoUrl,
  }) =>
      User(
          idUser: idUser ?? this.idUser,
          name: name ?? this.name,
          email: email ?? this.email,
          photoUrl: photoUrl ?? this.photoUrl);
  static User fromJson(Map<String, dynamic> json) => User(
        idUser: json['idUser'],
        name: json['name'],
        email: json['e-mail'],
        photoUrl: json['photoUrl'],
      );
  Map<String, dynamic> toJson() => {
        'idUser': idUser,
        'name': name,
        'e-mail': email,
        'photoUrl': photoUrl,
      };

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      idUser: doc.id,
      name: doc['name'],
      email: doc['e-mail'],
      photoUrl: doc['photoUrl'],
    );
  }
}
