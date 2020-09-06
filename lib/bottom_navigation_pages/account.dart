import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallyapp/add_wallpaper_screen.dart';

import '../wallpaper_view.dart';

class AccountScreen extends StatefulWidget {
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  final Firestore _db = Firestore.instance;

  /*var images = [
    "https://images.unsplash.com/photo-1460572894071-bde5697f7197?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1450778869180-41d0601e046e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1589258977674-a5ecbaf96ff2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1589201968286-dfb786c4f846?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1588688800872-263adfc809b7?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/flagged/photo-1553028826-ccdfc006d078?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1554200876-907f9286c2a1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/flagged/photo-1563536310477-c7b4e3a800c2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1568855300082-fb53bff46590?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
  ];*/

  @override
  void initState() {
    fetch_data();
    super.initState();
  }

  void fetch_data() async {
    FirebaseUser u = await _auth.currentUser();
    setState(() {
      _user = u;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _user != null
          ? Container(
        child: Stack(
          children: <Widget>[
            Image(
              image: AssetImage("assets/div.png"),
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              fit: BoxFit.cover,
            ),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              margin: EdgeInsets.only(top: 100),
              child: Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: FadeInImage(
                      height: 180,
                      width: 180,
                      image: NetworkImage("${_user.photoUrl}"),
                      placeholder: AssetImage("assets/download.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      _user.displayName,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: RaisedButton(
                      onPressed: () {
                        _auth.signOut();
                      },
                      child: Text("Logout"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20, left: 25, bottom: 10),
                        child: Text(
                          "My Wallpapers",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20, right: 10, bottom: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddWallpaperScreen(),
                                  fullscreenDialog: true,
                                ));
                          },
                        ),
                      ),
                    ],
                  ),
                  StreamBuilder(
                    stream: _db
                        .collection("Wallpaper")
                        .where("Uploaded by",
                        isEqualTo: _user
                            .uid) // kyunki specific user ka spseific wallpaper
                        .orderBy("date", descending: true)
                        .snapshots(),
                    builder:
                        (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                        builder: (context) =>
                                            WallpaperScreeen(
                                              data: snapshot
                                                  .data
                                                  .documents[index]
                                              ,
                                            )));
                              },
                              child: Stack(
                                children: <Widget>[
                                  Hero(
                                    tag: snapshot.data.documents[index]
                                        .data["url"],
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: snapshot.data
                                            .documents[index].data["url"],
                                        placeholder: (ctx, url) =>
                                            Image(
                                              image: AssetImage(
                                                  "assets/placeholder.png"),
                                            ),
                                        errorWidget:
                                            (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomLeft,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              return AlertDialog(
                                                shape:
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(16),
                                                ),
                                                title: Text(
                                                    "Are you sure ?"),
                                                content: Text(
                                                    "you want to delete this item"),
                                                actions: <Widget>[
                                                  RaisedButton(
                                                    child: Text("Delete"),
                                                    onPressed: () {
                                                      _db
                                                          .collection(
                                                          "Wallpaper")
                                                          .document(snapshot
                                                          .data
                                                          .documents[
                                                      index]
                                                          .documentID)
                                                          .delete();
                                                      Navigator.of(
                                                          context)
                                                          .pop();
                                                    },
                                                    color: Colors.blue,
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          16),
                                                    ),
                                                  ),
                                                  FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                          context)
                                                          .pop();
                                                    },
                                                    child: Text("Cancel"),
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          16),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                    ),
                                  ),
                                ],
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

                  /*StaggeredGridView.countBuilder(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          staggeredTileBuilder: (int index) =>
                              StaggeredTile.fit(1),
                          itemCount: images.length,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          itemBuilder: (ctx, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image(
                                image: NetworkImage(images[index]),
                              ),
                            );
                          },
                        ),*/
                ],
              ),
            ),
          ],
        ),
      )
          : CircularProgressIndicator(),
    );
  }
}
