import 'package:tinder_clone/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchesRepository {
  final FirebaseFirestore _firestore;

  MatchesRepository({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMatchedList(userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('matchedList')
        .snapshots();
  }

  Stream<QuerySnapshot> getSelectedList(userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('selectedList')
        .snapshots();
  }

  Future<User> getUserDetails(userId) async {
    User _user = User();

    await _firestore.collection('users').doc(userId).get().then((user) {
      _user.uid = user.id;
      _user.fullName = user['fullName'];
      _user.photo = user['photoUrl'];
      _user.age = user['age'];
      _user.bio = user['bio'];
      _user.verified = user['verified'];
      _user.location = user['location'];
      _user.gender = user['gender'];
      _user.interestedIn = user['interestedIn'];
    });

    return _user;
  }

  Future openChat({currentUserId, selectedUserId}) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(selectedUserId)
        .set({'timestamp': DateTime.now()});

    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('chats')
        .doc(currentUserId)
        .set({'timestamp': DateTime.now()});

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('matchedList')
        .doc(selectedUserId)
        .delete();

    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('matchedList')
        .doc(currentUserId)
        .delete();
  }

  void deleteUser(currentUserId, selectedUserId) async {
    return await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('selectedList')
        .doc(selectedUserId)
        .delete();
  }

  Future selectUser(currentUserId, selectedUserId, currentUserName,
      currentUserPhotoUrl, selectedUserName, selectedUserPhotoUrl) async {
    deleteUser(currentUserId, selectedUserId);

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('matchedList')
        .doc(selectedUserId)
        .set({
      'name': selectedUserName,
      'photoUrl': selectedUserPhotoUrl,
    });

    return await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('matchedList')
        .doc(currentUserId)
        .set({
      'name': currentUserName,
      'photoUrl': currentUserPhotoUrl,
    });
  }
  Future<List<String>> getMatchedUsers(userId) async {
    List<String> returnedUsers =[];
    await _firestore.collection('users').doc(userId).collection('matchedList').limit(100).get().then((users) {
      for (int i=0; i<users.docs.length; i++) {
        returnedUsers.add(users.docs[i].id);
      }
    });
    return returnedUsers;
  }
  Future<List<String>> getLikes(userId) async {
    List<String> matchedList = await getMatchedUsers(userId);
    List<String> returnedUsers =[];
    await _firestore.collection('users').doc(userId).collection('selectedList').limit(100).get().then((users) {
      for (int i=0; i<users.docs.length; i++) {
        if(!matchedList.contains(users.docs[i].id)){
          returnedUsers.add(users.docs[i].id);
        }
      }
    });
    return returnedUsers;
  }
}
