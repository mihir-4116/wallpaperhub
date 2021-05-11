import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign-up.dart';
import 'package:wallpaperhub/auth/resetpassword.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email, _password;

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        print(user);

        Navigator.pushReplacementNamed(context, "home");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
  }

  login() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      try {
        await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);
      } catch (e) {
        showError(e.message);
        print(e);
      }
    }
  }

  showError(String errormessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ERROR'),
            content: Text(errormessage),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  navigateToSignUp() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
  }

  navigateToReset() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ResetScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image(
                  image: AssetImage("images/log-in.jpg"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                          child: TextFormField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              onSaved: (input) => _email = input),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Stack(
                        alignment: const Alignment(0, 0),
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: 15, right: 15, top: 5),
                              child: TextFormField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    labelText: 'Your password',
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  // obscureText: true,
                                  onSaved: (input) => _password = input),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    RaisedButton(
                      padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                      onPressed: login,
                      child: Text('LOGIN',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold)),
                      color: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            GestureDetector(
              child: Text(
                'Create an Account',
                style: TextStyle(fontSize: 20),
              ),
              onTap: navigateToSignUp,
            ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              child: Text(
                'forgot password?',
                style: TextStyle(fontSize: 20),
              ),
              onTap: navigateToReset,
            ),
          ],
        ),
      ),
    ));
  }
}
