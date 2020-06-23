import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaphulka1/login.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  //bool _rememberMe = false;
  final _emailController=TextEditingController();
  final _confirmPasswordController=TextEditingController();
  final _newPasswordController=TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey=new GlobalKey<ScaffoldState>();
  bool verifying =false;
  final _formKey = GlobalKey<FormState>();
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
                                "https://firebasestorage.googleapis.com/v0/b/halkafulka-221d3.appspot.com/o/simple.jpg?alt=media&token=719ff7c7-c7b6-4573-ab20-aef925020cae"
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
                      vertical: 70.0,
                    ),
                    child: Form(
                      key:_formKey ,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                                color: Colors.white),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'You can reset your password from here',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16),
                          ),
                          SizedBox(height: 40,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 10.0),
                              Container(
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: transBlue,
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(8),topLeft: Radius.circular(8)),
                                ),
                                height: 60.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      width:MediaQuery.of(context).size.width*0.65,
                                      child: TextFormField(
                                        cursorColor: Colors.white,
                                        keyboardType: TextInputType.emailAddress,
                                        style: GoogleFonts.aBeeZee(
                                          color: Colors.white,
                                        ),
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
                                        decoration: InputDecoration(
                                          errorMaxLines: 2,
                                          hintStyle: TextStyle(color: Colors.white),
                                          errorStyle: GoogleFonts.balooBhaina(color: Colors.white),
                                          contentPadding: const EdgeInsets.symmetric(horizontal:14.0,vertical: 8.0),
                                          border: InputBorder.none,
                                          hintText: 'Enter Email',
                                        ),
                                        controller: _emailController,
                                      ),
                                    ),
                                    Icon(Icons.alternate_email,color:Colors.white)
                                  ],
                                ),

                              ),

                              SizedBox(height: 1.0),
                              Container(
                                alignment: Alignment.centerLeft,
                                decoration: kBoxDecorationStyle,
                                height: 60.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      width:MediaQuery.of(context).size.width*0.65,
                                      child: TextFormField(
                                        cursorColor: Colors.white,
                                        keyboardType: TextInputType.emailAddress,
                                        style: GoogleFonts.aBeeZee(
                                          color: Colors.white,
                                        ),
                                        validator: (value){
                                          if(value==null||value==""){
                                            return "Password Field Empty";
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          errorMaxLines: 2,
                                          hintStyle: TextStyle(color: Colors.white),
                                          errorStyle: GoogleFonts.balooBhaina(color: Colors.white),
                                          contentPadding: const EdgeInsets.symmetric(horizontal:14.0,vertical: 8.0),
                                          border: InputBorder.none,
                                          hintText: 'Enter New Password',
                                        ),
                                        controller: _newPasswordController,
                                      ),
                                    ),
                                    Icon(Icons.lock,color: Colors.white,),
                                  ],
                                ),
                              ),

                              SizedBox(height: 1.0),
                              Container(
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: transBlue,
                                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(8),bottomLeft: Radius.circular(8)),
                                ),
                                height: 60.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      width:MediaQuery.of(context).size.width*0.65,
                                      child: TextFormField(
                                        cursorColor: Colors.white,
                                        keyboardType: TextInputType.emailAddress,
                                        style: GoogleFonts.aBeeZee(
                                          color: Colors.white,
                                        ),
                                        validator: (value){
                                          if(value==null||value==""){
                                            return "Password Field Empty";
                                          }
                                          else if(_newPasswordController.text!=_confirmPasswordController.text){
                                            return "Passwords do not Match";
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          errorMaxLines: 2,
                                          hintStyle: GoogleFonts.aBeeZee(color: Colors.white),
                                          errorStyle: GoogleFonts.balooBhaina(color: Colors.white),
                                          contentPadding: const EdgeInsets.symmetric(horizontal:14.0,vertical: 8.0),
                                          border: InputBorder.none,
                                          hintText: 'Confirm New Password',
                                        ),
                                        controller: _confirmPasswordController,
                                      ),
                                    ),
                                    Icon(Icons.lock,color: Colors.white,)
                                  ],
                                ),

                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 25.0),
                            width: double.infinity,
                            child: FlatButton(
                              onPressed: () async {
                                if(_formKey.currentState.validate()){
                                  Firestore.instance.collection("users").document("${_emailController.text.trim()}").get().then((doc) async {
                                    setState(() {
                                      verifying=true;
                                    });
                                    if(doc.exists){
                                      Firestore.instance.collection("users").document(doc.data['email']).updateData({
                                        "password":_confirmPasswordController.text,
                                      }).then((value){
                                        Navigator.of(context).push(new MaterialPageRoute(
                                            builder: (BuildContext context) => Login(message: "Password has been reset Successfully",)));
                                      });
                                    }
                                    else{
                                      _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.red,content: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Icon(Icons.close,color:Colors.white),
                                          ),
                                          Text("Email not Registered"),
                                        ],
                                      ),));
                                    }
                                  });
                                }
                              },
                              padding: EdgeInsets.all(10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              color: Colors.white,
                              child: Text(
                                'Reset Password',
                                style: GoogleFonts.balooBhai(
                                  color: Colors.blue,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                verifying?LinearProgressIndicator():Container(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(icon: Icon(Icons.arrow_back,color:Colors.white),
                    onPressed: ()=>Navigator.pushReplacement(context,MaterialPageRoute(
                      builder: (context){
                        return Login();
                      }
                    )),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


final kBoxDecorationStyle = BoxDecoration(
  color: transBlue,
);