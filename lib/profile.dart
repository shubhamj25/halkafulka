import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaphulka1/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class Profile extends StatefulWidget {
  final String email;
  final bool rememberMe;
  const Profile({Key key, this.email, this.rememberMe}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final bioController=TextEditingController();
  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:() {
        myFocusNode.unfocus();
      },
      child: Scaffold(
        body: StreamBuilder(
            stream: Firestore.instance.collection("users").document(widget.email.toString()).snapshots(),
            builder: (context, snapshot) {
              return snapshot.hasData?
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left:8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 35,),
                                  snapshot.data['photoURL']!=null?Material(
                                    shape: CircleBorder(),
                                    child: Container(
                                      alignment: Alignment.topCenter,
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle
                                      ),
                                      child: CachedNetworkImage(
                                          imageUrl: snapshot.data['photoURL'],
                                          fadeInDuration: Duration(milliseconds: 500),
                                          fadeInCurve: Curves.easeIn,
                                          imageBuilder: (context, imageProvider) => Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: imageProvider, fit: BoxFit.cover),
                                            ),
                                          ),
                                          placeholder: (context, url) => Padding(
                                            padding: const EdgeInsets.all(32.0),
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) => Icon(Icons.account_circle,size: 50,color: Colors.blueAccent,)
                                      ),
                                    ),
                                  ):Icon(Icons.account_circle,size: 60,color: Colors.blueAccent,),
                                  Container(height: 10,width: 2,color:Colors.blueAccent,),
                                  Container(
                                    width: 40,height: 40,
                                    child: FloatingActionButton(
                                      heroTag: 293,
                                      child: Icon(Icons.camera_alt,size: 20,),
                                      onPressed: (){

                                      },
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Container(
                                    width: 40,height: 40,
                                    child: FloatingActionButton(
                                      backgroundColor: Colors.white,
                                      heroTag: 294,
                                      child: Icon(Icons.person_add,size: 20,color: Colors.blueAccent,),
                                      onPressed: (){

                                      },
                                    ),
                                  ),

                                  SizedBox(height: 10,),
                                  Container(
                                    width: 40,height: 40,
                                    child: FloatingActionButton(
                                      heroTag: 295,
                                      child: Icon(Icons.send,size: 20,),
                                      onPressed: (){

                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width*0.8,
                              child: Padding(
                                padding: const EdgeInsets.only(top:30.0),
                                child: ListTile(
                                  isThreeLine: true,
                                  title: Stack(
                                    children: <Widget>[
                                      Text("${snapshot.data['name']}",style: GoogleFonts.balooBhai(fontSize: 22,),),
                                      Padding(
                                        padding: const EdgeInsets.only(top:28.0),
                                        child: Text("${snapshot.data['email']}",style: GoogleFonts.aBeeZee(fontSize: 16,color: Colors.grey),),
                                      ),

                                    ],
                                  ),
                                  subtitle:Column(
                                    children: <Widget>[

                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text("Followers",style: GoogleFonts.aBeeZee(fontSize: 16),),
                                                StreamBuilder(
                                                    stream: Firestore.instance.collection("users").document(loggedInEmail).snapshots(),
                                                    builder: (context, snap) {
                                                      return AnimatedCount(count: !snap.hasData?0:2342, duration:  Duration(seconds: 4));
                                                    }
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text("Following",style: GoogleFonts.aBeeZee(fontSize: 16),),
                                                StreamBuilder(
                                                    stream: Firestore.instance.collection("users").document(loggedInEmail).snapshots(),
                                                    builder: (context, snap) {
                                                      return AnimatedCount(count: !snap.hasData?0:2353, duration:  Duration(seconds: 4));
                                                    }
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:8.0),
                                          child: TextFormField(
                                            style: GoogleFonts.aBeeZee(fontSize: 17,color: Colors.black54),
                                            initialValue: snapshot.data['bio']??"Edit your Bio from here.\nThis is public so make sure you don't add something inappropriate.",
                                            maxLines: 10,
                                            minLines: 1,
                                            focusNode: myFocusNode,
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: <Widget>[

                              ],
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0,right:8),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(icon:
                            Icon(Icons.settings,color: Colors.blueGrey,size: 30,),
                              onPressed: (){

                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0,right:50),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(icon: Icon(Icons.exit_to_app,color: Colors.redAccent,size: 30,),
                              onPressed: () async {
                                if(!widget.rememberMe){
                                  signOutGoogle();
                                  loggedInEmail=null;
                                  loggedInPassword=null;
                                  facebookLogin.logOut();
                                  final prefs = await SharedPreferences.getInstance();
                                  prefs.remove('loggedInEmail');
                                  prefs.remove('loggedInPassword');
                                }
                                Navigator.of(context).pushReplacement(new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Login()));
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                        alignment: Alignment.topCenter,
                        height: 500,
                        child: PreviousPosts()),
                  ],
                ),
              ):Center(child: CircularProgressIndicator(strokeWidth: 3,));
            }
        ),
      ),
    );
  }
}


class PreviousPosts extends StatefulWidget {
  @override
  _PreviousPostsState createState() => _PreviousPostsState();
}

class _PreviousPostsState extends State<PreviousPosts> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 3,
          child: Scaffold(

            appBar:TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.blueAccent,
              tabs: [
                Tab(icon: Icon(Icons.video_library),),
                Tab(icon: Icon(Icons.thumb_up)),
                Tab(icon: Icon(Icons.drafts)),
              ],
            ),
            body: TabBarView(
              children: [
                Icon(Icons.video_library),
                Icon(Icons.thumb_up),
                Icon(Icons.drafts),
              ],
            ),
          ),
        )
    );
  }
}

class AnimatedCount extends ImplicitlyAnimatedWidget {
  final int count;

  AnimatedCount({
    Key key,
    @required this.count,
    @required Duration duration,
    Curve curve = Curves.linear
  }) : super(duration: duration, curve: curve, key: key);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends AnimatedWidgetBaseState<AnimatedCount> {
  IntTween _count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: new Text(_count.evaluate(animation).toString(),style:GoogleFonts.aBeeZee(fontSize: 18),textAlign: TextAlign.center,),
    );
  }

  @override
  void forEachTween(TweenVisitor visitor) {
    _count = visitor(_count, widget.count, (dynamic value) => new IntTween(begin: value));
  }
}