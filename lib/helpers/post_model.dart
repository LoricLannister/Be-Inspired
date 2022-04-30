import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? about, postUrl, originName, originUrl, id;
  bool? photo, video, text;
  List<dynamic>? commentModel;
  List<dynamic>? likers;
  DateTime? createdOn;
  int? likes;

  PostModel({
    this.about,
    this.createdOn,
    this.postUrl,
    this.likers,
    this.originName,
    this.originUrl,
    this.photo,
    this.video,
    this.text,
    this.id,
    this.likes,
    this.commentModel,
  });
  PostModel.fromJson(Map<String, dynamic> json) {
    about = json['about'];
    createdOn = json['createdOn'] != null
        ? (json['createdOn'] as Timestamp).toDate()
        : null;
    originName = json['originName'];
    originUrl = json['originUrl'];
    postUrl = json['postUrl'];
    video = json['video'];
    photo = json['photo'];
    text = json['text'];
    id = json['id'];
    likes = json['likes'];
    likers = json['likers'];
    commentModel = json['comments'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['about'] = this.about;
    data['createdOn'] = this.createdOn;
    data['originName'] = this.originName;
    data['originUrl'] = this.originUrl;
    data['postUrl'] = this.postUrl;
    data['video'] = this.video;
    data['photo'] = this.photo;
    data['text'] = this.text;
    data['likes'] = this.likes;
    data['likers'] = this.likers;
    data['id'] = this.id;
    data['comments'] = this.commentModel;
    return data;
  }
}
