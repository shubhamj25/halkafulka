import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaphulka1/custom_icons_icons.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_trimmer/video_viewer.dart';
import '../home.dart';
Map<String, dynamic> currentpost = {'title': null, 'caption': null};
File _imageFile;
File _video;

class DuetVIdeoCapture extends StatefulWidget {
  final String initVideoUrl,initVideoId;
  const DuetVIdeoCapture({Key key, this.initVideoUrl, this.initVideoId}) : super(key: key);
  @override
  _DuetVIdeoCaptureState createState() => _DuetVIdeoCaptureState();
}

class _DuetVIdeoCaptureState extends State<DuetVIdeoCapture> {
  VideoPlayerController  _videoPlayerController;
  VideoPlayerController  _videoPlayerController2;

  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });
    String _value;
    await _trimmer
        .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
        .then((value) {
      setState(() {
        _progressVisibility = false;
        _value = value;
      });
    });
    return _value;
  }



  Future<void> _pickImage(ImageSource source) async {
    // ignore: deprecated_member_use
    File selected=await ImagePicker.pickImage(source: source).then((filepath) {
      return ImageCropper.cropImage(sourcePath: filepath.path,androidUiSettings:AndroidUiSettings(
        initAspectRatio: CropAspectRatioPreset.square,
      ), );
    });
    setState(() {
      _imageFile=selected;
    });
  }

  _pickVideo() async {
    // ignore: deprecated_member_use
    File video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      await _trimmer.loadVideo(videoFile: video);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) {
        return Material(
          child: Builder(
            builder: (context) =>  Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AspectRatio(
                        aspectRatio:1/1,
                        child: VideoViewer()),
                    TrimEditor(
                      durationTextStyle: GoogleFonts.happyMonkey(color:Colors.black54,fontSize: 16),
                      viewerHeight: 70,
                      viewerWidth: MediaQuery.of(context).size.width*0.8,
                      onChangeStart: (value) {
                        _startValue = value;
                      },
                      onChangeEnd: (value) {
                        _endValue = value;
                      },
                      onChangePlaybackState: (value) {
                        _isPlaying = value;
                      },
                    ),
                    FlatButton.icon(
                      icon: _isPlaying
                          ? Icon(
                          Icons.pause_circle_filled,
                          color: Colors.pink
                      )
                          : Icon(
                        Icons.play_circle_filled,
                        color: Colors.blueAccent,
                      ),
                      label: Text(_isPlaying?"Pause":"Play",style: GoogleFonts.balooBhai(fontSize: 18),),
                      onPressed: () async {
                        bool playbackState =
                        await _trimmer.videPlaybackControl(
                          startValue: _startValue,
                          endValue: _endValue,
                        );
                        setState(() {
                          _isPlaying = playbackState;
                        });
                      },
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    InkWell(
                      onTap: _progressVisibility
                          ? null
                          : () async {
                        _saveVideo().then((outputPath) {
                          Navigator.pop(context);
                          _videoPlayerController = VideoPlayerController.file(File(outputPath))..initialize().then((_) {
                            setState(() {
                              _video=File(outputPath);
                            });
                            _videoPlayerController.play();
                          });
                        });
                      },
                      child: Container(width: MediaQuery.of(context).size.width*0.5,height: 50,color: Colors.blueAccent,child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(CustomIcons.magic,size: 20,color: Colors.white,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Trim",style: GoogleFonts.balooBhai(fontSize: 18,color: Colors.white),),
                          ),
                        ],
                      ),),
                    ),
                    InkWell(
                      onTap:()=>Navigator.pop(context),
                      child: Container(color:deepRed,width: MediaQuery.of(context).size.width*0.5,height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.close,size: 20,color: Colors.white,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Close",style: GoogleFonts.balooBhai(fontSize: 18,color: Colors.white),),
                            ),
                          ],
                        ),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }));
    }
  }

  _pickVideoFromCamera() async {
    // ignore: deprecated_member_use
    File video = await ImagePicker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      await _trimmer.loadVideo(videoFile: video);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) {
        return Material(
          child: Builder(
            builder: (context) =>  Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AspectRatio(
                        aspectRatio:1/1,
                        child: VideoViewer()),
                    TrimEditor(
                      durationTextStyle: GoogleFonts.happyMonkey(color:Colors.black54,fontSize: 16),
                      viewerHeight: 70,
                      viewerWidth: MediaQuery.of(context).size.width*0.8,
                      onChangeStart: (value) {
                        _startValue = value;
                      },
                      onChangeEnd: (value) {
                        _endValue = value;
                      },
                      onChangePlaybackState: (value) {
                        _isPlaying = value;
                      },
                    ),
                    FlatButton.icon(
                      icon: _isPlaying
                          ? Icon(
                          Icons.pause_circle_filled,
                          color: Colors.pink
                      )
                          : Icon(
                        Icons.play_circle_filled,
                        color: Colors.blueAccent,
                      ),
                      label: Text(_isPlaying?"Pause":"Play",style: GoogleFonts.balooBhai(fontSize: 18),),
                      onPressed: () async {
                        bool playbackState =
                        await _trimmer.videPlaybackControl(
                          startValue: _startValue,
                          endValue: _endValue,
                        );
                        setState(() {
                          _isPlaying = playbackState;
                        });
                      },
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    InkWell(
                      onTap: _progressVisibility
                          ? null
                          : () async {
                        _saveVideo().then((outputPath) {
                          Navigator.pop(context);
                          _videoPlayerController = VideoPlayerController.file(File(outputPath))..initialize().then((_) {
                            setState(() {
                              _video=File(outputPath);
                            });
                            _videoPlayerController.play();
                          });
                        });
                      },
                      child: Container(width: MediaQuery.of(context).size.width*0.5,height: 50,color: Colors.blueAccent,child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(CustomIcons.magic,size: 20,color: Colors.white,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Trim",style: GoogleFonts.balooBhai(fontSize: 18,color: Colors.white),),
                          ),
                        ],
                      ),),
                    ),
                    InkWell(
                      onTap:()=>Navigator.pop(context),
                      child: Container(color:deepRed,width: MediaQuery.of(context).size.width*0.5,height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.close,size: 20,color: Colors.white,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Close",style: GoogleFonts.balooBhai(fontSize: 18,color: Colors.white),),
                            ),
                          ],
                        ),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }));
    }
  }

  Future<void> _cropImage()async{
    File cropped=await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      androidUiSettings: AndroidUiSettings(
        initAspectRatio: CropAspectRatioPreset.square,
      ),
    );
    setState(() {
      _imageFile=cropped ?? _imageFile;
    });
  }


  bool photocapture=true;

  void clear(){
    setState(() {
      _imageFile=null;
      _video=null;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _imageFile=null;
    _video=null;
    _videoPlayerController2 = VideoPlayerController.network(widget.initVideoUrl)..initialize().then((_) {
      setState(() { });
      _videoPlayerController2.play();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.45,
              width:  MediaQuery.of(context).size.width*2,
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      _video!=null&&_videoPlayerController.value.initialized
                          ? Container(
                        width:_video!=null||_imageFile!=null?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: <Widget>[
                            Container(
                           width:MediaQuery.of(context).size.width,
                           child: VideoPlayer(_videoPlayerController)),
                            VideoProgressIndicator(_videoPlayerController, allowScrubbing: true),
                          ],
                        ),
                      )
                          : _imageFile!=null? Container(
                            width:_video!=null||_imageFile!=null?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width,
                            child: Image.file(_imageFile,
                                fit: BoxFit.fill,
                              ),

                            ):Container(),
                      _videoPlayerController2.value.initialized
                          ? Container(
                        width:_video!=null||_imageFile!=null?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: <Widget>[
                            VideoPlayer(_videoPlayerController2),
                            VideoProgressIndicator(_videoPlayerController2, allowScrubbing: true),
                          ],
                        ),
                      )
                          : Container(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(alignment: Alignment.topLeft,child:IconButton(icon:Icon(Icons.close,color:Colors.redAccent),onPressed:(){
                      _videoPlayerController2.pause();
                      if(_video!=null)
                        _videoPlayerController.pause();
                      Navigator.pop(context);
                    },) ,),
                  ),
                ],
              ),
            ),

            _video!=null ?Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[

                    FlatButton.icon(icon: Icon(Icons.play_circle_filled),
                      onPressed:(){
                        setState(() {
                          setState(() {
                            _videoPlayerController.play();
                          });
                        });
                      },
                      label: Text("Play",
                        style: GoogleFonts.balooBhai(),
                      ),),
                    FlatButton.icon(icon: Icon(Icons.delete),onPressed:(){
                      setState(() {
                        clear();
                        _videoPlayerController.pause();
                        clear();
                      });
                    },label: Text("Delete",style: GoogleFonts.balooBhai(),),),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: VideoUploader(file:_video,initialUrl: widget.initVideoUrl,),
                ),
              ],
            ):_imageFile!=null?
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton.icon(icon: Icon(Icons.crop),onPressed:_cropImage,label: Text("Crop",style: GoogleFonts.balooBhai(),),),
                    FlatButton.icon(icon: Icon(Icons.refresh),onPressed: clear,label: Text("Clear",style: GoogleFonts.balooBhai())),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Uploader(file:_imageFile,initialUrl: widget.initVideoUrl,),
                ),
              ],
            ):Container(),



            _video==null&&_imageFile==null?Padding(
              padding: const EdgeInsets.symmetric(horizontal:84.0,vertical: 8.0),
              child: ToggleSwitch(
                  minWidth: 95.0,
                  cornerRadius: 20,
                  activeBgColor: Colors.blueAccent,
                  activeTextColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveTextColor: Colors.white,
                  labels: ['Photo', 'Video'],
                  icons: [Icons.photo, Icons.videocam],
                  onToggle: (index) {
                    if(index==0){
                      setState(() {
                        photocapture=true;
                      });
                    }else if(index==1){
                      setState(() {
                        photocapture=false;
                      });
                    }
                  }),
            ):Container(),



            _video==null&&_imageFile==null?
            Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top:80.0),
                      child: Text("Select Media From\nGallery", style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
                    ),
                    SizedBox(height: 50,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        photocapture?IconButton(
                          icon: Icon(Icons.photo_camera,size: MediaQuery.of(context).size.width*0.08,),
                          onPressed: ()=>_pickImage(ImageSource.camera),
                        ):IconButton(
                          icon: Icon(Icons.videocam,size: MediaQuery.of(context).size.width*0.08,),
                          onPressed: ()=>_pickVideoFromCamera(),
                        ),
                        photocapture?IconButton(
                          icon: Icon(Icons.photo_library,size: MediaQuery.of(context).size.width*0.08),
                          onPressed: ()=>_pickImage(ImageSource.gallery),
                        ):IconButton(
                          icon: Icon(Icons.video_library,size: MediaQuery.of(context).size.width*0.08),
                          onPressed: ()=>_pickVideo(),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ):Container(),
          ],
        ),
      ),
    );
  }
}

class Uploader extends StatefulWidget {
  final File file;
  final String initialUrl,initVideoId;
  Uploader({Key key,this.file, this.initialUrl, this.initVideoId}) : super(key:key);
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage=FirebaseStorage(storageBucket: "gs://halkafulka-221d3.appspot.com");
  StorageUploadTask _task;
  Future<void> startUpload() async {
    String filePath='images/${DateTime.now()}.png';
    setState(() {
      _task=_storage.ref().child(filePath).putFile(widget.file);
    });
    var dowurl = await (await _task.onComplete).ref.getDownloadURL();
    var url = dowurl.toString();
    print(url);
    Firestore.instance.collection("allPosts").add({
      'title':_titleController.text,
      'subpara':_captionController.text,
      'postedby':loggedInEmail,
      'likes':0,
      'type':"image",
      'timestamp':Timestamp.now(),
      'link':url,
      'link2':widget.initialUrl,
      'type2':'video',
      'initVideoId':widget.initVideoId
    }).then((val){
      Firestore.instance.collection("allPosts").document(val.documentID).updateData({"id":val.documentID});
    });
  }


  Future<void> saveAsDraft() async {
    String filePath='drafts/${DateTime.now()}.png';
    setState(() {
      _task=_storage.ref().child(filePath).putFile(widget.file);
    });
    var dowurl = await (await _task.onComplete).ref.getDownloadURL();
    var url = dowurl.toString();
    print(url);
    Firestore.instance.collection("drafts").document(loggedInEmail).collection("drafts").add({
      'title':_titleController.text,
      'subpara':_captionController.text,
      'postedby':loggedInEmail,
      'likes':0,
      'timestamp':Timestamp.now(),
      'type':"image",
      'link':url,
      'link2':widget.initialUrl,
      'type2':'video',
      'initVideoId':widget.initVideoId

    }).then((value){
      Firestore.instance.collection("drafts").document(loggedInEmail).collection("drafts").document(value.documentID).updateData({"id":value.documentID});
    });
  }


  final _formKey = GlobalKey<FormState>();
  bool emptyfields=false;
  final _titleController=TextEditingController();
  final _captionController=TextEditingController();
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

  void clear(){
    setState(() {
      _imageFile=null;
      _video=null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_task!=null){
      return StreamBuilder<StorageTaskEvent>(
        stream: _task.events,
        builder: (context,snapshot){
          var event=snapshot?.data?.snapshot;
          double progressPercent= event !=null ?
          event.bytesTransferred/event.totalByteCount:0;
          return Column(
            children: <Widget>[
              _task.isComplete?
              Text("Upload Complete!",style: GoogleFonts.happyMonkey(color: Colors.black,fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700),):Container(),
              _task.isPaused?
              FloatingActionButton(
                heroTag: 284821324,
                child: Icon(Icons.play_arrow),
                onPressed: ()=>_task.isInProgress,
              ):Container(),
              _task.isInProgress?
              FloatingActionButton(
                heroTag: 34232,
                child: Icon(Icons.pause),
                onPressed: ()=>_task.isPaused,
              ):Container(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    "${(progressPercent*100).toStringAsFixed(2)}%",
                    style: GoogleFonts.happyMonkey(
                      color: Colors.lightBlueAccent,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white,
                  value:progressPercent,
                ),
              ),],
          );
        },
      );
    }else{
      return InkWell(
        onTap: (){
          myFocusNode.unfocus();
        },
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child:Column(
                children: <Widget>[
                  TextFormField(
                    controller: _titleController,
                    style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.05,color:Colors.black),
                    onSaved: (var value){
                      setState(() {
                        currentpost['title']=value;
                      });
                    },
                    validator: (value){
                      if(value==""||value==null){
                        return "Please enter a title";
                      }
                      else{
                        return null;
                      }
                    },
                    onChanged:(v)=> _formKey.currentState.validate(),
                    decoration: InputDecoration(
                      labelText: "Title",
                      errorStyle: GoogleFonts.balooBhai(),
                      labelStyle: GoogleFonts.balooBhaina(fontSize: 16),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 8.0),
                      suffixIcon: !emptyfields ? Icon(Icons.title,):Icon(Icons.error,color: Colors.red,),
                      border: InputBorder.none,
                    ),

                  ),

                  TextFormField(
                    focusNode: myFocusNode,
                    controller: _captionController,
                    style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.05,color:Colors.black,),
                    onSaved: (var value){
                      setState(() {
                        currentpost['caption']=value;
                      });
                    },
                    validator: (val){
                      if(val==""||val==null){
                        return "Please enter a title";
                      }
                      else{
                        return null;
                      }
                    },
                    onChanged: (val){
                      setState(() {
                        myFocusNode.requestFocus();
                        _formKey.currentState.validate();
                      });
                    },
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Caption",
                      errorStyle: GoogleFonts.balooBhai(),
                      labelStyle: GoogleFonts.balooBhaina(fontSize: 16),
                      contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                      suffixIcon: !emptyfields ? myFocusNode.hasFocus?IconButton(icon: Icon(Icons.check_circle,color: Colors.blueAccent,
                      ),
                        onPressed: (){
                          setState(() {
                            myFocusNode.unfocus();
                          });
                        },):Icon(Icons.description)
                          :Icon(Icons.error,color: Colors.red,),
                      border: InputBorder.none,
                    ),

                  ),
                ],
              ),

            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: FloatingActionButton.extended(
                    heroTag: 23523,
                      label:Text("Save Draft",style: GoogleFonts.balooBhai(color: Colors.white,),) ,
                      icon: Icon(Icons.drafts,color: Colors.white,) ,
                      backgroundColor: Colors.deepOrangeAccent,
                      onPressed: (){
                        if(_formKey.currentState.validate()){
                          saveAsDraft();
                        }
                      }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: FloatingActionButton.extended(
                    heroTag: 78078,
                      label:Text("Upload",style: GoogleFonts.balooBhai(color: Colors.white,),) ,
                      icon: Icon(Icons.cloud_upload,color: Colors.white,) ,
                      backgroundColor: Colors.indigoAccent,
                      onPressed: (){
                        if(_formKey.currentState.validate()){
                          startUpload();
                        }
                      }
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

  }
}





class VideoUploader extends StatefulWidget {
  final File file;
  final String initialUrl,initVideoId;
  VideoUploader({Key key,this.file, this.initialUrl, this.initVideoId}) : super(key:key);
  @override

  _VideoUploaderState createState() => _VideoUploaderState();
}

class _VideoUploaderState extends State<VideoUploader> {
  final FirebaseStorage _storage=FirebaseStorage(storageBucket: "gs://halkafulka-221d3.appspot.com/");
  StorageUploadTask _task;
  Future<void> startUpload() async {
    String filePath='videos/${DateTime.now()}.mp4';
    setState((){
      _task=_storage.ref().child(filePath).putFile(widget.file);
    });
    var dowurl = await (await _task.onComplete).ref.getDownloadURL();
    var url = dowurl.toString();
    Firestore.instance.collection("allPosts").add({
      'title':_titleController.text,
      'subpara':_captionController.text,
      'postedby':loggedInEmail,
      'likes':0,
      'timestamp':Timestamp.now(),
      'type':"video",
      'link':url,
      'link2':widget.initialUrl,
      'type2':'video',
      'initVideoId':widget.initVideoId

    }).then((val){
      Firestore.instance.collection("allPosts").document(val.documentID).updateData({"id":val.documentID});
    });
  }

  Future<void> saveAsDraft() async {
    String filePath='drafts/${DateTime.now()}.mp4';
    setState(() {
      _task=_storage.ref().child(filePath).putFile(widget.file);
    });
    var dowurl = await (await _task.onComplete).ref.getDownloadURL();
    var url = dowurl.toString();
    print(url);
    Firestore.instance.collection("drafts").document(loggedInEmail).collection("drafts").add({
      'title':_titleController.text,
      'subpara':_captionController.text,
      'postedby':loggedInEmail,
      'likes':0,
      'timestamp':Timestamp.now(),
      'type':"video",
      'link':url,
      'link2':widget.initialUrl,
      'type2':'video',
      'initVideoId':widget.initVideoId
    }).then((value){
      Firestore.instance.collection("drafts").document(loggedInEmail).collection("drafts").document(value.documentID).updateData({"id":value.documentID});
    });
  }

  final _formKey = GlobalKey<FormState>();
  bool emptyfields=false;
  final _titleController=TextEditingController();
  final _captionController=TextEditingController();
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

  void clear(){
    setState(() {
      _imageFile=null;
      _video=null;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(_task!=null){
      return StreamBuilder<StorageTaskEvent>(
        stream: _task.events,
        builder: (context,snapshot){
          var event=snapshot?.data?.snapshot;
          double progressPercent= event !=null ?
          event.bytesTransferred/event.totalByteCount:0;
          return Column(
            children: <Widget>[
              _task.isComplete?
              Text("Upload Complete!",style: GoogleFonts.happyMonkey(color: Colors.black,fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700),):Container(),
              _task.isPaused?
              FloatingActionButton(
                heroTag: 27368,
                child: Icon(Icons.play_arrow),
                onPressed: ()=>_task.isInProgress,
              ):Container(),
              _task.isInProgress?
              FloatingActionButton(
                heroTag: 8356,
                child: Icon(Icons.pause),
                onPressed: ()=>_task.isPaused,
              ):Container(),
              Center(
                child: Text(
                  "${(progressPercent*100).toStringAsFixed(2)}%",
                  style: GoogleFonts.balooBhai(
                    color: Colors.lightBlueAccent,
                    fontSize: 20.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white,
                  value:progressPercent,
                ),
              ),

            ],
          );
        },
      );
    }else{
      return InkWell(
        onTap: (){
          myFocusNode.unfocus();
        },
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child:Column(
                children: <Widget>[
                  TextFormField(
                    controller: _titleController,
                    style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.05,color:Colors.black),
                    onSaved: (var value){
                      setState(() {
                        currentpost['title']=value;
                      });
                    },
                    validator: (value){
                      if(value==""||value==null){
                        return "Please enter a title";
                      }
                      else{
                        return null;
                      }
                    },
                    onChanged:(v)=> _formKey.currentState.validate(),
                    decoration: InputDecoration(
                      labelText: "Title",
                      errorStyle: GoogleFonts.balooBhai(),
                      labelStyle: GoogleFonts.balooBhaina(fontSize: 16),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 8.0),
                      suffixIcon: !emptyfields ? Icon(Icons.title,):Icon(Icons.error,color: Colors.red,),
                      border: InputBorder.none,
                    ),

                  ),

                  TextFormField(
                    focusNode: myFocusNode,
                    controller: _captionController,
                    style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.05,color:Colors.black,),
                    onSaved: (var value){
                      setState(() {
                        currentpost['caption']=value;
                      });
                    },
                    validator: (val){
                      if(val==""||val==null){
                        return "Please enter a title";
                      }
                      else{
                        return null;
                      }
                    },
                    onChanged: (val){
                      setState(() {
                        myFocusNode.requestFocus();
                        _formKey.currentState.validate();
                      });
                    },
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Caption",
                      errorStyle: GoogleFonts.balooBhai(),
                      labelStyle: GoogleFonts.balooBhaina(fontSize: 16),
                      contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                      suffixIcon: !emptyfields ? myFocusNode.hasFocus?IconButton(icon: Icon(Icons.check_circle,color: Colors.blueAccent,
                      ),
                        onPressed: (){
                          setState(() {
                            myFocusNode.unfocus();
                          });
                        },):Icon(Icons.description)
                          :Icon(Icons.error,color: Colors.red,),
                      border: InputBorder.none,
                    ),

                  ),
                ],
              ),

            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: FloatingActionButton.extended(
                    heroTag: 363,
                      label:Text("Save Draft",style: GoogleFonts.balooBhai(color: Colors.white,),) ,
                      icon: Icon(Icons.drafts,color: Colors.white,) ,
                      backgroundColor: Colors.deepOrangeAccent,
                      onPressed: (){
                        if(_formKey.currentState.validate()){
                          saveAsDraft();
                        }
                      }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: FloatingActionButton.extended(
                    heroTag: 35899,
                      label:Text("Upload",style: GoogleFonts.balooBhai(color: Colors.white,),) ,
                      icon: Icon(Icons.cloud_upload,color: Colors.white,) ,
                      backgroundColor: Colors.indigoAccent,
                      onPressed: (){
                        if(_formKey.currentState.validate()){
                          startUpload();
                        }
                      }
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

  }
}
