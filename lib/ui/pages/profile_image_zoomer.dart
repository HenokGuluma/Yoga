import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tinder_clone/repositories/userRepository.dart';
import 'package:tinder_clone/models/user.dart';
import 'package:tinder_clone/ui/widgets/picture_form.dart';

class Profile extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
  Uint8List imageFile;
  bool profile;
  double aspectRatio;
  Uint8List thumnailFile;
  bool original;
  DocumentReference reference;
  String currentUserID;
  final UserRepository userRepository;
  String id;
  Profile({this.id, this.userRepository, this.imageFile, this.original, this.reference, this.aspectRatio, this.thumnailFile, this.currentUserID, this.profile});
}

class ProfileState extends State<Profile> {

  File imageFile;
  bool buttonActive = false;
  var _repository = UserRepository();
  storage.Reference _storageReference;
  bool updating = false;

  @override
  void dispose() {
    super.dispose();
  }

  /// Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.dark,
          leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black,), onPressed: () {
            Navigator.pop(
                context);
          },),
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Image Preview", style: TextStyle(color: Colors.black),),
              Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: updating
                      ? Container(
                    height: 30,
                    width: 80,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: Center(
                      child: Text('Updating',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400)),
                    ),
                  )
                      :MaterialButton(
                      child: Container(
                        height: 30,
                        width: 80,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(30)
                        ),
                        child: Center(
                          child: Text('Update',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400)),
                        ),
                      ),
                      onPressed: widget.imageFile == null
                          ?(){}
                          : () {
                        setState(() {
                          updating = true;
                        });
                        print("The file is ${imageFile}");
                        compressImage().then((compressedImage) {
                          uploadImagesToStorage(compressedImage).then((url) {
                            _repository.updatePhoto(url, widget.currentUserID).then((v) {
                              Fluttertoast.showToast(
                                  msg: 'Profile Image successfully updated',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white
                              );
                              widget.profile
                              ?Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                  builder: ((context) => PictureForm(photo: url, userRepository: widget.userRepository, id: widget.id))), (Route<dynamic> route) => false,)
                              :Navigator.pop(context);
                            });
                          });
                        });
                      }
                  ))
            ],
          ),

        ),
        body: Container(
            child: widget.imageFile == null
                ? Center()
                : Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Image.memory(
                      widget.imageFile,
                      fit: BoxFit.fitHeight
                    //BoxFit.cover
                  ),
                ))));
  }

  Future<String> uploadImagesToStorage( Uint8List imageFile) async {
    _storageReference = storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    storage.UploadTask storageUploadTask = _storageReference.putData(imageFile);
    var url = await (await storageUploadTask).ref.getDownloadURL();
    return url;
  }

  Future<Uint8List> compressImage() async {
    print('starting compression');
    var result = await FlutterImageCompress.compressWithList(
      widget.imageFile,
      quality: 25,
    );
    print('done');
    return result;
  }
}