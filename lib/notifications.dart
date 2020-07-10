import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaphulka1/custom_icons_icons.dart';
import 'package:halkaphulka1/home.dart';



class Notifications extends StatefulWidget {
  final String userEmail;
  final int currentIndex;
  Notifications({this.userEmail, this.currentIndex});
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: DefaultTabController(
            length: 2,
            initialIndex: widget.currentIndex!=null?widget.currentIndex:0,
            child: Scaffold(
              appBar: AppBar(
                leading: Icon(Icons.notifications),
                actions: <Widget>[IconButton(icon:Icon(Icons.close,color: Colors.white),onPressed: ()=>Navigator.pop(context))],
                centerTitle: true,
                backgroundColor: deepRed,
                bottom: TabBar(
                  labelColor: Colors.white,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(icon:Icon(Icons.favorite)),
                    Tab(icon: Icon(Icons.chat)),
                  ],
                ),
                title: Text(
                  "Notifications",
                  style: GoogleFonts.balooBhaina(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25.0),
                ),
              ),
              body: TabBarView(
                children: [
                  StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection("notifications").document(loggedInEmail).collection("notifications_$loggedInEmail").orderBy('timestamp',descending: true).snapshots(),
                      builder: (context, snapshot) {
                        int current=0;
                        for(int i=0;i<snapshot.data.documents.length;i++){
                          if(!snapshot.data.documents.elementAt(i).data['seen']&& snapshot.data.documents.elementAt(i).data['postId']!=null){
                            current++;
                          }
                        }
                        return !snapshot.hasData?Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(child: Container(width:27,height: 27,child: CircularProgressIndicator(strokeWidth: 2,backgroundColor: Colors.white,))),
                        ):current!=0?ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return  !snapshot.data.documents.elementAt(index).data['seen']&& snapshot.data.documents.elementAt(index).data['postId']!=null ?Padding(
                              padding: const EdgeInsets.symmetric(horizontal:8.0),
                              child: Card(
                                elevation: 8.0,
                                child: ListTile(
                                    onTap: () {},
                                    trailing: IconButton(icon: Icon(Icons.delete,color: Colors.blueAccent,),onPressed: (){
                                      Firestore.instance.collection("notifications").document(loggedInEmail).collection("notifications_$loggedInEmail").document(snapshot.data.documents.elementAt(index).data['id'].toString()).updateData({
                                        "seen":true,
                                      });
                                    },),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal:4.0,vertical: 16.0),
                                      child: Text(snapshot.data.documents.elementAt(index).data['message'],style: GoogleFonts.happyMonkey(),),
                                    ),
                                    leading: snapshot.data.documents.elementAt(index).data['message'].toString().contains('disliked')?Icon(CustomIcons.sad_tear):Icon(Icons.favorite,color: deepRed,)
                                ),
                              ),
                            ):Container();
                          },
                        )
                        :Padding(
                          padding: const EdgeInsets.symmetric(vertical:60.0),
                          child: Text("No Recent Reactions",style: GoogleFonts.happyMonkey(fontWeight:FontWeight.bold,fontSize: 18),textAlign: TextAlign.center,),
                        )
                        ;
                      }
                  ),
                  StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection("notifications").document(loggedInEmail).collection("notifications_$loggedInEmail").orderBy('timestamp',descending: true).snapshots(),
                      builder: (context, snapshot) {
                        int current=0;
                        for(int i=0;i<snapshot.data.documents.length;i++){
                          if(!snapshot.data.documents.elementAt(i).data['seen']&& snapshot.data.documents.elementAt(i).data['postId']==null){
                            current++;
                          }
                        }
                        return !snapshot.hasData?Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(child: Container(width:27,height: 27,child: CircularProgressIndicator(strokeWidth: 2,backgroundColor: Colors.white,))),
                        ):current!=0?ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return  !snapshot.data.documents.elementAt(index).data['seen']&& snapshot.data.documents.elementAt(index).data['postId']==null?Padding(
                              padding: const EdgeInsets.symmetric(horizontal:8.0),
                              child: Card(
                                elevation: 8.0,
                                child: ListTile(
                                  onTap: () {},
                                  trailing: IconButton(icon: Icon(Icons.delete,color: Colors.blueAccent,),onPressed: (){
                                    Firestore.instance.collection("notifications").document(loggedInEmail).collection("notifications_$loggedInEmail").document(snapshot.data.documents.elementAt(index).data['id'].toString()).updateData({
                                      "seen":true,
                                    });
                                  },),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal:4.0,vertical: 16.0),
                                    child: Text(snapshot.data.documents.elementAt(index).data['message'],style: GoogleFonts.happyMonkey(),),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage:
                                    AdvancedNetworkImage('https://firebasestorage.googleapis.com/v0/b/halkafulka-221d3.appspot.com/o/appicon.png?alt=media&token=1149b22a-aded-4a39-907e-f7df06aad868',useDiskCache: true,
                                    ),
                                  ),
                                ),
                              ),
                            ):Container();
                          },
                        ):Padding(
                        padding: const EdgeInsets.symmetric(vertical:60.0),
                        child: Text("No Active Notifications",style: GoogleFonts.happyMonkey(fontWeight:FontWeight.bold,fontSize: 18),textAlign: TextAlign.center,),
                        )
                        ;
                      }
                  ),
                ],
              ),
            )
        )
    );
  }
}
