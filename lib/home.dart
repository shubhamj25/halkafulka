import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaphulka1/profile.dart';
import 'package:halkaphulka1/socialApp.dart';
import 'package:halkaphulka1/widgets/duet_cam.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';
import 'camera.dart';
import 'notifications.dart';
String loggedInEmail;
String loggedInPassword;
Color deepRed=Color.fromRGBO(253, 11, 23, 1);

List<CameraDescription> cameras = [];
Map<String, dynamic> formData = {'name': null, 'password': null};
Map<String, dynamic> signupData = {'name':null,'email': null, 'password': null,'address':null,'phone':null};
Map<String, dynamic> signedin = {'username': null};
List<VideoApp> videos=[];

bool  closingloggingalert=false;
class Homepage extends StatefulWidget {
  final bool rememberMe;
  const Homepage(this.rememberMe);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //final _formKey = GlobalKey<FormState>();
  final searchFieldController=TextEditingController();
  final phoneFieldController=TextEditingController();
  //bool _obscureText = true;
  bool onsignupclick=false;
  bool onsubmit=false;
  double signupfieldopac=0.0;
  String status="You are not Signed In";
  bool signupvalidation=false;
  bool signinerror=false;
  bool loading=false;
  bool phonesignup=false;
  bool requestingotp=false;
  bool phoneregistered=true;
  //bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body:SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.add_a_photo,color: Colors.indigoAccent,size: 30,),
                      onPressed: (){
                        setState(() {
                          Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context){
                              return MyBottomNavigationBar(currentState: 1,username: loggedInEmail,rememberMe: widget.rememberMe,);
                            }
                          ));
                        });
                      },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text("Halka Fulka",style: GoogleFonts.happyMonkey(fontSize: 25,color:Color.fromARGB(170, 0, 0, 0),fontWeight: FontWeight.bold),),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:8.0),
                        child: StreamBuilder(
                          stream: Firestore.instance.collection("users").document(loggedInEmail).snapshots(),
                          builder: (context, snapshot) {
                            return snapshot.hasData?
                            snapshot.data['photoURL']!=null?Material(
                              shape: CircleBorder(),
                              child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child:CachedNetworkImage(
                                      fadeInDuration: Duration(milliseconds: 500),
                                      fadeInCurve: Curves.easeIn,
                                      imageUrl: snapshot.data['photoURL'],
                                      fit: BoxFit.fill,
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider, fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) => Center(
                                        child: HeartbeatProgressIndicator(
                                          child: Icon(Icons.account_circle,size: 25,color: Colors.grey,),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Icon(Icons.image,size: 25,color: Colors.blueAccent,)
                                  )
                              ),
                            ):
                            Icon(Icons.account_circle,size: 25,color: Colors.blueAccent,)
                            :HeartbeatProgressIndicator(
                              child: Icon(Icons.account_circle,size: 25,color: Colors.grey,),
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection("allPosts").orderBy("timestamp",descending: true).snapshots(),
                    builder: (context, snapshot){
                      return !snapshot.hasData?Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(child: Container(width: 27,height: 27,child: CircularProgressIndicator(backgroundColor: Colors.white,strokeWidth: 2,))),
                      ):
                      snapshot.data.documents.isNotEmpty?
                      Container(
                        height: MediaQuery.of(context).size.height*0.78,
                        child: Swiper(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context,i){
                            return VideoApp(videoCardDetails: VideoCardDetails.fromSnapshot(snapshot.data.documents[i]),);
                          },
                          itemCount: snapshot.data.documents.length,
                          scrollDirection: Axis.vertical,
                          scale: 0.9,
                          curve: Curves.decelerate,
                        ),
                      ):Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical:32.0),
                            child: Text("No Recent Posts",style: GoogleFonts.happyMonkey(fontSize: 20),),
                          )
                        ],
                      );
                    }
                ),
                SizedBox(height: 40,)
              ],
            ),
          )
      ),
    );
  }
}

List<Comments> comments=[];
class VideoCardDetails{
  final String link,title,subpara,postedby,id,type,link2,type2,initVideoId;
  int likes;
  VideoCardDetails.fromMap(Map<dynamic ,dynamic> map)
      : assert(map['link']!=null),
        assert(map['type']!=null),
        link=map['link'],
        link2=map['link2'],
        type2=map['type2'],
        initVideoId=map['initVideoId'],
        title=map['title'],
        type=map['type'],
        subpara=map['subpara'],
        id=map['id'],
        postedby=map['postedby'],
        likes=map['likes'];
  VideoCardDetails.fromSnapshot(DocumentSnapshot snapshot):this.fromMap(snapshot.data);
}
void share(BuildContext context,VideoCardDetails videoCardDetails){
  final RenderBox box=context.findRenderObject();
  final String text="Hey there Checkout this Post by ${videoCardDetails.postedby}\n${videoCardDetails.title}\nLink to Video:\n${videoCardDetails.link}";
  Share.share(text,
      subject: videoCardDetails.subpara,
      sharePositionOrigin:box.localToGlobal(Offset.zero) & box.size);
}


class VideoApp extends StatefulWidget {
  final VideoCardDetails videoCardDetails;
  const VideoApp({Key key, this.videoCardDetails}) : super(key: key);
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;
  VideoPlayerController _controller2;
  final commentController=TextEditingController();
  bool favourite=false;
  final _formKey = GlobalKey<FormState>();
  final searchFieldController=TextEditingController();
  final phoneFieldController=TextEditingController();
  //bool _obscureText = true;
  bool onsignupclick=false;
  bool onsubmit=false;
  double signupfieldopac=0.0;
  String status="You are not Signed In";
  bool signupvalidation=false;
  bool signinerror=false;
  bool loading=false;
  bool phonesignup=false;
  bool requestingotp=false;
  bool phoneregistered=true;
  TextOverflow overflow=TextOverflow.ellipsis;

  @override
  void initState() {
    myFocusNode = FocusNode();
    Firestore.instance.collection('favourites').document(loggedInEmail).collection("likedVideos").document(widget.videoCardDetails.id).get().then((doc){
      if(doc.exists){
        setState(() {
          favourite=true;
        });
      }
    });
    if(widget.videoCardDetails.type=="video"){
      _controller = VideoPlayerController.network(
          widget.videoCardDetails.link)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {
            _controller.play();
          });
        });
    }
    if(widget.videoCardDetails.type2=="video"){
      _controller2 = VideoPlayerController.network(
          widget.videoCardDetails.link2)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {
            _controller2.play();
          });
        });
    }
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    if(widget.videoCardDetails.type=="video"){
      _controller.dispose();
    }
    if(widget.videoCardDetails.type2=="video"){
      _controller2.dispose();
    }
    myFocusNode.dispose();
    super.dispose();
  }

  FocusNode myFocusNode;

  @override
  Widget build(BuildContext context) {
    return widget.videoCardDetails.type=="video"?
    Padding(
      padding: const EdgeInsets.symmetric(horizontal:8.0),
      child:Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topRight:Radius.circular(10),topLeft: Radius.circular(10)),
                ),
                color: Color.fromARGB(200, 0, 0, 0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StreamBuilder(
                          stream: Firestore.instance.collection("users").document(widget.videoCardDetails.postedby).snapshots(),
                          builder: (context, snapshot) {
                            return snapshot.hasData?
                            snapshot.data['photoURL']!=null?Material(
                              shape: CircleBorder(),
                              child: Container(
                                alignment: Alignment.topCenter,
                                width: 35.0,
                                height: 35.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color:Colors.white,width: 2)
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
                                    errorWidget: (context, url, error) => Icon(Icons.person,color: Colors.blueAccent,)
                                ),
                              ),
                            ):Icon(Icons.account_circle,size: 35,color: Colors.blueAccent,)
                                :Icon(Icons.account_circle,color: Colors.grey,size: 35,)
                            ;
                          }
                      ),
                    ),
                    Text(widget.videoCardDetails.postedby,style: GoogleFonts.happyMonkey(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 18),),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  InkWell(
                    onTap: (){
                      if(_controller.value.initialized){
                        setState(() {
                          _controller.value.isPlaying?_controller.pause():_controller.play();
                        });
                      }
                      if(_controller2.value.initialized){
                        setState(() {
                          _controller2.value.isPlaying?_controller2.pause():_controller2.play();
                        });
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                            width: widget.videoCardDetails.link2!=null?MediaQuery.of(context).size.width*0.477:MediaQuery.of(context).size.width*0.955,
                            height: MediaQuery.of(context).size.width*0.8,
                            child:_controller.value.initialized?new VideoPlayer(_controller): Center(child:   HeartbeatProgressIndicator(
                              child: Icon(Icons.video_library,size: 40,color: Colors.grey,),
                            ),)
                        ),
                        widget.videoCardDetails.link2!=null&&widget.videoCardDetails.type2=='video'?Container(
                            width: widget.videoCardDetails.link2!=null?MediaQuery.of(context).size.width*0.477:MediaQuery.of(context).size.width*0.955,
                            height: MediaQuery.of(context).size.width*0.8,
                            child:_controller2.value.initialized?new VideoPlayer(_controller2): Center(child:   HeartbeatProgressIndicator(
                              child: Icon(Icons.video_library,size: 40,color: Colors.grey,),
                            ),)
                        ):widget.videoCardDetails.link2!=null&&widget.videoCardDetails.type2!='video'?
                        Container(
                          width: widget.videoCardDetails.link2!=null?MediaQuery.of(context).size.width*0.477:MediaQuery.of(context).size.width*0.955,
                          height: MediaQuery.of(context).size.width*0.8,
                          child: CachedNetworkImage(
                              fadeInDuration: Duration(milliseconds: 500),
                              fadeInCurve: Curves.easeIn,
                              imageUrl: widget.videoCardDetails.link,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  child: HeartbeatProgressIndicator(
                                    child: Icon(Icons.image,size: 50,color: Colors.grey,),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.image,size: 50,color: Colors.blueAccent,)
                          ),
                        ):Container(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left:18.0),
                          child: Container(
                            width: 50,
                            height: 50,
                            child: FloatingActionButton(
                                heroTag: Timestamp.now().microsecondsSinceEpoch,
                                child: Icon(Icons.comment),
                                onPressed: () {
                                  Navigator.push(context,MaterialPageRoute(
                                      builder: (context){
                                        return  SafeArea(
                                          child: Scaffold(
                                            body: Stack(
                                              alignment: Alignment.bottomCenter,
                                              children: <Widget>[
                                                SingleChildScrollView(
                                                  child: Column(
                                                    children: <Widget>[
                                                      SizedBox(height: 10,),
                                                      ListTile(
                                                          leading:Icon(Icons.edit,),
                                                          title:Text("Comments",style:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600)),
                                                          subtitle: Text("${widget.videoCardDetails.title}\nby ${widget.videoCardDetails.postedby}",style: GoogleFonts.happyMonkey(fontSize: 14),),
                                                          trailing:IconButton(
                                                            icon: Icon(Icons.close,size: 20.0,color: deepRed,),
                                                            onPressed: (){
                                                              Navigator.pop(context);
                                                            },
                                                          )
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        height:  MediaQuery.of(context).size.height,
                                                        child:  StreamBuilder<QuerySnapshot>(
                                                            stream: Firestore.instance.collection("comments").document(widget.videoCardDetails.id).collection("comments").orderBy('timestamp',descending:true).snapshots(),
                                                            builder: (context,snapshot) {
                                                              return !snapshot.hasData? Center(child: CircularProgressIndicator(backgroundColor: Colors.white,strokeWidth: 2,)):
                                                              snapshot.data.documents.isNotEmpty?ListView.builder(
                                                                itemCount:snapshot.data.documents.length,
                                                                itemBuilder: (BuildContext context,index){
                                                                  return Comments(snapshot.data.documents.elementAt(index).data['comment'],
                                                                      snapshot.data.documents.elementAt(index).data['by'],
                                                                      snapshot.data.documents.elementAt(index).data['timestamp']);
                                                                },
                                                              ):Center(
                                                                child: Text("No recent Comments",style: GoogleFonts.balooBhai(fontSize: 20,color: Colors.grey),),
                                                              );
                                                            }
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Form(
                                                  key: _formKey,
                                                  child: Material(
                                                    elevation: 12.0,
                                                    color: Colors.white,
                                                    child: TextFormField(
                                                      controller: commentController,
                                                      validator:(val){
                                                        if(val==""||val==null){
                                                          return "Please enter something";
                                                        }
                                                        else{
                                                          return null;
                                                        }
                                                      },
                                                      style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black),
                                                      decoration: InputDecoration(
                                                        labelText: "Add Comment",
                                                        errorStyle:GoogleFonts.balooBhai(),
                                                        border:InputBorder.none,
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 14.0,),
                                                        suffixIcon: IconButton(icon:Icon(Icons.send,color: Colors.blueAccent,),
                                                          onPressed: (){
                                                            setState(() {
                                                              String comment=commentController.text;
                                                              Firestore.instance.collection("comments").document(widget.videoCardDetails.id).collection("comments").add({
                                                                'comment':comment,
                                                                'timestamp':Timestamp.now(),
                                                                'by':loggedInEmail,
                                                              }).then((value){
                                                                Firestore.instance.collection("comments").document(widget.videoCardDetails.id).collection("comments").document(value.documentID).updateData({
                                                                  'id':value.documentID
                                                                });
                                                              });
                                                              commentController.clear();
                                                            });
                                                          }
                                                          ,),
                                                      ),

                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                  ));
                                }
                            ),
                          ),
                        ),

                        Container(
                          width: 50,height: 50,
                          child: FloatingActionButton(
                            heroTag: Timestamp.now().microsecondsSinceEpoch,
                            backgroundColor: favourite? Colors.white:Colors.blue,
                            child: !favourite?Icon(Icons.favorite):Icon(Icons.favorite,color: Colors.red,),
                            onPressed: () {
                              setState(() {
                                if(favourite==false){
                                  favourite=true;
                                  widget.videoCardDetails.likes++;
                                  Firestore.instance.collection("allPosts").document(widget.videoCardDetails.id.toString()).updateData({
                                    'likes':widget.videoCardDetails.likes,
                                  });
                                  Firestore.instance.collection("favourites").document(loggedInEmail).collection("likedVideos").document(widget.videoCardDetails.id).setData({
                                    'title':widget.videoCardDetails.title,
                                    'postedby':widget.videoCardDetails.postedby,
                                    'link':widget.videoCardDetails.link,
                                    'id':widget.videoCardDetails.id,
                                    'timestamp':Timestamp.now(),
                                    "type":widget.videoCardDetails.type,
                                    'subpara':widget.videoCardDetails.subpara,
                                    'likes':widget.videoCardDetails.likes
                                  });

                                  Firestore.instance.collection("notifications").document(widget.videoCardDetails.postedby).collection("notifications_${widget.videoCardDetails.postedby}").add({
                                    "message":"$loggedInEmail liked your post having title ${widget.videoCardDetails.title}",
                                    "timestamp":DateTime.now().toIso8601String(),
                                    "postId":widget.videoCardDetails.id,
                                    "seen":false
                                  }).then((value){
                                    Firestore.instance.collection("notifications").document(widget.videoCardDetails.postedby).collection("notifications_${widget.videoCardDetails.postedby}").document(value.documentID).updateData({
                                      "id":value.documentID,
                                    });
                                  });

                                }
                                else if(favourite==true){
                                  favourite=false;
                                  widget.videoCardDetails.likes--;
                                  Firestore.instance.collection("allPosts").document(widget.videoCardDetails.id).updateData({
                                    'likes':widget.videoCardDetails.likes,
                                  });
                                  Firestore.instance.collection("favourites").document(loggedInEmail).collection("likedVideos").document("${widget.videoCardDetails.id}").delete();

                                  Firestore.instance.collection("notifications").document(widget.videoCardDetails.postedby).collection("notifications_${widget.videoCardDetails.postedby}").add({
                                    "message":"$loggedInEmail disliked your post having title ${widget.videoCardDetails.title}",
                                    "timestamp":DateTime.now().toIso8601String(),
                                    "postId":widget.videoCardDetails.id,
                                    "seen":false
                                  }).then((value){
                                    Firestore.instance.collection("notifications").document(widget.videoCardDetails.postedby).collection("notifications_${widget.videoCardDetails.postedby}").document(value.documentID).updateData({
                                      "id":value.documentID,
                                    });
                                  });

                                }

                              });
                            },
                          ),
                        ),

                        Container(
                          width: 50,height: 50,
                          child: FloatingActionButton(
                            heroTag: Timestamp.now().microsecondsSinceEpoch,
                            child: Icon(Icons.share),
                            onPressed: ()=> share(context,widget.videoCardDetails),
                          ),
                        ),

                        if(widget.videoCardDetails.type=="video")
                          Container(
                            width: 50,height: 50,
                            child: FloatingActionButton(
                              heroTag: Timestamp.now().microsecondsSinceEpoch,
                              onPressed: () {
                                 Navigator.push(context,MaterialPageRoute(builder: (context){
                                   return DuetVIdeoCapture(initVideoUrl: widget.videoCardDetails.link,);
                                 }));
                              },
                              child: Icon(Icons.control_point_duplicate,),
                            ),
                          )
                          /*Container(
                            width: 50,height: 50,
                            child: FloatingActionButton(
                              heroTag: Timestamp.now().microsecondsSinceEpoch,
                              onPressed: () {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              },
                              child: Icon(
                                _controller.value.isPlaying ? Icons.pause :
                                Icons.play_arrow,
                              ),
                            ),
                          ),*/
                      ],
                    ),
                  ),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
              Focus(
                focusNode: myFocusNode,
                child: ListTile(
                  trailing: Icon(Icons.video_library,size: 30,),
                  title:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${widget.videoCardDetails.title}",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.048,fontWeight: FontWeight.w700),),
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
                            myFocusNode.requestFocus();
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
                            myFocusNode.unfocus();
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
              ),

            ],
          ),
        ),
      ),
    )
        :
    Padding(
      padding: const EdgeInsets.symmetric(horizontal:8.0),
      child: Material(
        color: Color.fromARGB(255, 250, 250, 250),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Column(// new
            children: <Widget>[
              Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topRight:Radius.circular(10),topLeft: Radius.circular(10)),
                ),
                color: Color.fromARGB(200, 0, 0, 0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StreamBuilder(
                          stream: Firestore.instance.collection("users").document(widget.videoCardDetails.postedby).snapshots(),
                          builder: (context, snapshot) {
                            return snapshot.hasData?
                            snapshot.data['photoURL']!=null?Material(
                              shape: CircleBorder(),
                              child: Container(
                                alignment: Alignment.topCenter,
                                width: 35.0,
                                height: 35.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color:Colors.white,width: 2)
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
                                    errorWidget: (context, url, error) => Icon(Icons.account_circle,size: 35,color: Colors.blueAccent,)
                                ),
                              ),
                            ):Icon(Icons.account_circle,size: 35,color: Colors.blueAccent,)
                                :Icon(Icons.account_circle,color: Colors.grey,size: 35,)
                            ;
                          }
                      ),
                    ),
                    Text(widget.videoCardDetails.postedby,style: GoogleFonts.happyMonkey(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 18),),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  InkWell(
                    onTap: (){
                      if(_controller.value.initialized){
                        setState(() {
                          _controller.value.isPlaying?_controller.pause():_controller.play();
                        });
                      }
                      if(_controller2.value.initialized){
                        setState(() {
                          _controller2.value.isPlaying?_controller2.pause():_controller2.play();
                        });
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                            width: widget.videoCardDetails.link2!=null?MediaQuery.of(context).size.width*0.477:MediaQuery.of(context).size.width*0.955,
                            height: MediaQuery.of(context).size.width*0.8,
                            child:CachedNetworkImage(
                                fadeInDuration: Duration(milliseconds: 500),
                                fadeInCurve: Curves.easeIn,
                                imageUrl: widget.videoCardDetails.link,
                                fit: BoxFit.fill,
                                placeholder: (context, url) => Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: HeartbeatProgressIndicator(
                                      child: Icon(Icons.image,size: 50,color: Colors.grey,),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.image,size: 40,color: Colors.blueAccent,)
                            )
                        ),
                        widget.videoCardDetails.link2!=null&&widget.videoCardDetails.type2=='video'?Container(
                            width: widget.videoCardDetails.link2!=null?MediaQuery.of(context).size.width*0.477:MediaQuery.of(context).size.width*0.955,
                            height: MediaQuery.of(context).size.width*0.8,
                            child:_controller2.value.initialized?new VideoPlayer(_controller2): Center(child:   HeartbeatProgressIndicator(
                              child: Icon(Icons.video_library,size: 40,color: Colors.grey,),
                            ),)
                        ):widget.videoCardDetails.link2!=null&&widget.videoCardDetails.type2!='video'?
                        Container(
                          width: widget.videoCardDetails.link2!=null?MediaQuery.of(context).size.width*0.477:MediaQuery.of(context).size.width*0.955,
                          height: MediaQuery.of(context).size.width*0.8,
                          child: CachedNetworkImage(
                              fadeInDuration: Duration(milliseconds: 500),
                              fadeInCurve: Curves.easeIn,
                              imageUrl: widget.videoCardDetails.link,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  child: HeartbeatProgressIndicator(
                                    child: Icon(Icons.image,size: 50,color: Colors.grey,),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.image,size: 50,color: Colors.blueAccent,)
                          ),
                        ):Container(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left:18.0),
                          child: Container(
                            width: 50,
                            height: 50,
                            child: FloatingActionButton(
                                heroTag: Timestamp.now().microsecondsSinceEpoch,
                                child: Icon(Icons.comment),
                                onPressed: () {
                                  Navigator.push(context,MaterialPageRoute(
                                    builder: (context){
                                      return  SafeArea(
                                        child: Scaffold(
                                          body: Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: <Widget>[
                                              SingleChildScrollView(
                                                child: Column(
                                                  children: <Widget>[
                                                    SizedBox(height: 10,),
                                                    ListTile(
                                                        leading:Icon(Icons.edit,),
                                                        title:Text("Comments",style:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600)),
                                                        subtitle: Text("${widget.videoCardDetails.title}\nby ${widget.videoCardDetails.postedby}",style: GoogleFonts.happyMonkey(fontSize: 14),),
                                                        trailing:IconButton(
                                                          icon: Icon(Icons.close,size: 20.0,color: deepRed,),
                                                          onPressed: (){
                                                            Navigator.pop(context);
                                                          },
                                                        )
                                                    ),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width,
                                                      height:  MediaQuery.of(context).size.height,
                                                      child:  StreamBuilder<QuerySnapshot>(
                                                          stream: Firestore.instance.collection("comments").document(widget.videoCardDetails.id).collection("comments").orderBy('timestamp',descending:true).snapshots(),
                                                          builder: (context,snapshot) {
                                                            return !snapshot.hasData? Center(child: CircularProgressIndicator(backgroundColor: Colors.white,strokeWidth: 2,)):
                                                            snapshot.data.documents.isNotEmpty?ListView.builder(
                                                              itemCount:snapshot.data.documents.length,
                                                              itemBuilder: (BuildContext context,index){
                                                                return Comments(snapshot.data.documents.elementAt(index).data['comment'],
                                                                    snapshot.data.documents.elementAt(index).data['by'],
                                                                    snapshot.data.documents.elementAt(index).data['timestamp']);
                                                              },
                                                            ):Center(
                                                              child: Text("No recent Comments",style: GoogleFonts.balooBhai(fontSize: 20,color: Colors.grey),),
                                                            );
                                                          }
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Form(
                                                key: _formKey,
                                                child: Material(
                                                  elevation: 12.0,
                                                  color: Colors.white,
                                                  child: TextFormField(
                                                    controller: commentController,
                                                    validator:(val){
                                                      if(val==""||val==null){
                                                        return "Please enter something";
                                                      }
                                                      else{
                                                        return null;
                                                      }
                                                      },
                                                    style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black),
                                                    decoration: InputDecoration(
                                                      labelText: "Add Comment",
                                                      errorStyle:GoogleFonts.balooBhai(),
                                                      border:InputBorder.none,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 14.0,),
                                                      suffixIcon: IconButton(icon:Icon(Icons.send,color: Colors.blueAccent,),
                                                        onPressed: (){
                                                          setState(() {
                                                            String comment=commentController.text;
                                                            Firestore.instance.collection("comments").document(widget.videoCardDetails.id).collection("comments").add({
                                                              'comment':comment,
                                                              'timestamp':Timestamp.now(),
                                                              'by':loggedInEmail,
                                                            }).then((value){
                                                              Firestore.instance.collection("comments").document(widget.videoCardDetails.id).collection("comments").document(value.documentID).updateData({
                                                                'id':value.documentID
                                                              });
                                                            });
                                                            commentController.clear();
                                                          });
                                                        }
                                                        ,),
                                                    ),

                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  ));
                                }
                            ),
                          ),
                        ),

                        Container(
                          width: 50,height: 50,
                          child: FloatingActionButton(
                            heroTag: Timestamp.now().microsecondsSinceEpoch,
                            backgroundColor: favourite? Colors.white:Colors.blue,
                            child: !favourite?Icon(Icons.favorite):Icon(Icons.favorite,color: Colors.red,),
                            onPressed: () {
                              setState(() {
                                if(favourite==false){
                                  favourite=true;
                                  widget.videoCardDetails.likes++;
                                  Firestore.instance.collection("allPosts").document(widget.videoCardDetails.id.toString()).updateData({
                                    'likes':widget.videoCardDetails.likes,
                                  });
                                  Firestore.instance.collection('favourites').document(loggedInEmail).collection("likedVideos").document("${widget.videoCardDetails.id}").setData({
                                    'title':widget.videoCardDetails.title,
                                    'postedby':widget.videoCardDetails.postedby,
                                    'link':widget.videoCardDetails.link,
                                    'id':widget.videoCardDetails.id,
                                    'timestamp':Timestamp.now(),
                                    "type":widget.videoCardDetails.type,
                                    'subpara':widget.videoCardDetails.subpara,
                                    'likes':widget.videoCardDetails.likes
                                  });
                                  Firestore.instance.collection("notifications").document(widget.videoCardDetails.postedby).collection("notifications_${widget.videoCardDetails.postedby}").add({
                                    "message":"$loggedInEmail liked your post having title ${widget.videoCardDetails.title}",
                                    "timestamp":DateTime.now().toIso8601String(),
                                    "postId":widget.videoCardDetails.id,
                                    "seen":false
                                  }).then((value){
                                    Firestore.instance.collection("notifications").document(widget.videoCardDetails.postedby).collection("notifications_${widget.videoCardDetails.postedby}").document(value.documentID).updateData({
                                      "id":value.documentID,
                                    });
                                  });
                                }
                                else if(favourite==true){
                                  favourite=false;
                                  widget.videoCardDetails.likes--;
                                  Firestore.instance.collection("allPosts").document(widget.videoCardDetails.id).updateData({
                                    'likes':widget.videoCardDetails.likes,
                                  });
                                  Firestore.instance.collection('favourites').document(loggedInEmail).collection("likedVideos").document("${widget.videoCardDetails.id}").delete();
                                  Firestore.instance.collection("notifications").document(widget.videoCardDetails.postedby).collection("notifications_${widget.videoCardDetails.postedby}").add({
                                    "message":"$loggedInEmail disliked your post having title ${widget.videoCardDetails.title}",
                                    "timestamp":DateTime.now().toIso8601String(),
                                    "postId":widget.videoCardDetails.id,
                                    "seen":false
                                  }).then((value){
                                    Firestore.instance.collection("notifications").document(widget.videoCardDetails.postedby).collection("notifications_${widget.videoCardDetails.postedby}").document(value.documentID).updateData({
                                      "id":value.documentID,
                                    });
                                  });
                                }
                              });
                            },
                          ),
                        ),

                        Container(
                          width: 50,height: 50,
                          child: FloatingActionButton(
                            heroTag: Timestamp.now().microsecondsSinceEpoch,
                            child: Icon(Icons.share),
                            onPressed: ()=> share(context,widget.videoCardDetails),
                          ),
                        ),

                        if(widget.videoCardDetails.type=="video")
                          Container(
                            width: 50,height: 50,
                            child: FloatingActionButton(
                              heroTag: Timestamp.now().microsecondsSinceEpoch,
                              onPressed: () {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              },
                              child: Icon(
                                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
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
                  subtitle:Focus(
                    focusNode: myFocusNode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${widget.videoCardDetails.subpara}",overflow:overflow,style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.046,fontWeight: FontWeight.w400),),
                        overflow==TextOverflow.ellipsis?
                        InkWell(
                          onTap:(){
                            setState(() {
                              overflow=TextOverflow.visible;
                              myFocusNode.requestFocus();
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
                              myFocusNode.unfocus();
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class Comments extends StatefulWidget {
  final String comment,by;
  final Timestamp time;
  Comments(this.comment, this.by, this.time);
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        alignment: widget.by==loggedInEmail?Alignment.topRight:Alignment.topLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:MediaQuery.of(context).size.width*0.7,
          ),
          child: Card(
            color: widget.by==loggedInEmail?Colors.blueAccent:Colors.black45,
            shape: RoundedRectangleBorder(
              borderRadius: widget.by==loggedInEmail?BorderRadius.only(topRight:Radius.circular(12),
              topLeft:Radius.circular(12),bottomLeft:Radius.circular(12)):
              BorderRadius.only(topRight:Radius.circular(12),
                  topLeft:Radius.circular(12),bottomRight:Radius.circular(12))
              ,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Text("${widget.comment}",style: GoogleFonts.happyMonkey(color:Colors.white,fontSize: MediaQuery.of(context).size.width*0.045,fontWeight:FontWeight.w500),textAlign: TextAlign.left,),
                  Text(widget.by,style: GoogleFonts.happyMonkey(color: Colors.white,fontSize: 10),textAlign: TextAlign.right,)
                ],
              ),
            ),),
        ),
      ),
    );
  }
}

class MyBottomNavigationBar extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String username;
  final bool rememberMe;
  final int currentState;
  MyBottomNavigationBar({this.cameras, this.username, this.rememberMe, this.currentState});
  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}
int _currentIndex=0;
class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  //final _formKey = GlobalKey<FormState>();
  final searchFieldController=TextEditingController();
  final phoneFieldController=TextEditingController();
  //bool _obscureText = true;
  bool onsignupclick=false;
  bool onsubmit=false;
  double signupfieldopac=0.0;
  String status="You are not Signed In";
  bool signupvalidation=false;
  bool signinerror=false;
  bool loading=false;
  bool phonesignup=false;
  bool requestingotp=false;
  bool phoneregistered=true;
  //bool _autoValidate = false;
  @override
  void initState() {
    // TODO: implement initState
    if(widget.currentState!=null){
      setState(() {
        _currentIndex=widget.currentState;
      });
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> _children=[
      SafeArea(child: Homepage(widget.rememberMe)),
      Material(child: ImageCapture()),
      StreamBuilder(
          stream: Firestore.instance.collection("users").document(loggedInEmail).snapshots(),
          builder: (context, snapshot) {
            return snapshot.hasData?Social(userEmail:snapshot.data['email'],userName:snapshot.data['name'],img: snapshot.data['photoURL']):Center(child: Container(width:30,height: 30,child: CircularProgressIndicator(strokeWidth: 4,backgroundColor: Colors.white,)));
          }
      ),
      Profile(email: widget.username,rememberMe: widget.rememberMe,),
    ];
    return Scaffold(
      body:_children[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Color.fromARGB(0, 0, 0, 0),
          color: Colors.blueAccent,
          animationCurve: Curves.fastOutSlowIn,
          height: 55,
          index: _currentIndex,
          items: <Widget>[
            Icon(Icons.home,color: Colors.white,),
            Icon(Icons.add,color: Colors.white,),
            Icon(Icons.favorite,color: Colors.white,),
            Icon(Icons.account_circle,color: Colors.white,),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex=index;
            });
          }
      ),
    );
  }
}
