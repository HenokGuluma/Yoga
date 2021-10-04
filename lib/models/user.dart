import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String fullName;
  String gender;
  String interestedIn;
  String photo;
  Timestamp age;
  GeoPoint location;
  bool verified;
  String bio = '';

  User(
      {this.uid,
        this.fullName,
        this.gender,
        this.interestedIn,
        this.photo,
        this.age,
        this.location,
        this.verified,
        this.bio
      });
}
