import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AddWallpaperScreen extends StatefulWidget {
  @override
  _AddWallpaperScreenState createState() => _AddWallpaperScreenState();
}

class _AddWallpaperScreenState extends State<AddWallpaperScreen> {
  File _image;
  final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
  List<ImageLabel> detectedlables;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isUploading = false;
  bool _isCompleteUploading = false;
  var lst = new List();

  @override
  void dispose() {
    labeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Wallpaper "),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  load();
                },
                child: _image != null
                    ? Image.file(_image)
                    : Image(
                        image: AssetImage("assets/placeholder.png"),
                        width: MediaQuery.of(context).size.width,
                      ),
              ),
              Wrap(alignment: WrapAlignment.center, children: [
                InkWell(
                  onTap: () {
                    load();
                  },
                  child: Text(
                    "Click The Image to upload a wallpaper",
                    style: TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                )
              ]),
              SizedBox(
                height: 20,
              ),
              detectedlables != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                          spacing: 10,
                          children: detectedlables.map((label) {
                            return Chip(
                              label: Text(label.text),
                            );
                          }).toList()),
                    )
                  : Container(),
              // ignore: sdk_version_ui_as_code
              if (_isUploading) ...[Text("Uplaoding Wallpaper")],
              // ignore: sdk_version_ui_as_code
              if (_isCompleteUploading) ...[Text("Uplaoding Completed")],
              RaisedButton(
                onPressed: () {
                  upload_wallpaper();
                },
                child: Text("Upload Wallpaper"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void load() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 30);
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);

    List<ImageLabel> labels = await labeler.processImage(visionImage);

    for (var i in labels) {
      lst.add(i.text);
    }

    print(lst);

    setState(() {
      detectedlables = labels;
      _image = image;
    });
  }

  // ignore: non_constant_identifier_names
  void upload_wallpaper() async {
    if (_image != null) {
      String filename =
          path.basename(_image.path); // convert image to image link.
      print(" File: " + filename);

      FirebaseUser user = await _auth.currentUser();
      String uid = user.uid;
      StorageUploadTask task = _storage
          .ref()
          .child("wallpapers")
          .child(uid)
          .child(filename)
          .putFile(_image);

      task.events.listen((e) async {
        if (e.type == StorageTaskEventType.progress) {
          setState(() {
            _isUploading = true;
          });
        }
        if (e.type == StorageTaskEventType.success) {
          setState(() {
            _isCompleteUploading = true;
            _isUploading = false;
          });

          e.snapshot.ref.getDownloadURL().then((url) {
            _db.collection("Wallpaper").add({
              "url": url,
              "date": DateTime.now(),
              "Uploaded by": uid,
              "tags": lst,
            });

            Navigator.of(context).pop();
          });
        }
      });
    } else {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text("Error"),
              content: Text("while selecting your photo"),
              actions: <Widget>[
                Container(
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text("Ok"),
                  ),
                ),
              ],
            );
          });
    }
  }
}
