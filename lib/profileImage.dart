import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'home.dart';

class ProfileImageCapture extends StatefulWidget {
  final String email;
  ProfileImageCapture(this.email);
  @override
  _ProfileImageCaptureState createState() => _ProfileImageCaptureState();
}

class _ProfileImageCaptureState extends State<ProfileImageCapture> {
  File _imageFile;
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
    });
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if(photocapture)IconButton(
                icon: Icon(Icons.photo_camera,size: MediaQuery.of(context).size.width*0.08,),
                onPressed: ()=>_pickImage(ImageSource.camera),
              ),
              if(photocapture)IconButton(
                icon: Icon(Icons.photo_library,size: MediaQuery.of(context).size.width*0.08),
                onPressed: ()=>_pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close,color: deepRed,),
                  onPressed:() {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            if(_imageFile!=null) ...[

              Image.file(_imageFile),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(child: Icon(Icons.crop),onPressed:_cropImage,),
                  FlatButton(child: Icon(Icons.refresh),onPressed: clear),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Uploader(file:_imageFile,email: widget.email,),
              ),
            ],
            if(_imageFile==null)
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top:80.0),
                    child: Text("Select Image From\nGallery", style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class Uploader extends StatefulWidget {
  final File file;
  final String email;
  Uploader({Key key,this.file, this.email}) : super(key:key);
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage = FirebaseStorage(
      storageBucket: "gs://halkafulka-221d3.appspot.com");
  StorageUploadTask _task;

  Future<void> startUpload() async {
    String filePath = 'profileimages/${DateTime.now()}.png';
    setState(() {
      _task = _storage.ref().child(filePath).putFile(widget.file);
    });
    var downUrl = await (await _task.onComplete).ref.getDownloadURL();
    var url = downUrl.toString();
    Firestore.instance.collection("users").document("${widget.email}").updateData({
      "photoURL":url
    });
  }
  @override
  Widget build(BuildContext context) {
    if (_task != null) {
      return StreamBuilder<StorageTaskEvent>(
        stream: _task.events,
        builder: (context, snapshot) {
          var event = snapshot?.data?.snapshot;
          double progressPercent = event != null ?
          event.bytesTransferred / event.totalByteCount : 0;
          return Column(
            children: <Widget>[
              if(_task.isComplete)
                Text("Upload Complete!",
                  style: GoogleFonts.happyMonkey(color: Colors.black, fontSize: MediaQuery
                      .of(context)
                      .size
                      .width * 0.05, fontWeight: FontWeight.w700),),
              if(_task.isPaused)
                FloatingActionButton(
                  heroTag: 1,
                  child: Icon(Icons.play_arrow),
                  onPressed: () => _task.isInProgress,
                ),
              if(_task.isInProgress)
                FloatingActionButton(
                  heroTag: 2,
                  child: Icon(Icons.pause),
                  onPressed: () => _task.isPaused,
                ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    "${(progressPercent * 100).toStringAsFixed(2)}%",
                    style: GoogleFonts.happyMonkey(
                      color: Colors.lightBlueAccent,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white,
                  value: progressPercent,
                ),
              ),
            ],
          );
        },
      );
    } else {
      return FlatButton.icon(
        label: Text(
          "Upload", style: GoogleFonts.happyMonkey(color: Colors.black, fontSize: MediaQuery
            .of(context)
            .size
            .width * 0.05, fontWeight: FontWeight.w700),),
        icon: Icon(Icons.cloud_upload),
        onPressed: startUpload,
      );
    }
  }
}