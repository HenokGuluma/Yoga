import 'package:tinder_clone/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchRepository {
  final FirebaseFirestore _firestore;

  SearchRepository({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<User> chooseUser(currentUserId, selectedUserId, name, photoUrl) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chosenList')
        .doc(selectedUserId)
        .set({});

    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('chosenList')
        .doc(currentUserId)
        .set({});

    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('selectedList')
        .doc(currentUserId)
        .set({
      'name': name,
      'photoUrl': photoUrl,
    });
    return getUser(currentUserId);
  }

  passUser(currentUserId, selectedUserId) async {
    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('chosenList')
        .doc(currentUserId)
        .set({});

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chosenList')
        .doc(selectedUserId)
        .set({});
    return getUser(currentUserId);
  }
  Future<bool>chooseThisUser(currentUserId, selectedUserId, name, photoUrl) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chosenList')
        .doc(selectedUserId)
        .set({});
    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('selectedList')
        .doc(currentUserId)
        .set({
      'name': name,
      'photoUrl': photoUrl,
    });
    List<String> selectedList = await getSelectedList(currentUserId);
    if(selectedList.contains(selectedUserId)){
      _firestore
          .collection('users')
          .doc(selectedUserId)
          .collection('matchedList')
          .doc(currentUserId).set({
        'time': Timestamp.now()
      });
      _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('matchedList')
          .doc(selectedUserId).set({
        'time': Timestamp.now()
      });
      return true;
    }
    else{
      return false;
    }
  }
  Future<bool>superLikeThisUser(currentUserId, selectedUserId, name, photoUrl) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('superLikeList')
        .doc(selectedUserId)
        .set({});

    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('superLikedList')
        .doc(currentUserId)
        .set({
      'name': name,
      'photoUrl': photoUrl,
    });
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chosenList')
        .doc(selectedUserId)
        .set({});

    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('selectedList')
        .doc(currentUserId)
        .set({
      'name': name,
      'photoUrl': photoUrl,
    });
    List<String> selectedList = await getSelectedList(currentUserId);
    if(selectedList.contains(selectedUserId)){
      _firestore
          .collection('users')
          .doc(selectedUserId)
          .collection('matchedList')
          .doc(currentUserId).set({
        'time': Timestamp.now()
      });
      _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('matchedList')
          .doc(selectedUserId).set({
        'time': Timestamp.now()
      });
      return true;
    }
    else{
      return false;
    }
  }
  passThisUser(currentUserId, selectedUserId) async {
    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('chosenList')
        .doc(currentUserId)
        .set({});

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chosenList')
        .doc(selectedUserId)
        .set({});
  }

  Future getUserInterests(userId) async {
    User currentUser = User();

    await _firestore.collection('users').doc(userId).get().then((user) {
      currentUser.fullName = user['fullName'];
      currentUser.photo = user['photoUrl'];
      currentUser.gender = user['gender'];
      currentUser.interestedIn = user['interestedIn'];
      currentUser.verified = user['verified'];
      currentUser.age = user['age'];
      currentUser.bio = user['bio'];
      currentUser.verified = user['verified'];
    });
    return currentUser;
  }

  Future<List> getChosenList(userId) async {
    List<String> chosenList = [];
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('chosenList')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        chosenList.add(doc.id);
      });
    });
    return chosenList;
  }
  Future<List> getSelectedList(userId) async {
    List<String> chosenList = [];
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('selectedList')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        chosenList.add(doc.id);
      });
    });
    return chosenList;
  }

  Future<User> getUser(userId) async {
    User _user = User();
    List<String> chosenList = await getChosenList(userId);
    User currentUser = await getUserInterests(userId);

    await _firestore.collection('users').get().then((users) {
      for (var user in users.docs) {
        if ((!chosenList.contains(user.id)) &&
            (user.id != userId) &&
            (currentUser.interestedIn == user['gender']) &&
            (user['interestedIn'] == currentUser.gender)) {
          _user.uid = user.id;
          _user.fullName = user['fullName'];
          _user.photo = user['photoUrl'];
          _user.age = user['age'];
          _user.location = user['location'];
          _user.gender = user['gender'];
          _user.interestedIn = user['interestedIn'];
          _user.bio = user['bio'];
          _user.verified = user['verified'];
          break;
        }
      }
    });
    return _user;
  }
  Future<List<User>> getUsers(userId) async {
    //User _user = User();
    List<String> chosenList = await getChosenList(userId);
    User currentUser = await getUserInterests(userId);
    List<User> returnedUsers =[];
    await _firestore.collection('users').limit(10).get().then((users) {
      for (int i=0; i<users.docs.length; i++) {
        User _user = User();
        if ((!chosenList.contains(users.docs[i].id)) &&
            (users.docs[i].id != userId) /*&&
            (currentUser.interestedIn == users.docs[i]['gender']) &&
            (users.docs[i]['interestedIn'] == currentUser.gender)*/) {
          _user.uid = users.docs[i].id;
          _user.fullName = users.docs[i]['fullName'];
          _user.photo = users.docs[i]['photoUrl'];
          _user.age = users.docs[i]['age'];
          _user.location = users.docs[i]['location'];
          _user.gender = users.docs[i]['gender'];
          _user.interestedIn = users.docs[i]['interestedIn'];
          _user.bio = users.docs[i]['bio'];
          _user.verified = users.docs[i]['verified'];
          returnedUsers.add(_user);
          //break;
        }
      }
    });
    return returnedUsers;
  }
}
