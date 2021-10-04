import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tinder_clone/repositories/userRepository.dart';
import 'package:tinder_clone/ui/pages/profile_cropper.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:tinder_clone/models/user.dart';


class Profile_picture extends StatefulWidget {
  @override
  _Profile_pictureState createState() => _Profile_pictureState();
  bool original; bool profile;
  DocumentReference reference;
  String currentUser;
  UserRepository userRepository;
  String id;
  Profile_picture({this.original, this.reference, this.currentUser, this.profile, this.id, this.userRepository});
}

// ignore: camel_case_types
class _Profile_pictureState extends State<Profile_picture> {
  // This will hold all the assets we fetched
  List<AssetEntity> assets = [];

  @override
  void initState() {
    _fetchAssets();
    super.initState();
  }

  _fetchAssets() async {
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(onlyAll: true, type: RequestType.image);
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1000000, // end at a very big index (to get all the assets)
    );

    // Update the state and notify UI
    setState(() => assets = recentAssets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed:(){
            Navigator.pop(context);
          },
        ),
        title: Text('Photo Gallery', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w400),),
        backgroundColor: Colors.white,
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // A grid view with 3 items per row
          crossAxisCount: 3,
        ),
        itemCount: assets.length,
        itemBuilder: (_, index) {
          return AssetThumbnail(id: widget.id, userRepository: widget.userRepository, profile: widget.profile, asset: assets[index], original: widget.original, reference: widget.reference, currentUser: widget.currentUser,/* original: widget.original, reference: widget.reference,*/);
        },
      ),
    );
  }
}
class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({
    Key key,
    @required this.asset, @required this.original, @required this.reference,
    @required this.currentUser, @required this.profile, @required this.userRepository, @required this.id
  }) : super(key: key);
  final AssetEntity asset;
  final bool original;
  final DocumentReference reference;
  final String currentUser;
  final bool profile;
  final UserRepository userRepository;
  final String id;

  // ignore: missing_return
  Future<double>getAspectRatio(File imageFile)async{
    double aspectRatio;
    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    aspectRatio = decodedImage.width/decodedImage.height;
    return aspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    // We're using a FutureBuilder since thumbData is a future
    return FutureBuilder<Uint8List>(
      future: asset.thumbData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return Center();
        // If there's data, display it as an image
        return InkWell(
          onTap: () {
            print('stage0');
            asset.file.then((images) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => ProfileCropper(userRepository: userRepository, id: id, original: original, profile: profile, reference: reference, thumbnail: bytes, imageFile: images, sample: images, currentUser: currentUser,))));
            });
          },


          child: Stack(
            children: [
              // Wrap the image in a Positioned.fill to fill the space
              Positioned.fill(
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
              // Display a Play icon if the asset is a video
              if (asset.type == AssetType.video)
                Center(
                  child: Container(
                    //color: Colors.blue,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}



class ImageScreen extends StatelessWidget {
  const ImageScreen({
    Key key,
    @required this.imageFile,
  }) : super(key: key);

  final Future<File> imageFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: FutureBuilder<File>(
        future: imageFile,
        builder: (_, snapshot) {
          final file = snapshot.data;
          if (file == null) return Container();
          return Image.file(file);
        },
      ),
    );
  }
}

