import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../wallpaper_view.dart';

class FavoriteScreen extends StatefulWidget {
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  final Firestore _db = Firestore.instance;


  @override
  void initState() {
    _getuser();
    super.initState();
  }

  void _getuser() async {
    FirebaseUser u = await _auth.currentUser();
    setState(() {
      _user = u;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(top: 15, left: 12, bottom: 20),
              child: Text(
                "Favorites",
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),
            _user != null
                ? StreamBuilder(
                    stream:  _db
                        .collection("user")
                        .document(_user.uid)
                        .collection("favorites")

                        .orderBy("date", descending: true)
                        .snapshots(),
                    builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return StaggeredGridView.countBuilder(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          staggeredTileBuilder: (int index) =>
                              StaggeredTile.fit(1),
                          itemCount: snapshot.data.documents.length,
                          //image[index] for linked date awhich is available at the top
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          itemBuilder: (ctx, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WallpaperScreeen(
                                              data: snapshot
                                                  .data.documents[index],
                                            )));
                              },
                              child: Hero(
                                tag: snapshot.data.documents[index].data["url"],
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: snapshot
                                        .data.documents[index].data["url"],
                                    placeholder: (ctx, url) => Image(
                                      image:
                                          AssetImage("assets/placeholder.png"),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return SpinKitFadingCircle(
                        color: Colors.red,
                        size: 50,
                      );
                    },
                  )
                : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
