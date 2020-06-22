import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'login.dart';


Future<void> main() async{
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseApp.configure(
      name:'Halka-Phulka',
      options: Platform.isAndroid
          ?const FirebaseOptions(
          googleAppID: '1:285987441589:android:110afaa8b026bc7e2da7fc',
          apiKey: "AIzaSyBmzJP8YkSVKZidd1uq5dX9_ebPjdw-ABc",
          databaseURL: "https://halkafulka-221d3.firebaseio.com/"
      ):null);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "Halka Phulka",
      debugShowCheckedModeBanner: false,
      home: Login(),
      /*routes: <String, WidgetBuilder> {
        '/home': (BuildContext context) => new MyBottomNavigationBar(),
        '/favourites':(BuildContext context) => new FavScreen(),
      },*/
      theme: ThemeData(
        primaryColor: Colors.pink,
        accentColor: Colors.blue,
      ),
    );
  }
}
