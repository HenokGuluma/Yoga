import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tinder_clone/models/user.dart';

class UserRepository {
  final auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserRepository({auth.FirebaseAuth auths, FirebaseFirestore firestore})
      : _auth = auths ?? auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;
  //Sign in
  Future<void> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  //First time user registration
  Future<bool> isFirstTime(String userId) async {
    bool exist;
    await _firestore.collection('users').doc(userId).get().then((user) {
      exist = user.exists;
    });
    return exist;
  }

  //Sign up
  Future<void> signUpWithEmail(String email, String password) async {
    print(_auth);
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  //Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
  Future<void> updateDetails(
      String uid, String fullName, String bio, Timestamp age) async {
    Map<String, dynamic> map = Map();
    map['age'] = age;
    map['fullName'] = fullName;
    map['bio'] = bio;

    return _firestore.collection("users").doc(uid).update(map);
  }

  //Get currently signed-in users
  Future<bool> isSignedIn() async {
    final currentUser = _auth.currentUser;
    return currentUser != null;
  }

  //Getting userId.
  Future<String> getUser() async {
    return (await _auth.currentUser.uid);
  }

  Future<User> getCurrentUser() async {
    auth.User currentUser;
    User user;
    currentUser = _auth.currentUser;
    user = await getUserDetail(userId: currentUser.uid);
    return user;
  }
  Future<String> getCurrentUserPhoto() async {
    auth.User currentUser;
    String photo;
    currentUser = _auth.currentUser;
    photo = currentUser.photoURL;
    return photo;
  }
  Future<User> getUserDetail({userId}) async {
    User _user = User();

    await _firestore.collection('users').doc(userId).get().then((user) {
      _user.uid = user.id;
      _user.fullName = user['fullName'];
      _user.photo = user['photoUrl'];
      _user.age = user['age'];
      _user.bio = user['bio'];
      _user.location = user['location'];
      _user.gender = user['gender'];
      _user.interestedIn = user['interestedIn'];
      _user.verified = user['verified'];
    });
    return _user;
  }
  Future<List<DocumentSnapshot>> retrieveUserPhotoPosts(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("posts").get();
    return querySnapshot.docs;
  }
  Future<void> updatePhoto(String photoUrl, String uid) async {
    Map<String, dynamic> map = Map();
    map['photoUrl'] = photoUrl;
    _firestore.collection("users").doc(uid).update(map);
    return _firestore.collection("users").doc(uid).collection('previous_photos').doc(Timestamp.now().toString()).set(map);
  }
  Future<List<DocumentSnapshot>> previousPhotos(String uid) async{
    QuerySnapshot querySnapshot = await _firestore.collection('users').doc(uid).collection('previous_photos').get();
    return querySnapshot.docs;
  }

  //Profile Setup
  Future<void> profileSetup(
    File photo,
    String userId,
    String bio,
    String fullName,
    bool verified,
    String gender,
    String interestedIn,
    DateTime age,
    GeoPoint location,
  ) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child('userPhotos')
        .child(userId)
        .child(userId)
        .putFile(photo);

    return await uploadTask.then((ref) async {
      await ref.ref.getDownloadURL().then((url) async {
        await _firestore.collection('users').doc(userId).set({
          'uid': userId,
          'bio': bio,
          'photoUrl': url,
          'fullName': fullName,
          "location": location,
          'gender': gender,
          'interestedIn': interestedIn,
          'verified': verified,
          'age': age
        });
      });
    });
  }
}
