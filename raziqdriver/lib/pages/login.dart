import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raziqdriver/pages/home.dart';
import 'package:raziqdriver/pages/register.dart';
import 'package:raziqdriver/widgets/CustomTextField.dart';
import 'package:raziqdriver/widgets/PrimaryButton.dart';
import 'package:raziqdriver/widgets/SecondaryButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController icController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String icErrorText = "";
  String passwordErrorText = "";

  bool icValid = false;
  bool passwordValid = false;

  bool hidePassword = true;

  bool rememberMe = false;

  void StoreCredentials(String ic, String password) async {
    final _prefs = await SharedPreferences.getInstance();
    _prefs.setString("ic", ic);
    _prefs.setString("password", password);
  }

  void GetCredentials() async {
    final _prefs = await SharedPreferences.getInstance();
    final ic = _prefs.getString("ic");
    final password = _prefs.getString("password");

    if (ic != null && password != null) {
      Login(ic, password);
    }
  }

  void Login(String ic, String password) async {
    showDialog(context: context, builder: (BuildContext context) {
      return Center(child: CircularProgressIndicator());
    }, );
    try {
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "${ic}@driver.cc",
        password: password,
      );
      Navigator.pop(context);
      final userId = credential.user!.uid;

      if (rememberMe == true) {
        StoreCredentials(ic, password);
      }

      Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) {
        return HomePage(uid: credential.user!.uid);
      }));

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login with IC Number ${ic} successful")));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("The password provided is too weak.")));
      } else if (e.code == 'email-already-in-use') {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("The account already exists for that email.")));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    GetCredentials();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 30 / 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Login",
                      style: GoogleFonts.montserrat(
                          color: CupertinoColors.systemGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 35),
                    ),
                    Text(
                      "Access your driver account",
                      style: GoogleFonts.montserrat(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CustomTextField(
                  controller: icController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12)
                  ],
                  onChanged: (value) {
                    if (value.length<12) {
                      icErrorText = "Please enter a valid IC number";
                      icValid = false;
                    }
                    else{
                      icErrorText = "";
                      icValid = true;
                    }
                    setState(() {

                    });
                  },
                  hintText: "IC Number",
                  errorText: icErrorText),
              SizedBox(
                height: 20,
              ),
              CustomTextField(
                  controller: passwordController,
                  keyboardType: TextInputType.text,
                  obscureText: hidePassword,
                  inputFormatters: [],
                  onChanged: (value) {
                    if (value.length<6) {
                      passwordErrorText="Password length must not be less than 6";
                      passwordValid = false;
                    }
                    else{
                      passwordErrorText="";
                      passwordValid = true;
                    }
                    setState(() {

                    });
                  },
                  hintText: "Password",
                  suffixIcon: IconButton(
                      onPressed: () {
                        hidePassword = !hidePassword;
                        setState(() {});
                      },
                      icon: hidePassword == true
                          ? Icon(CupertinoIcons.eye_slash_fill)
                          : Icon(CupertinoIcons.eye_solid)),
                  errorText: passwordErrorText),
              CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text("Remember me"),
                  activeColor: CupertinoColors.systemGreen,
                  checkboxShape: CircleBorder(),
                  value: rememberMe,
                  onChanged: (value) {
                    if (value != null) {
                      rememberMe = value;
                      setState(() {});
                    }
                  }),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: PrimaryButton(onPressed: (icValid==true&&passwordValid==true)? () {
                        Login(icController.text, passwordController.text);
                      }:null, text: "Login")),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Divider(color: Colors.grey, thickness: 2),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Text(
                      "Or",
                      style: GoogleFonts.montserrat(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                  return RegisterPage();
                }));
              }, child: Text("Register a new account", style: GoogleFonts.montserrat(
                color: CupertinoColors.systemGreen,
                fontWeight: FontWeight.bold
              ),))
            ],
          ),
        ),
      ),
    );
  }
}
