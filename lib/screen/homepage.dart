import 'dart:ui';
import 'package:buddies_gram/model/user.dart';
import 'package:buddies_gram/screen/tabbedscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'timeline.dart';
import 'package:flutter/material.dart';
import '../model/signin.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else if (snapshot.hasError)
            return Center(child: Text('error'));
          else if (snapshot.hasData)
            return TabbedScreen();
          else
            return signin();
        },
      ),
    );
  }
}

class signin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenwidth = MediaQuery.of(context).size.width;
    var screenheight = MediaQuery.of(context).size.height;
    return Container(
      width: screenwidth,
      height: screenheight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).cardColor,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(30),
            child: Text(
              'Buddiesgram',
              style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          FormContainer(),
          FlatButton(
            onPressed: () {
              Provider.of<google>(context, listen: false).signingoogle();
            },
            child: Container(
                width: screenwidth * 0.5,
                height: screenheight * 0.07,
                child: FittedBox(
                  child: Image.asset(
                    "images/signin_button.png",
                  ),
                  fit: BoxFit.fill,
                )),
          )
        ],
      ),
    );
  }
}

class FormContainer extends StatefulWidget {
  @override
  _FormContainerState createState() => _FormContainerState();
}

class _FormContainerState extends State<FormContainer> {
  TextEditingController econtroler = TextEditingController();
  TextEditingController pcontroler = TextEditingController();
  TextEditingController ncontroler = TextEditingController();
  TextEditingController dcontroler = TextEditingController();
  TextEditingController icontroler = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();
  var conatinersizedecider = false;
  @override
  Widget build(BuildContext context) {
    var screenwidth = MediaQuery.of(context).size.width;
    var screenheight = MediaQuery.of(context).size.height;
    void change(){econtroler .clear();
    pcontroler.clear();
    ncontroler.clear();
    dcontroler.clear();
    icontroler.clear();
    setState(() {
      conatinersizedecider=!conatinersizedecider;
    });}
    Widget login() {

      return Container(
        margin: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: econtroler,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty || !value.contains('@')) {
                  return 'Invalid email!';
                }
              },
            ),
            TextFormField(
              obscureText: true,
              controller: pcontroler,
              decoration: InputDecoration(labelText: 'Password'),
              keyboardType: TextInputType.visiblePassword,
              validator: (value) {
                if (value!.isEmpty || value.length < 5) {
                  return 'Password is too short!';
                }
              },
            ),
          ],
        ),
      );
    }

    Widget logup() {
      return Container(
        margin: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: econtroler,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty || !value.contains('@')) {
                  return 'Invalid email!';
                }
              },
            ),
            TextFormField(
              obscureText: true,
              controller: pcontroler,
              decoration: InputDecoration(labelText: 'Password'),
              keyboardType: TextInputType.visiblePassword,
              validator: (value) {
                if (value!.isEmpty || value.length < 5) {
                  return 'Password is too short!';
                }
              },
            ),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Verify Password'),
              keyboardType: TextInputType.visiblePassword,
              validator: (value) {
                print(value);
                if (value != pcontroler.text) {
                  return 'Password doesnot match!';
                }
              },
            ),
            TextFormField(
              controller: ncontroler,
              decoration: InputDecoration(labelText: 'Profile Name'),
              keyboardType: TextInputType.text,
            ),
            TextFormField(
              controller: icontroler,
              decoration: InputDecoration(labelText: 'ImageUrl'),
              keyboardType: TextInputType.text,
            ),
            TextFormField(
              controller: dcontroler,
              decoration: InputDecoration(labelText: 'Description'),
              keyboardType: TextInputType.text,
            ),
          ],
        ),
      );
    }

    return Container(
      child: Form(
        key: _key,
        child: Column(
          children: [
            Center(child: conatinersizedecider ? logup() : login()),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: FlatButton(
                  onPressed: () {
                    if (!_key.currentState!.validate()) {
                    } else if (conatinersizedecider)
                      Provider.of<google>(context, listen: false).sigup(
                          econtroler.text,
                          pcontroler.text,
                          user(
                              email: econtroler.text,
                              profilename: ncontroler.text,
                              description: dcontroler.text,
                              imageurl: icontroler.text)).then((_){change();});
                    else
                      Provider.of<google>(context, listen: false)
                          .siginemail(econtroler.text, pcontroler.text);
                  },
                  child: Text("submit")),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: FlatButton(
                  onPressed: change,
                  child: Text(conatinersizedecider ? 'SignIn' : 'SignUp')),
            ),
          ],
        ),
      ),
      width: screenwidth * 0.7,
      height: conatinersizedecider ? screenheight * 0.71 : screenheight * 0.4,
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
    );
  }
}
