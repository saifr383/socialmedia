import 'package:buddies_gram/model/signin.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class Timeline extends StatefulWidget {
  static const routename = '../screen/timeline.dart';

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  Future<QuerySnapshot>? posts;
  @override
  void initState() {
    setState(() {
      posts = FirebaseFirestore.instance.collection('post').get();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
                future: posts,
                builder: (context, data) {
                  QuerySnapshot? d = data.data as QuerySnapshot?;
                  if (d == null)
                    return Center(
                        child: CircularProgressIndicator(
                      color: Colors.green,
                    ));
                  List<post> list = [];
                  d.docs.forEach((element) {
                    post p = post(element);
                    list.add(p);
                  });
                  return ListView(
                    physics: NeverScrollableScrollPhysics(),
                    children: list,
                    shrinkWrap: true,
                  );
                })
          ],
        ),
      ),
    );
  }
}

class post extends StatefulWidget {
  final DocumentSnapshot data;
  post(this.data);
  @override
  _postState createState() => _postState(data);
}

class _postState extends State<post> {
  final DocumentSnapshot data;
  _postState(this.data);
  DocumentSnapshot? u;
  Future<void> user() async {
    DocumentSnapshot d = await FirebaseFirestore.instance
        .collection('users')
        .doc(data['ownerid'])
        .get();
    setState(() {
      u = d;
    });
  }

  @override
  initState() {
    nooflike=data['likes'].length;
    user();
    super.initState();
  }
  var nooflike=0;
  @override
  var islike = null;
  Widget build(BuildContext context) {
    header() {
      return Container(
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        width: double.infinity,
        height: 40,
        child: Row(
          children: [
            CircleAvatar(
                maxRadius: 30,
                backgroundImage: CachedNetworkImageProvider(u!['image'])),
            Container(
                margin: EdgeInsets.only(left: 5),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    u!['profilename'],
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                )),
          ],
        ),
      );
    }

    body() {
      return Column(
        children: [
          Container(
              padding: EdgeInsets.only(left: 20),
              color: Colors.black38,
              alignment: Alignment.centerLeft,
              child: Text(
                data['caption'],
                style: TextStyle(color: Colors.white, fontSize: 20),
              )),
          Image.network(
            data["image"],
            width: double.infinity,
            height: 200,
            fit: BoxFit.fill,
          ),
        ],
      );
    }

    footer() {
      List like = data['likes'];
      if (islike == null)
        islike = like.contains(
            Provider.of<google>(context, listen: false).Currentuser.email);
      return Container(
        height: 50,
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(children:[IconButton(
                iconSize: 35,
                onPressed: () async {

                  if (islike == false) {

                    await FirebaseFirestore.instance
                        .collection('post')
                        .doc(data['postid'])
                        .update({
                      'likes': FieldValue.arrayUnion([
                        Provider.of<google>(context, listen: false)
                            .Currentuser
                            .email
                      ])
                    }).whenComplete(() {
                      setState(() {
                        ++nooflike;
                        islike = true;
                      });





                    });
                  } else if (islike == true) {
                    await FirebaseFirestore.instance
                        .collection('post')
                        .doc(data['postid'])
                        .update({
                      'likes': FieldValue.arrayRemove([
                        Provider.of<google>(context, listen: false)
                            .Currentuser
                            .email
                      ])
                    }).whenComplete(()  {


                      setState(() {
                        --nooflike;
                        islike = false;
                      });
                    });
                  }

                },
                icon: Icon(
                  Icons.volunteer_activism,
                  color: islike ? Colors.pink : Colors.white,
                )),Text(nooflike.toString(),style: TextStyle(fontSize: 15,color:Colors.white),)]),VerticalDivider(color: Colors.white,),
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(chat.routename, arguments: data['postid']);
              },
              icon: Icon(
                Icons.chat,
                color: Colors.white,
              ),
              iconSize: 35,
            ),
          ],
        ),
      );
    }

    if (u == null)
      return Center(
        child: Text(''),
      );
    return Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        children: [
          header(),
          body(),
          footer(),
        ],
      ),
    );
  }
}

class chat extends StatefulWidget {
  static const routename = "./screen/timeline.dart";
  @override
  _chatState createState() => _chatState();
}

class _chatState extends State<chat> {
  String? postid;
  List comment = [];
  var run = false;
  g() async {
    run = true;
    var snapshot = await FirebaseFirestore.instance
        .collection('post')
        .doc(postid)
        .get()
        .then((value) {
      setState(() {
        comment = value['comments'];
      });
    });
  }

  listw() {
    List<Column> list = [];
    if (!run) g();
    comment.forEach((element) {element.forEach((key, value) { var e = Column(children: [
      Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: ListTile(
            tileColor: Colors.white70,
            title: Text(
              key,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            subtitle: Text("\t\t$value", style: TextStyle(fontSize: 20)),
          )),
      Divider(
        color: Colors.white,
        height: 0,
      )
    ]);
    list.add(e);});});
    return ListView(
      children: list,
      shrinkWrap: true,
    );
  }

  TextEditingController ccontroler = TextEditingController();
  @override
  Widget build(BuildContext context) {
    postid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon:Icon(Icons.backspace_outlined),onPressed: (){Navigator.pop(context);},color: Colors.white,),
        title: Text(
          'Comments',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          listw(),
          Spacer(),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            color: Colors.black26,
            width: double.infinity,
            child: TextFormField(
              controller: ccontroler,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  hintStyle: TextStyle(color: Colors.white),
                  hintText: 'Search',
                  suffixIcon: IconButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('post')
                          .doc(postid)
                          .update({
                        'comments':FieldValue.arrayUnion([{
                          Provider.of<google>(context, listen: false)
                              .Currentuser
                              .email: ccontroler.text.toString()
                        }])


                      });
                      ccontroler.clear();
                      g();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
