import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaphulka1/home.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:video_player/video_player.dart';

List<VideoGridTile> myVideos=[];
List<VideoGridTile> myLikedVideos=[];

class SearchProfile extends StatefulWidget {
  final String email;
  const SearchProfile({Key key, this.email}) : super(key: key);
  @override
  _SearchProfileState createState() => _SearchProfileState();
}

class _SearchProfileState extends State<SearchProfile> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                                          child: Text(snapshot.data['bio']!=null?snapshot.data['bio']:"",
                                            style: GoogleFonts.aBeeZee(fontSize: 17,color: Colors.black54),
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0,right:8),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(icon:
                            Icon(Icons.close,color:deepRed,size: 30,),
                              onPressed: (){
                                   Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:20.0),
                      child: Container(
                          alignment: Alignment.topCenter,
                          height: 500,
                          child: PreviousPosts(widget.email)),
                    ),
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
  final String email;
  PreviousPosts(this.email);
  @override
  _PreviousPostsState createState() => _PreviousPostsState();
}

class _PreviousPostsState extends State<PreviousPosts> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar:TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.blueAccent,
              tabs: [
                Tab(icon: Icon(Icons.video_library),),
                Tab(icon: Icon(Icons.thumb_up)),
              ],
            ),
            body: TabBarView(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection("allPosts").orderBy('timestamp',descending: true).snapshots(),
                  builder: (context,snapshot){
                    myVideos.clear();
                    if(snapshot.hasData){
                      for(int i=0;i<snapshot.data.documents.length;i++){
                        if(snapshot.data.documents.elementAt(i).data['postedby']==widget.email){
                          myVideos.add(VideoGridTile(VideoGridCardDetails.fromSnapshot(snapshot.data.documents.elementAt(i)),0));
                        }
                      }
                    }
                    return snapshot.hasData?
                    snapshot.data.documents.isNotEmpty?
                    GridView.builder(
                      shrinkWrap: true,
                      primary: false,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:3),
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context,i){
                        if(snapshot.data.documents.elementAt(i).data['postedby']==widget.email){
                          return VideoGridTile(VideoGridCardDetails.fromSnapshot(snapshot.data.documents.elementAt(i)),0);
                        }
                        else{
                          return Container();
                        }
                      },
                    ):Padding(
                      padding: const EdgeInsets.symmetric(horizontal:16.0,vertical: 50),
                      child: Text("No Recent Posts",style: GoogleFonts.happyMonkey(fontWeight: FontWeight.bold,fontSize: 18),textAlign: TextAlign.center,),
                    )
                        :LinearProgressIndicator();
                  },

                ),
                StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection("favourites").document(widget.email).collection("likedVideos").orderBy('timestamp',descending: true).snapshots(),
                  builder: (context,snapshot){
                    myLikedVideos.clear();
                    if(snapshot.hasData){
                      for(int i=0;i<snapshot.data.documents.length;i++){
                        myLikedVideos.add(VideoGridTile(VideoGridCardDetails.fromSnapshot(snapshot.data.documents.elementAt(i)),1));
                      }
                    }
                    return snapshot.hasData?
                    snapshot.data.documents.isNotEmpty?GridView.count(
                      shrinkWrap: true,
                      primary: false,
                      crossAxisCount: 3,
                      children: myLikedVideos,
                    ):Padding(
                      padding: const EdgeInsets.symmetric(horizontal:16.0,vertical: 50),
                      child: Text("No Recent Liked Posts",style: GoogleFonts.happyMonkey(fontWeight: FontWeight.bold,fontSize: 18),textAlign: TextAlign.center,),
                    )
                        :LinearProgressIndicator();
                  },

                ),
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


class VideoGridCardDetails{
  final String link,title,subpara,postedby,id,type;
  int likes;
  VideoGridCardDetails.fromMap(Map<dynamic ,dynamic> map)
      : assert(map['link']!=null),
        link=map['link'],
        title=map['title'],
        type=map['type'],
        subpara=map['subpara'],
        id=map['id'],
        postedby=map['postedby'],
        likes=map['likes'];
  VideoGridCardDetails.fromSnapshot(DocumentSnapshot snapshot):this.fromMap(snapshot.data);
}
class VideoGridTile extends StatefulWidget {
  final VideoGridCardDetails videoCardDetails;
  VideoGridTile(this.videoCardDetails, this.tabNumber);
  final int tabNumber;
  @override
  _VideoGridTileState createState() => _VideoGridTileState();
}

class _VideoGridTileState extends State<VideoGridTile> {
  VideoPlayerController _controller;
  FocusNode myFocusNode;
  String draftTitle;
  bool addingPost=false;
  bool removingPost=false;
  bool removingLiked=false;
  bool removingDraft=false;
  String draftCaption;
  final _draftFormKey=GlobalKey<FormState>();
  @override
  void initState() {
    myFocusNode = FocusNode();
    if(widget.videoCardDetails.type=="video") {
      _controller = VideoPlayerController.network(
          widget.videoCardDetails.link)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {
            _controller.pause();
          });
        });
    }
    super.initState();
  }
  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }
  TextOverflow overflow=TextOverflow.ellipsis;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: widget.videoCardDetails.type=="video"?Center(
        child: _controller.value.initialized
            ?InkWell(
          onDoubleTap: (){
            setState(() {
              _controller.initialize();
            });
          },
          onTap: (){
            setState(() {
              _controller.value.isPlaying?_controller.pause():_controller.play();
            });
          },
          onLongPress: (){
            setState(() {
              _controller.play();
            });

            if(widget.tabNumber==1){
              showDialog(context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.all(0),
                          content: Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              Container(
                                height: double.maxFinite,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: <Widget>[
                                      Material(
                                        color: Colors.pink,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(
                                                  10)),
                                        ),
                                        child: ListTile(
                                          leading: Icon(Icons.drafts,
                                              color: Colors.white),
                                          title: Text("Liked Post",
                                            style: GoogleFonts.happyMonkey(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),),
                                          trailing: IconButton(icon: Icon(
                                              Icons.close,
                                              color: Colors.white),
                                            onPressed: () =>
                                                Navigator.pop(context),),
                                        ),
                                      ),
                                      Container(
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: <Widget>[
                                            Container(
                                                width:MediaQuery.of(context).size.width*0.8,
                                                height:MediaQuery.of(context).size.width*0.8,
                                                child: VideoPlayer(_controller)),
                                            VideoProgressIndicator(_controller,allowScrubbing: true,),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: ListTile(
                                          trailing: Icon(Icons.image,size: 30,),
                                          title:Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text("${widget.videoCardDetails.title}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.048,fontWeight: FontWeight.w700,),),
                                              Text("by ${widget.videoCardDetails.postedby}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.046,fontWeight: FontWeight.w600),),
                                            ],
                                          ),
                                          subtitle:Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text("${widget.videoCardDetails.subpara}",overflow:overflow,style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.046,fontWeight: FontWeight.w400),),
                                              overflow==TextOverflow.ellipsis?
                                              InkWell(
                                                onTap:(){
                                                  setState(() {
                                                    overflow=TextOverflow.visible;
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical:4.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(8)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical: 4),
                                                      child: Text("More",style: GoogleFonts.happyMonkey(color: Colors.white,fontSize: 16),),
                                                    ),
                                                  ),
                                                ),
                                              ): InkWell(
                                                onTap:(){
                                                  setState(() {
                                                    overflow=TextOverflow.ellipsis;
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical:4.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(8)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical: 4),
                                                      child: Text("Collapse",style: GoogleFonts.happyMonkey(color: Colors.white,fontSize: 16),),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Icon(Icons.favorite,size: 25.0,color: Colors.redAccent,),
                                                  Text("${widget.videoCardDetails.likes}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.048,fontWeight: FontWeight.w600,),),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
              );
            }
            else{
              showDialog(context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.all(0),
                          content: Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              Container(
                                height: double.maxFinite,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: <Widget>[
                                      Material(
                                        color: Colors.pink,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(
                                                  10)),
                                        ),
                                        child: ListTile(
                                          leading: Icon(Icons.drafts,
                                              color: Colors.white),
                                          title: Text(widget.videoCardDetails.title,
                                            style: GoogleFonts.happyMonkey(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),),
                                          trailing: IconButton(icon: Icon(
                                              Icons.close,
                                              color: Colors.white),
                                            onPressed: () =>
                                                Navigator.pop(context),),
                                        ),
                                      ),
                                      Container(
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: <Widget>[
                                            Container(
                                                width:MediaQuery.of(context).size.width*0.8,
                                                height:MediaQuery.of(context).size.width*0.8,
                                                child: VideoPlayer(_controller)),
                                            VideoProgressIndicator(_controller,allowScrubbing: true,),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: ListTile(
                                          trailing: Icon(Icons.image,size: 30,),
                                          title:Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text("${widget.videoCardDetails.title}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.048,fontWeight: FontWeight.w700,),),
                                              Text("by ${widget.videoCardDetails.postedby}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.046,fontWeight: FontWeight.w600),),
                                            ],
                                          ),
                                          subtitle:Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text("${widget.videoCardDetails.subpara}",overflow:overflow,style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.046,fontWeight: FontWeight.w400),),
                                              overflow==TextOverflow.ellipsis?
                                              InkWell(
                                                onTap:(){
                                                  setState(() {
                                                    overflow=TextOverflow.visible;
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical:4.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(8)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical: 4),
                                                      child: Text("More",style: GoogleFonts.happyMonkey(color: Colors.white,fontSize: 16),),
                                                    ),
                                                  ),
                                                ),
                                              ): InkWell(
                                                onTap:(){
                                                  setState(() {
                                                    overflow=TextOverflow.ellipsis;
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical:4.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(8)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical: 4),
                                                      child: Text("Collapse",style: GoogleFonts.happyMonkey(color: Colors.white,fontSize: 16),),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Icon(Icons.favorite,size: 25.0,color: Colors.redAccent,),
                                                  Text("${widget.videoCardDetails.likes}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.048,fontWeight: FontWeight.w600,),),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
              );
            }
          },
          child: GridTile(
              child: new FittedBox(
                  fit: BoxFit.fill,
                  alignment: Alignment.center,
                  child: Container(
                      decoration: BoxDecoration(
                          border:Border.all(color: Colors.white,width: 0.1)
                      ),
                      width: MediaQuery.of(context).size.width*0.3333333333,
                      height:MediaQuery.of(context).size.width*0.3333333333,
                      child: new VideoPlayer(_controller)
                  )
              )
          ),
        )
            : Center(child:Container(width:18,height:18,child: CircularProgressIndicator())),
      )
          :Center(
          child:
          InkWell(
            onTap: (){
            if(widget.tabNumber==1){
                showDialog(context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.all(0),
                            content: Stack(
                              alignment: Alignment.bottomCenter,
                              children: <Widget>[
                                Container(
                                  height: double.maxFinite,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: <Widget>[
                                        Material(
                                          color: Colors.pink,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(
                                                    10)),
                                          ),
                                          child: ListTile(
                                            leading: Icon(Icons.drafts,
                                                color: Colors.white),
                                            title: Text("Liked Post",
                                              style: GoogleFonts.happyMonkey(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),),
                                            trailing: IconButton(icon: Icon(
                                                Icons.close,
                                                color: Colors.white),
                                              onPressed: () =>
                                                  Navigator.pop(context),),
                                          ),
                                        ),
                                        Container(
                                          child: Stack(
                                            alignment: Alignment.bottomRight,
                                            children: <Widget>[
                                              CachedNetworkImage(
                                                  fadeInDuration: Duration(
                                                      seconds: 1),
                                                  fadeInCurve: Curves.easeIn,
                                                  imageUrl: widget
                                                      .videoCardDetails.link,
                                                  placeholder: (context, url) =>
                                                      Center(
                                                        child: HeartbeatProgressIndicator(
                                                          child: Icon(
                                                            Icons.image, size: 35,
                                                            color: Colors.grey,),
                                                        ),
                                                      ),
                                                  errorWidget: (context, url,
                                                      error) => Icon(
                                                    Icons.image, size: 35,
                                                    color: Colors.blueAccent,)
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: ListTile(
                                            trailing: Icon(Icons.image,size: 30,),
                                            title:Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("${widget.videoCardDetails.title}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.048,fontWeight: FontWeight.w700,),),
                                                Text("by ${widget.videoCardDetails.postedby}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.046,fontWeight: FontWeight.w600),),
                                              ],
                                            ),
                                            subtitle:Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("${widget.videoCardDetails.subpara}",overflow:overflow,style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.046,fontWeight: FontWeight.w400),),
                                                overflow==TextOverflow.ellipsis?
                                                InkWell(
                                                  onTap:(){
                                                    setState(() {
                                                      overflow=TextOverflow.visible;
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical:4.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(8)),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal:8.0,vertical: 4),
                                                        child: Text("More",style: GoogleFonts.happyMonkey(color: Colors.white,fontSize: 16),),
                                                      ),
                                                    ),
                                                  ),
                                                ): InkWell(
                                                  onTap:(){
                                                    setState(() {
                                                      overflow=TextOverflow.ellipsis;
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical:4.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(8)),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal:8.0,vertical: 4),
                                                        child: Text("Collapse",style: GoogleFonts.happyMonkey(color: Colors.white,fontSize: 16),),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Icon(Icons.favorite,size: 25.0,color: Colors.redAccent,),
                                                    Text("${widget.videoCardDetails.likes}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.048,fontWeight: FontWeight.w600,),),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                );
              }
              else{
                showDialog(context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.all(0),
                            content: Stack(
                              alignment: Alignment.bottomCenter,
                              children: <Widget>[
                                Container(
                                  height: double.maxFinite,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: <Widget>[
                                        Material(
                                          color: Colors.pink,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(
                                                    10)),
                                          ),
                                          child: ListTile(
                                            leading: Icon(Icons.drafts,
                                                color: Colors.white),
                                            title: Text(widget.videoCardDetails.title,
                                              style: GoogleFonts.happyMonkey(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),),
                                            trailing: IconButton(icon: Icon(
                                                Icons.close,
                                                color: Colors.white),
                                              onPressed: () =>
                                                  Navigator.pop(context),),
                                          ),
                                        ),
                                        Container(
                                          child: Stack(
                                            alignment: Alignment.bottomRight,
                                            children: <Widget>[
                                              CachedNetworkImage(
                                                  fadeInDuration: Duration(
                                                      seconds: 1),
                                                  fadeInCurve: Curves.easeIn,
                                                  imageUrl: widget
                                                      .videoCardDetails.link,
                                                  placeholder: (context, url) =>
                                                      Center(
                                                        child: HeartbeatProgressIndicator(
                                                          child: Icon(
                                                            Icons.image, size: 35,
                                                            color: Colors.grey,),
                                                        ),
                                                      ),
                                                  errorWidget: (context, url,
                                                      error) => Icon(
                                                    Icons.image, size: 35,
                                                    color: Colors.blueAccent,)
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: ListTile(
                                            trailing: Icon(Icons.image,size: 30,),
                                            title:Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("${widget.videoCardDetails.title}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.048,fontWeight: FontWeight.w700,),),
                                                Text("by ${widget.videoCardDetails.postedby}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.046,fontWeight: FontWeight.w600),),
                                              ],
                                            ),
                                            subtitle:Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("${widget.videoCardDetails.subpara}",overflow:overflow,style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.046,fontWeight: FontWeight.w400),),
                                                overflow==TextOverflow.ellipsis?
                                                InkWell(
                                                  onTap:(){
                                                    setState(() {
                                                      overflow=TextOverflow.visible;
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical:4.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(8)),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal:8.0,vertical: 4),
                                                        child: Text("More",style: GoogleFonts.happyMonkey(color: Colors.white,fontSize: 16),),
                                                      ),
                                                    ),
                                                  ),
                                                ): InkWell(
                                                  onTap:(){
                                                    setState(() {
                                                      overflow=TextOverflow.ellipsis;
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical:4.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(8)),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal:8.0,vertical: 4),
                                                        child: Text("Collapse",style: GoogleFonts.happyMonkey(color: Colors.white,fontSize: 16),),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Icon(Icons.favorite,size: 25.0,color: Colors.redAccent,),
                                                    Text("${widget.videoCardDetails.likes}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.048,fontWeight: FontWeight.w600,),),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                );
              }
            },
            child: GridTile(
                child: new FittedBox(
                    fit: BoxFit.fill,
                    alignment: Alignment.center,
                    child: Container(
                        decoration: BoxDecoration(
                            border:Border.all(color: Colors.white,width: 0.1)
                        ),
                        width: MediaQuery.of(context).size.width*0.3333333333,
                        height:MediaQuery.of(context).size.width*0.3333333333,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: <Widget>[
                            CachedNetworkImage(
                                fadeInDuration: Duration(milliseconds: 500),
                                fadeInCurve: Curves.easeIn,
                                imageUrl: widget.videoCardDetails.link,
                                fit: BoxFit.fill,
                                placeholder: (context, url) => Center(child:Container(width:18,height:18,child: CircularProgressIndicator())),
                                errorWidget: (context, url, error) => Icon(Icons.error,color: deepRed,)
                            ),
                            widget.tabNumber==1?
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Material(elevation: 12,shape:CircleBorder(),child: Container(decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.white,),child: Icon(Icons.favorite,color: Colors.redAccent,size: 18,),width: 28,height: 28,)),
                            )
                                : widget.tabNumber==2?Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Material(elevation: 12,shape:CircleBorder(),child: Container(decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.white),child: Icon(Icons.drafts,color: Colors.deepOrange,size: 18,),width: 28,height: 28,)),
                            )
                                :Container()
                          ],
                        )
                    )
                )
            ),
          )
      ),
    );
  }
}