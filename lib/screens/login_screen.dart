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
          onPressed: () {},
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
        child: currrantState == MobileVerificationState.SHOW_MOBILE_FORM_STATE ?
        getMobileWidgetState(context) :
        getOtpWidgetState(context),
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
