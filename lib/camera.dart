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

import 'home.dart';
Map<String, dynamic> currentpost = {'title': null, 'caption': null};
File _imageFile;
File _video;
File _cameraVideo;
class ImageCapture extends StatefulWidget {
  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  VideoPlayerController  _videoPlayerController;
  VideoPlayerController  _cameraVideoPlayerController;

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
    _video = video;
    _videoPlayerController = VideoPlayerController.file(_video)..initialize().then((_) {
      setState(() { });
      _videoPlayerController.play();
    });
  }


  _pickVideoFromCamera() async {
    File video = await ImagePicker.pickVideo(source: ImageSource.camera);
    _cameraVideo = video;
    _cameraVideoPlayerController = VideoPlayerController.file(_cameraVideo)..initialize().then((_) {
      setState(() { });
      _cameraVideoPlayerController.play();
    });
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
    _cameraVideo=null;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              _imageFile!=null?Column(
                children: <Widget>[
                  Container(
                    height: 400,
                    child: Image.file(_imageFile,
                      fit: BoxFit.fill,
                    ),

                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton.icon(icon: Icon(Icons.crop),onPressed:_cropImage,label: Text("Crop",style: GoogleFonts.balooBhai(),),),
                      FlatButton.icon(icon: Icon(Icons.refresh),onPressed: clear,label: Text("Clear",style: GoogleFonts.balooBhai())),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Uploader(file:_imageFile),
                  ),
                ],
              ):Container(),

              _video!=null ?Column(
                children: <Widget>[
                  _videoPlayerController.value.initialized
                      ? AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  )
                      : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton.icon(icon: Icon(Icons.refresh),onPressed: clear,label: Text("Refresh",style: GoogleFonts.balooBhai(),),),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: VideoUploader(file:_video),
                  ),
                ],
              ):Container(),

              _cameraVideo!=null?
              Column(
                children: <Widget>[
                  _videoPlayerController.value.initialized
                      ? AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: VideoUploader(file:_cameraVideo),
                  ),
                ],
              ):Container(),

              Padding(
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
              ),
            ],
          ),
          _video==null&&_imageFile==null?
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top:80.0),
                    child: Text("Select Media From\nGallery", style: GoogleFonts.aBeeZee(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
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
    );
  }
}

class Uploader extends StatefulWidget {
  final File file;
  Uploader({Key key,this.file}) : super(key:key);
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage=FirebaseStorage(storageBucket: "gs://halkafulka-221d3.appspot.com");
  StorageUploadTask _task;
  void startUpload(){
    String filePath='images/${DateTime.now()}.png';
    setState(() {
      _task=_storage.ref().child(filePath).putFile(widget.file);
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
              Text("Upload Complete!",style: GoogleFonts.aBeeZee(color: Colors.black,fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700),):Container(),
              _task.isPaused?
              FloatingActionButton(
                heroTag: 1,
                child: Icon(Icons.play_arrow),
                onPressed: ()=>_task.isInProgress,
              ):Container(),
              _task.isInProgress?
              FloatingActionButton(
                heroTag: 2,
                child: Icon(Icons.pause),
                onPressed: ()=>_task.isPaused,
              ):Container(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    "${(progressPercent*100).toStringAsFixed(2)}%",
                    style: GoogleFonts.aBeeZee(
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
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: FlatButton.icon(
          label:Text("Upload",style: GoogleFonts.balooBhai(color: Colors.black87,fontSize:18,),) ,
          icon: Icon(Icons.cloud_upload,color: Colors.grey,) ,
          onPressed: startUpload,
        ),
      );
    }

  }
}





class VideoUploader extends StatefulWidget {
  final File file;
  VideoUploader({Key key,this.file}) : super(key:key);
  @override
  _VideoUploaderState createState() => _VideoUploaderState();
}

class _VideoUploaderState extends State<VideoUploader> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseStorage _storage=FirebaseStorage(storageBucket: "gs://halkafulka-221d3.appspot.com/");
  StorageUploadTask _task;
  Future<void> startUpload() async {
    setState(() {
      _formKey.currentState.save();
    });
    String filePath='videos/${DateTime.now()}.mp4';
    setState((){
      _task=_storage.ref().child(filePath).putFile(widget.file);
    });
    var dowurl = await (await _task.onComplete).ref.getDownloadURL();
    var url = dowurl.toString();
    print(url);
    Firestore.instance.collection("allvideos").document("${DateTime.now().toIso8601String()}").setData({
      'id':"${DateTime.now().toIso8601String()}",
      'title':currentpost['title'],
      'subpara':currentpost['caption'],
      'postedby':loggedInEmail,
      'likes':0,
      'link':url
    });
  }
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
              Text("Upload Complete!",style: GoogleFonts.aBeeZee(color: Colors.black,fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700),):Container(),
              _task.isPaused?
              FloatingActionButton(
                heroTag: 1,
                child: Icon(Icons.play_arrow),
                onPressed: ()=>_task.isInProgress,
              ):Container(),
              _task.isInProgress?
              FloatingActionButton(
                heroTag: 2,
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
                    style: GoogleFonts.aBeeZee(fontSize: MediaQuery.of(context).size.width*0.05,color:Colors.black),
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
                    style: GoogleFonts.aBeeZee(fontSize: MediaQuery.of(context).size.width*0.05,color:Colors.black,),
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: FlatButton.icon(
                label:Text("Upload",style: GoogleFonts.balooBhai(color: Colors.black87,fontSize:18,),) ,
                icon: Icon(Icons.cloud_upload,color: Colors.grey,) ,
                onPressed: (){
                  if(_formKey.currentState.validate()){
                    startUpload();
                  }
                }
              ),
            ),
          ],
        ),
      );
    }

  }
}
