import 'package:buddies_gram/screen/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screen/timeline.dart';
import 'model/signin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(create: (ctx)=>google(),child: MaterialApp(
      title: 'Buddiesgram',
      theme: ThemeData(
          primarySwatch: Colors.grey,
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.white60
      ),
      home: HomePage(),
      routes: {Timeline.routename:(ctx)=>Timeline(),
      chat.routename:(ctx)=>chat()},
    ),);
  }
}
