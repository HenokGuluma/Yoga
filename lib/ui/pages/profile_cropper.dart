import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:tinder_clone/models/user.dart';
import 'package:tinder_clone/repositories/userRepository.dart';
import 'package:tinder_clone/ui/pages/profile_image_zoomer.dart';




class ProfileCropper extends StatefulWidget {
  Uint8List thumbnail;
  String currentUser;
  File imageFile;
  File sample;
  double aspectRatio;
  bool original;
  DocumentReference reference;
  bool profile;
  final UserRepository userRepository;
  String id;
  ProfileCropper({this.userRepository, this.id, this.reference, this.original, this.thumbnail, this.aspectRatio, this.profile, this.imageFile, this.sample, this.currentUser});
  @override
  _ProfileCropperState createState() => new _ProfileCropperState();
}

class _ProfileCropperState extends State<ProfileCropper> {
  final cropKey = GlobalKey<CropState>();
  File _file;
  File _sample;
  File _lastCropped;
  bool loading = false;

  @override
  void dispose() {
    super.dispose();
    _file?.delete();
    _sample?.delete();
    _lastCropped?.delete();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            brightness: Brightness.light,
            toolbarHeight: 40,
            centerTitle: true,
            title: Text('Crop your picture', style: TextStyle(color: Colors.blue, fontSize: 16),),
          ),
          body: _buildCroppingImage(),
          backgroundColor: Colors.white,
        )
    );
  }

  Future<double>getAspectRatio(File imageFile)async{
    double aspectRatio;
    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    aspectRatio = decodedImage.width/decodedImage.height;
    return aspectRatio;
  }

  Widget _buildCroppingImage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(widget.sample, key: cropKey),
        ),
        Container(
          padding: const EdgeInsets.only(top: 30.0, bottom: 10),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(onPressed: (){
                Navigator.pop(context);
              },
                  child: Container(
                    width: 90.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(color: Colors.blue)),
                    child: Center(
                      child: Text('Back',
                          style: TextStyle(color: Colors.white)),
                    ),
                  )),
              loading
                  ? TextButton(onPressed: null,
                  child: Container(
                    width: 90.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4.0),
                     ),
                    child: Center(
                      child: Text('Next',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ))
                  :TextButton(
                  child: Container(
                    width: 90.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(color: Colors.blue)),
                    child: Center(
                      child: Text('Next',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      loading = true;
                    });
                    _cropImage().then((value) {
                      getAspectRatio(_lastCropped).then((aspect) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // builder: ((context) => ImageZoomer(imageFile: image, original: widget.original, reference: widget.reference,))
                            // ignore: missing_return
                            builder: (_) {
                              return Profile(userRepository: widget.userRepository, id: widget.id, profile: widget.profile, imageFile: _lastCropped.readAsBytesSync(), original: widget.original, reference: widget.reference, thumnailFile: widget.thumbnail, aspectRatio: aspect, currentUserID: widget.currentUser,);
                              //return ImageZoomer(imageFile: _lastCropped, original: widget.original, reference: widget.reference, thumnailFile: widget.thumbnail, aspectRatio: aspect);
                              // If this is an image, navigate to ImageScreen
                              //return ImageScreen(imageFile: asset.file);

                            },
                          ),
                        );
                      });
                    });
                  }
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: widget.imageFile,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    sample.delete();

    _lastCropped?.delete();
    _lastCropped = file;

    debugPrint('$file');
  }
}
