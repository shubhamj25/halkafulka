import 'dart:convert';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:halkaphulka1/signup.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'forgetPassword.dart';
import 'dart:async';
import 'custom_icons_icons.dart';
import 'forgotPass.dart';
import 'home.dart';


Color transBlue=Color.fromARGB(155, 0, 0, 80);
bool _rememberMe = false;

class Login extends StatefulWidget {
  final String message;
  Login({this.message});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool userexists=false;
  var prefs;
  bool loginpress=false;
  final _formKey = GlobalKey<FormState>();
  final _emailController=TextEditingController();
  final _passwordController=TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey=new GlobalKey<ScaffoldState>();
  bool loggingin=false;
  @override
  void initState() {
    super.initState();
    globalVarInit();

  }

  globalVarInit() async{
    prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInEmail = prefs.getString('loggedInEmail') ?? null;
      loggedInPassword = prefs.getString('loggedInPassword') ?? null;
    });
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 30),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              width: 50,height: 50,
              child: FloatingActionButton(
                  backgroundColor: Colors.indigoAccent,
                  heroTag: 234,
                  onPressed: (){
                    setState(() {
                      loggingin=true;
                    });
                    initiateFacebookLogin();
                  },
                  child: Icon(CustomIcons.facebook_f,color: Colors.white,)),
            ),
            Container(
              width: 50,height: 50,
              child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  heroTag: 084,
                  onPressed: (){
                    setState(() {
                      loggingin=true;
                    });

                    signInWithGoogle().whenComplete(() => loggedInEmail!=null&&loggedInEmail!=""?Navigator.pushReplacement(context,MaterialPageRoute(builder: (context){
                      return MyBottomNavigationBar(username: loggedInEmail,rememberMe:_rememberMe);
                    }) ):
                    _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor:deepRed,content: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(Icons.close,color:Colors.white),
                        ),
                        Text("No Account Selected"),
                      ],
                    ),))).then((value){
                      loggingin=false;
                    });

                  },
                  child: Icon(CustomIcons.google,color: Colors.blueAccent,)),
            ),

            Container(
              width: 50,height: 50,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: (){
                 Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SignupScreen()));
                },
                heroTag: 449,
                child: Icon(Icons.group_add,color: deepRed,),
              ),
            ),
          ]
      ),
    );
  }

  void initiateFacebookLogin() async {
    var facebookLoginResult =
    await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${facebookLoginResult
                .accessToken.token}&picture?width=500,height=500');

        var profile = json.decode(graphResponse.body);
        print(profile.toString());

        onLoginStatusChanged(true, profileData: profile);
        break;
    }
  }

  Future<void> onLoginStatusChanged(bool isLoggedIn,{Map<String,dynamic> profileData}) async {
      if(isLoggedIn){
        setState((){
          loggedInEmail=profileData['email'];
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('loggedInEmail', loggedInEmail);
        Firestore.instance.collection("users").document("${profileData['email']}").get().then((doc) async {
          if(doc.exists){
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){return MyBottomNavigationBar(username: profileData['email'],rememberMe:_rememberMe);}));
          }
          else{
            setState(() async {
              loggedInEmail=profileData['email'];
            });
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('loggedInEmail', loggedInEmail);
            Firestore.instance.collection("users").document("${profileData['email']}").setData({
              "uid":profileData['access_token'],
              "name":profileData['name'],
              "email":profileData['email'],
              "photoURL":profileData['picture'],
              "password":"hf@${DateTime.now().millisecond}",
            },merge: true);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){return MyBottomNavigationBar(username: profileData['email'],rememberMe:_rememberMe);}));
          }
        });
      }

  }


 /* Widget _buildSignupBtn() {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Text("Don\'t have an Account?",textAlign: TextAlign.center,style: GoogleFonts.balooBhaina(color: Colors.white,fontSize: 18.0),),
        Padding(
          padding: const EdgeInsets.only(top:40.0,left:70,right:70.0),
          child: FloatingActionButton.extended(
              backgroundColor: Colors.white,
              onPressed: (){
               // Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => NewSinup()));
              },
              heroTag: 649,
              icon: Icon(Icons.group_add,color: deepRed,),
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 3.0),
                child: Text("SignUp",textAlign: TextAlign.center,style: GoogleFonts.balooBhaina(color: deepRed,fontSize: 16.0),),
              )),
        ),
      ],
    );
  }*/
  bool hidepass=true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: <Widget>[
                Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: new DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AdvancedNetworkImage(
                                "https://firebasestorage.googleapis.com/v0/b/halkafulka-221d3.appspot.com/o/forest.jpg?alt=media&token=a9501dab-0169-42bb-9af2-9e8e2b9b54fc"
                                ,useDiskCache: true
                            ),
                          ),
                        )
                    )
                ),
                Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 30.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text("Halka Phulka",style: GoogleFonts.laBelleAurore(fontWeight: FontWeight.bold,fontSize: 35,color:Colors.white),),
                              Text("#Local Vocal",style: GoogleFonts.laBelleAurore(fontWeight: FontWeight.bold,fontSize: 25,color:Colors.white),),
                            ],
                          ),

                          loginpress &&!_formKey.currentState.validate()?
                          SizedBox(height: MediaQuery.of(context).size.height*0.03):Container(),

                          !loginpress?
                          SizedBox(height: MediaQuery.of(context).size.height*0.06):Container(),
                          //email
                          loggedInPassword==null?
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(155, 0, 0, 80),
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(8),topLeft: Radius.circular(8)),
                                ),
                                width: MediaQuery.of(context).size.width*0.75,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width:MediaQuery.of(context).size.width*0.6,
                                      child: TextFormField(
                                        validator:(String value){
                                          Pattern pattern =
                                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                          RegExp regex = new RegExp(pattern);
                                          if (!regex.hasMatch(value)) {
                                            return "Enter a valid email";
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                        onChanged: (v)=>_formKey.currentState.validate(),
                                        cursorColor: Colors.white,
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        style: GoogleFonts.aBeeZee(fontSize: 16,color: Colors.white),
                                        decoration: InputDecoration(
                                            errorMaxLines: 2,
                                            errorStyle: GoogleFonts.balooBhaina(color: Colors.white),
                                            hintStyle: GoogleFonts.aBeeZee(fontSize: 16,color: Colors.white),
                                            contentPadding: const EdgeInsets.symmetric(horizontal:14.0,vertical: 8.0),
                                            border: InputBorder.none,
                                            hintText: 'Email'
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.mail,color: Colors.white,size: 22,),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ):Container(),
                          //password
                          loggedInPassword==null?
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(155, 0, 0, 80),
                                ),
                                width: MediaQuery.of(context).size.width*0.75,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.6,
                                      child: TextFormField(
                                        cursorColor: Colors.white,
                                        controller: _passwordController,
                                        obscureText: hidepass,
                                        style: GoogleFonts.aBeeZee(fontSize: 16,color: Colors.white),
                                        validator:(String value){
                                          if(value==""||value==null){
                                            return "Empty Password";
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                        onChanged: (val)=>_formKey.currentState.validate(),
                                        decoration: InputDecoration(
                                          errorMaxLines: 2,
                                          hintStyle: GoogleFonts.aBeeZee(fontSize: 16,color: Colors.white),
                                          errorStyle: GoogleFonts.balooBhaina(color: Colors.white),
                                          contentPadding: const EdgeInsets.symmetric(horizontal:14.0,vertical: 8.0),
                                          border: InputBorder.none,
                                          hintText: 'Password',
                                        ),
                                      ),
                                    ),
                                    IconButton(icon: Icon(hidepass?Icons.lock:Icons.lock_open,color: Colors.white,),onPressed: (){
                                      setState(() {
                                        if(hidepass==true){
                                          hidepass=false;
                                        }
                                        else if(hidepass==false){
                                          hidepass=true;
                                        }
                                      });
                                    },),
                                  ],
                                ),
                              ),
                            ],
                          ):Container(),
                          //Forgot pass


                          loggedInPassword!=null&&loggedInEmail!=null?
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical:16.0,horizontal: 10.0),
                            child: Text("You previously Signed in with $loggedInEmail.\nDo you want to Continue ?",textAlign: TextAlign.center
                              ,style: GoogleFonts.poppins(fontSize: 20,color: Colors.white,),),
                          ):Container(),


                          SizedBox(height: 2,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.75,
                            child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  loggingin=true;
                                  loginpress=true;
                                });
                                if(loggedInEmail!=null&&loggedInPassword!=null){
                                  Firestore.instance.collection("users").document("$loggedInEmail").get().then((doc){
                                    if(doc.exists){
                                      if(loggedInPassword==doc.data['password']){
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder:(context){return MyBottomNavigationBar(username:loggedInEmail,rememberMe:_rememberMe);}));
                                      }else{
                                        _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.red,content: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Icon(Icons.close,color:Colors.white),
                                            ),
                                            Expanded(child: Text("Invalid Session or Password might have been changed")),
                                          ],
                                        ),));
                                        setState(() {
                                          loggedInPassword=null;
                                          loggedInEmail=null;
                                        });
                                      }
                                    }
                                    setState(() {
                                      loggingin=false;
                                    });
                                  });
                                }
                                else{
                                  if(_formKey.currentState.validate()){
                                    Firestore.instance.collection("users").document("${_emailController.text.trim()}").get().then((doc){
                                      if(doc.exists){
                                        if(_passwordController.text.trim()==doc.data['password']){
                                         Navigator.pushReplacement(context, MaterialPageRoute(builder:(context){return MyBottomNavigationBar(username: _emailController.text.trim(),rememberMe:_rememberMe);})).then((value) async {
                                            loggedInEmail=_emailController.text.trim();
                                            loggedInPassword=_passwordController.text;
                                            final prefs = await SharedPreferences.getInstance();
                                            prefs.setString('loggedInEmail', _emailController.text.trim());
                                            prefs.setString('loggedInPassword', _passwordController.text);
                                          });

                                        }else{
                                          _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.red,content: Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Icon(Icons.close,color:Colors.white),
                                              ),
                                              Text("Invalid Credentials"),
                                            ],
                                          ),));
                                        }
                                      }
                                      else{
                                        _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.red,content: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Icon(Icons.error,color:Colors.white),
                                            ),
                                            Text("SignUp First Please"),
                                          ],
                                        ),));
                                      }
                                      setState(() {
                                        loggingin=false;
                                      });
                                    });
                                  }
                                  else{
                                    setState(() {
                                      loggingin=false;
                                    });
                                  }
                                }
                              },
                              padding: EdgeInsets.all(4.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(18),bottomLeft: Radius.circular(18)),
                              ),
                              color: Colors.white,
                              child: Text(
                                (loggedInEmail!=null&&loggedInPassword!=null)?'Continue':'Login',
                                style: GoogleFonts.balooBhai(
                                  letterSpacing: 1.5,
                                  fontSize: 18.0,
                                  color: Colors.black54
                                ),
                              ),
                            ),
                          ),


                          loggedInPassword==null?
                          Container(
                            alignment: Alignment.centerLeft,
                            child: FlatButton(
                              onPressed: () {
                               Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => ForgetPassword()));
                              },
                              padding: EdgeInsets.only(left: 22.0),
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),
                              ),
                            ),
                          ):Container(),
                          //Remember Me
                          Padding(
                            padding: const EdgeInsets.only(left:22.0),
                            child: Container(
                              height: 20.0,
                              alignment: Alignment.topCenter,
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top:8.0),
                                    child: Switch(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value;
                                        });
                                      },
                                      activeTrackColor: Colors.indigoAccent,
                                      activeColor: deepRed,
                                      inactiveTrackColor: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Remember me',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: MediaQuery.of(context).size.height*0.1,),
                          _buildSocialBtnRow(),
                        ],
                      ),
                    ),
                  ),
                ),
                (loggedInPassword!=null&&loggedInEmail!=null)?Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(icon: Icon(Icons.home,color: Colors.white,),
                    onPressed: () async {
                      setState(() {
                        loggedInEmail=null;
                        loggedInPassword=null;
                        prefs.remove('loggedInEmail');
                        prefs.remove('loggedInPassword');
                      });
                    },),
                ):Container(),
                widget.message!=null?Container(width:MediaQuery.of(context).size.width,height:50.0,color: Colors.blueAccent,child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(Icons.account_circle,color: Colors.white,),
                      ),
                      Expanded(child: Text("${widget.message}",style: TextStyle(color: Colors.white,fontSize:15.0),)),
                    ],
                  ),
                ),):Container(),
                loggingin?LinearProgressIndicator():Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: Colors.indigo,
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);



final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
var facebookLogin = FacebookLogin();
Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
  await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  updateUserData(user);
  return 'signInWithGoogle succeeded: $user';
}

void signOutGoogle() async{
  await googleSignIn.signOut();
  loggedInEmail="";
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('loggedInEmail');
}


void updateUserData(FirebaseUser user) async {
  loggedInEmail=user.email;
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('loggedInEmail', loggedInEmail);
  Firestore.instance.collection("users").document(user.email).get().then((value){
    if(!value.exists){
      DocumentReference ref = Firestore.instance.collection('users').document(user.email);
      return ref.setData({
        'uid': user.uid,
        'email': user.email,
        'photoURL': user.photoUrl,
        'name': user.displayName,
        'lastSeen': DateTime.now(),
        "password":"hf@${DateTime.now().millisecond}",
      }, merge: true);
    }
    else
    {
      return null;
    }
  });
}
