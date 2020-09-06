import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallyapp/wallpaper_view.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ExploreScreen extends StatefulWidget {
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  final Firestore _db = Firestore.instance;

/*
 var images = [
    "https://images.unsplash.com/photo-1460572894071-bde5697f7197?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1450778869180-41d0601e046e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1589258977674-a5ecbaf96ff2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1589201968286-dfb786c4f846?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1588688800872-263adfc809b7?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/flagged/photo-1553028826-ccdfc006d078?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1554200876-907f9286c2a1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/flagged/photo-1563536310477-c7b4e3a800c2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1568855300082-fb53bff46590?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
  ];
  */

  @override
  void initState() {
    Gfetch_data();
    super.initState();
  }

  void Gfetch_data() async {
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
            Row(
              children: <Widget>[
                _user != null
                    ? Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(top: 50, left: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: FadeInImage(
                            height: 50,
                            width: 50,
                            image: NetworkImage("${_user.photoUrl}"),
                            placeholder: AssetImage("assets/download.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : CircularProgressIndicator(),
              ],
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(top: 15, left: 12, bottom: 20),
              child: Text(
                "Explore",
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),
            StreamBuilder(
              stream: _db
                  .collection("Wallpaper")
                  .orderBy("date", descending: true)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                   return StaggeredGridView.countBuilder(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    itemCount: snapshot.data.documents.length,
                    //image[index] for linked date a which is available at the top
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
                              imageUrl:
                                  snapshot.data.documents[index].data["url"],
                              placeholder: (ctx, url) => Image(
                                image: AssetImage("assets/placeholder.png"),
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
            ),
          ],
        ),
      ),
    );
  }
}
