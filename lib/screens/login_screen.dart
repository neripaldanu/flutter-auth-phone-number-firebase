import 'package:auth_firebase_phone_number/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE
}

class LoginScreen extends StatefulWidget {


  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  MobileVerificationState currrantState = MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  final mobileController = TextEditingController();
  final otpController = TextEditingController();


  FirebaseAuth _auth = FirebaseAuth.instance;

  String verificationId;

  bool showLoading = false;

  void signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential) async{
    setState(() {
      showLoading = true;
    });

    
    
    try {
      final authCredential= await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showLoading=false;
      });
      if(authCredential?.user != null){
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {

      setState(() {
        showLoading = false;
      });

      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(e.message)));
      // TODO
    }
  }

  getMobileWidgetState(context) {
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: mobileController,
          decoration: InputDecoration(
              hintText: "Phone Number"
          ),
        ),
        SizedBox(
          height: 16,
        ),
        FlatButton(
          onPressed: () {
            setState(() {
              showLoading = true;
            });
            _auth.verifyPhoneNumber(
                phoneNumber: mobileController.text,
                verificationCompleted: (phoneAuthCredential) async {
                  setState(() {
                    showLoading = false;
                  });
                  //signInWithPhoneAuthCredential(phoneAuthCredential);

                },
                verificationFailed: (verificationFailed) async{
                  setState(() {
                    showLoading = false;
                  });
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(verificationFailed.message)));

                },
                codeSent: (verificationId, resendingToken) async{
                  setState(() {
                    showLoading = false;
                    currrantState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                    this.verificationId= verificationId;
                  });

                },
                codeAutoRetrievalTimeout: (verifivationId) async{

                }
            );
          },
          child: Text("Send"),
          color: Colors.blue,
          textColor: Colors.white,
        ),
        Spacer(),
      ],

    );
  }

  getOtpWidgetState(context) {
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: otpController,
          decoration: InputDecoration(
              hintText: "OTP Code"
          ),
        ),
        SizedBox(
          height: 16,
        ),
        FlatButton(
          onPressed: () async{
            PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpController.text);
            signInWithPhoneAuthCredential(phoneAuthCredential);

          },
          child: Text("enter OTP"),
          color: Colors.blue,
          textColor: Colors.white,
        ),
        Spacer(),
      ],

    );
  }

  final GlobalKey <ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: showLoading? Center(child: CircularProgressIndicator(),) :currrantState == MobileVerificationState.SHOW_MOBILE_FORM_STATE ?
        getMobileWidgetState(context) :
        getOtpWidgetState(context),
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}


