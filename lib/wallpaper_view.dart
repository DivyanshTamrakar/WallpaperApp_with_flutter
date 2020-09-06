import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class WallpaperScreeen extends StatefulWidget {
  final DocumentSnapshot data;

  WallpaperScreeen({this.data});

  @override
  _WallpaerScreenState createState() => _WallpaerScreenState();
}

class _WallpaerScreenState extends State<WallpaperScreeen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  bool check = false;

  @override
  Widget build(BuildContext context) {
    List<dynamic> tags = widget.data["tags"].toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Container(
                child: Hero(
                  tag: widget.data["url"],
                  child: CachedNetworkImage(
                    imageUrl: widget.data["url"],
                    placeholder: (ctx, url) => Image(
                      image: AssetImage("assets/placeholder.png"),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20, left: 10),
                child: Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                      );
                    }).toList()),
              ),
              Container(
                margin: EdgeInsets.only(top: 20, left: 0),
                child: Wrap(
                  spacing: 5,
                  children: <Widget>[
                    RaisedButton.icon(
                      onPressed: () {
                        _launchURL();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 10,
                      splashColor: Colors.orange,
                      icon: Icon(Icons.image),
                      label: Text("Get Wallpaper"),
                    ),
                    RaisedButton.icon(
                      onPressed: () {},
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 10,
                      splashColor: Colors.orange,
                      icon: Icon(Icons.share),
                      label: Text("Share"),
                    ),
                    RaisedButton.icon(
                      onPressed: () {
                        addtofavorite();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 10,
                      splashColor: Colors.orange,
                      icon: Icon(Icons.favorite_border),
                      label: Text("Favorite"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL() async {
    try {
      await launch(widget.data["url"],
          option: CustomTabsOption(
            toolbarColor: Colors.blue,
          ));
    } catch (e) {}
  }

  void addtofavorite() async {
    FirebaseUser user = await _auth.currentUser();

    String uid = user.uid;

    _db
        .collection("user")
        .document(uid)
        .collection("favorites")
        .document(widget.data.documentID)
        .setData(widget.data.data);
  }
}
