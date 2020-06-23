import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'datetime_picker.dart';
import 'login.dart';

Map<String, dynamic> signupData = {'name': null,'email':null, 'dob': null,'password':null};
bool emptyfields=false;
final _formKey = GlobalKey<FormState>();
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailFieldKey = GlobalKey<FormFieldState>();
  final D = TextEditingController();
  final emailController = TextEditingController();
  final passwordController=TextEditingController();
  bool emailAvailable = true;
  bool onEditing = false;
  bool hidepassword=true;
  bool passwordvalidation=true;
  bool enteringpass=false;

  bool validateUppercase(String value){
    Pattern pattern =
        r'^(?=.*?[A-Z]).{0,}$';
    RegExp regex = new RegExp(pattern);
    return regex.hasMatch(value);
  }

  bool validatelowercase(String value){
    Pattern pattern =
        r'^(?=.*?[a-z]).{0,}$';
    RegExp regex = new RegExp(pattern);
    return regex.hasMatch(value);
  }

  bool validatedigits(String value){
    Pattern pattern =
        r'^(?=.*?[0-9]).{0,}$';
    RegExp regex = new RegExp(pattern);
    return regex.hasMatch(value);
  }

  bool validatespecialchar(String value){
    Pattern pattern =
        r'^(?=.*?[!@#\$&*~]).{0,}$';
    RegExp regex = new RegExp(pattern);
    return regex.hasMatch(value);
  }
  bool noofdigits(String value){
    if(value.toString().length<8){
      return false;
    }
    else{
      return true;
    }
  }
  bool validating=false;
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    D.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
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
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  validating ?LinearProgressIndicator():Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
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
                  Container(
                    child: Form(
                        key: _formKey,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal:20.0),
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Sign Up',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28.0,
                                      color: Colors.white),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  'Email helps to discover people around you',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,

                                      fontWeight: FontWeight.w800,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: 30.0,
                                ),
                                //Username field and validation
                                Material(
                                  color: Color.fromARGB(155, 0, 0, 80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(8),topLeft: Radius.circular(8)),
                                  ),
                                  child: TextFormField(
                                    key: _emailFieldKey,
                                    style: GoogleFonts.aBeeZee(
                                        color: Colors.white),
                                    onSaved: (String value){
                                      setState(() {
                                        signupData['email']=value;
                                      });
                                    },
                                    onChanged: (String value) async {
                                      Firestore.instance.collection("users").document(emailController.text.trim()).get().then((value){
                                        if(value.exists){
                                          setState(() {
                                            onEditing = true;
                                            emailAvailable = false;
                                          });
                                          _emailFieldKey.currentState.validate();
                                        }
                                        else{
                                          setState(() {
                                            onEditing = true;
                                            emailAvailable = true;
                                          });
                                          _emailFieldKey.currentState.validate();
                                        }
                                      });
                                    },
                                    validator:(String value) {
                                      Pattern pattern =
                                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                      RegExp regex = new RegExp(pattern);
                                      if(value==""){
                                        return "Please enter an email ";
                                      }
                                      else if (!regex.hasMatch(value)) {
                                        return "Enter a valid email";
                                      }
                                      else if (emailAvailable==false) {
                                        return "Email already registered";
                                      }
                                      else if (emailAvailable) {
                                        return null;
                                      }
                                      return null;
                                    },
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      hintStyle: GoogleFonts.aBeeZee(color: Colors.white),
                                      suffixIcon: onEditing
                                          ? (emailAvailable && emailController.text != ""
                                          ? Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      )
                                          : Icon(Icons.error, color: Colors.white))
                                          : null,
                                        errorMaxLines: 2,
                                        errorStyle: GoogleFonts.balooBhaina(color: Colors.white),
                                        contentPadding: const EdgeInsets.all(14.0),
                                        border: InputBorder.none,
                                        hintText: 'Email'
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 1.0,
                                ),
                                Material(
                                  color: Color.fromARGB(155, 0, 0, 80),
                                  child: TextFormField(
                                    onSaved: (String value){
                                      setState(() {
                                        signupData['name']=value;
                                      });
                                    },
                                    onChanged: (String val){
                                      setState(() {
                                        _formKey.currentState.validate();
                                      });
                                    },
                                    style: GoogleFonts.aBeeZee(color: Colors.white,),
                                    validator: (String value){
                                      if(value==""||value==null){
                                        return "Empty Field";
                                      }
                                      else{
                                        return null;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintStyle: GoogleFonts.aBeeZee(color: Colors.white),
                                      hintText: "Enter your Name",
                                        errorMaxLines: 2,
                                        errorStyle: GoogleFonts.balooBhaina(color: Colors.white),
                                        contentPadding: const EdgeInsets.all(14.0),
                                        border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 1.0,
                                ),
                                Material(
                                  color: Color.fromARGB(155, 0, 0, 80),
                                  child: DateTimeField(
                                    onSaved: (DateTime value){
                                      setState(() {
                                        signupData['dob']=value.toIso8601String();
                                      });
                                    },
                                    format: DateFormat.yMMMEd(),
                                    style: GoogleFonts.aBeeZee(color: Colors.white, ),
                                    decoration: InputDecoration(
                                      hintStyle: GoogleFonts.aBeeZee(color: Colors.white),
                                      hintText: "Date of Birth",
                                        errorMaxLines: 2,
                                        errorStyle: GoogleFonts.balooBhaina(color: Colors.white),
                                        contentPadding: const EdgeInsets.all(14),
                                        border: InputBorder.none,
                                    ),
                                    validator: (DateTime value){
                                      if(value==null){
                                        return "DOB shouldn't be left empty";
                                      }
                                      else{
                                        return null;
                                      }
                                    },
                                    onShowPicker: (context, currentValue) {
                                      return showDatePicker(
                                        context: context,
                                        firstDate: DateTime(1900),
                                        initialDate: currentValue ?? DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 1.0,
                                ),
                                Material(
                                  color: Color.fromARGB(155, 0, 0, 80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(8),bottomLeft: Radius.circular(8)),
                                  ),
                                  child: TextFormField(
                                    onSaved: (String value){
                                      setState(() {
                                        signupData['password']=value;
                                      });
                                    },
                                    obscureText: hidepassword,
                                    style: GoogleFonts.poppins(color: Colors.white),
                                    validator: (String value){
                                      Pattern pattern =
                                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                                      RegExp regex = new RegExp(pattern);
                                      if(value==""){
                                        return "Empty Password";
                                      }
                                      else if (!regex.hasMatch(value)) {
                                        setState(() {
                                          passwordvalidation=false;
                                        });
                                        return "Invalid Password [ Tap the error button ]";
                                      }
                                      else{
                                        setState(() {
                                          passwordvalidation=true;
                                        });
                                        return null;
                                      }
                                    },
                                    onChanged:(String value){
                                      setState(() {
                                        _formKey.currentState.validate();
                                        enteringpass=true;
                                      });
                                      Pattern pattern =
                                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                                      RegExp regex = new RegExp(pattern);
                                      if (!regex.hasMatch(value)) {
                                        setState(() {
                                          passwordvalidation=false;
                                        });
                                      }
                                      else{
                                        setState(() {
                                          passwordvalidation=true;
                                        });
                                      }
                                    },
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                      hintStyle: GoogleFonts.aBeeZee(color: Colors.white),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          enteringpass?(!passwordvalidation?IconButton(icon: Icon(Icons.error,color:Colors.white),
                                            onPressed: (){
                                              showDialog(
                                                  context: context,
                                                  builder: (context){
                                                    return StatefulBuilder(builder: (context,setState){
                                                      return Dialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                        ),
                                                        child: Container(
                                                          margin: const EdgeInsets.all(20.0),
                                                          child: ListView(
                                                            shrinkWrap: true,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(vertical:5.0),
                                                                child: Row(
                                                                  children: <Widget>[
                                                                    Expanded(
                                                                      child: Text("The password must contain",style: GoogleFonts.poppins(
                                                                          fontWeight: FontWeight.bold,

                                                                          fontSize: 20.0
                                                                      ),),
                                                                    ),
                                                                    IconButton(
                                                                      icon: Icon(Icons.close),
                                                                      onPressed: ()=>Navigator.pop(context),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:const EdgeInsets.symmetric(vertical:5.0),
                                                                child: Row(
                                                                  children: <Widget>[
                                                                    !noofdigits(passwordController.text) ?Icon(Icons.close,color:Colors.red):Icon(Icons.check,color:Colors.green),
                                                                    Expanded(child: Text("Should atleast contain 8 letters",style: GoogleFonts.poppins(
                                                                        fontWeight: FontWeight.bold,

                                                                        fontSize: 15
                                                                    )),),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(vertical:5.0),
                                                                child: Row(
                                                                  children: <Widget>[
                                                                    !validateUppercase(passwordController.text) ?Icon(Icons.close,color:Colors.red):Icon(Icons.check,color:Colors.green),
                                                                    Expanded(child: Text("Should atleast contain 1 Uppercase letter",style: GoogleFonts.poppins(
                                                                        fontWeight: FontWeight.bold,

                                                                        fontSize: 15
                                                                    )),),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(vertical:5.0),
                                                                child: Row(
                                                                  children: <Widget>[
                                                                    !validatelowercase(passwordController.text) ?Icon(Icons.close,color:Colors.red):Icon(Icons.check,color:Colors.green),
                                                                    Expanded(child: Text("Should atleast contain 1 lowercase letter",style: GoogleFonts.poppins(
                                                                        fontWeight: FontWeight.bold,

                                                                        fontSize: 15
                                                                    )),),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(vertical:5.0),
                                                                child: Row(
                                                                  children: <Widget>[
                                                                    !validatedigits(passwordController.text) ?Icon(Icons.close,color:Colors.red):Icon(Icons.check,color:Colors.green),
                                                                    Expanded(child: Text("Should atleast contain 1 digit",style: GoogleFonts.poppins(
                                                                        fontWeight: FontWeight.bold,

                                                                        fontSize: 15
                                                                    )),),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(vertical:5.0),
                                                                child: Row(
                                                                  children: <Widget>[
                                                                    !validatespecialchar(passwordController.text) ?Icon(Icons.close,color:Colors.red):Icon(Icons.check,color:Colors.green),
                                                                    Expanded(child: Text("Should contain at least one Special character",style: GoogleFonts.poppins(
                                                                        fontWeight: FontWeight.bold,

                                                                        fontSize: 15
                                                                    ))),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                  }
                                              );
                                            },
                                          ):Icon(Icons.check,color: Colors.white,)):Container(),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                hidepassword = !hidepassword;
                                              });
                                            },
                                            icon: Icon(hidepassword ? Icons.visibility_off : Icons.visibility,color: Colors.white,),
                                          ),
                                        ],
                                      ),
                                      hintText:'Password',
                                        errorMaxLines: 2,
                                        errorStyle: GoogleFonts.balooBhaina(color: Colors.white),
                                        contentPadding: const EdgeInsets.all(14.0),
                                        border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'By creating your account you accept our Terms & Conditions',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,

                                        fontWeight: FontWeight.w800,
                                        fontSize: 15),
                                  ),
                                ),
                                SizedBox(height: 20,),

                                FlatButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () async {
                                    setState(() {
                                      validating=true;
                                    });
                                    Firestore.instance.collection("users").document(emailController.text.trim()).get().then((value){
                                      if(value.exists){
                                        setState(() {
                                          onEditing = true;
                                          emailAvailable = false;
                                        });
                                        _formKey.currentState.validate();
                                      }
                                      else{
                                        setState(() {
                                          onEditing = true;
                                          emailAvailable = true;
                                        });
                                        _formKey.currentState.validate();
                                      }
                                    });
                                    if(_formKey.currentState.validate()){
                                      _formKey.currentState.save();
                                      print(signupData);
                                      Firestore.instance.collection("users").document(emailController.text.trim().toString()).setData({
                                        'email':signupData['email'],
                                        'name':signupData['name'],
                                        'dob':signupData['dob'],
                                        'password':signupData['password']
                                      }).then((value){
                                        Flushbar(
                                          shouldIconPulse: true,
                                          isDismissible: true,
                                          flushbarPosition: FlushbarPosition.TOP,
                                          titleText: Text("SignUp Successful",style: GoogleFonts.aBeeZee(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 17.0),),
                                          messageText: Text("Your account with email ${emailController.text.trim()} has been created",style: GoogleFonts.aBeeZee(color: Colors.white,fontSize: 15.0)),
                                          duration: Duration(seconds: 1),
                                          icon: Icon(Icons.check,color: Colors.white,),
                                          backgroundColor:  Colors.green,
                                        )..show(context).then((value){
                                          Navigator.pop(context);
                                        });
                                      });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.0)),
                                    padding: EdgeInsets.symmetric(vertical: 10.0),
                                    width: double.infinity,
                                    child: Center(
                                      child: Text(
                                        'Create Account',
                                        style: GoogleFonts.balooBhai(
                                            fontSize: 20.0,
                                            color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

