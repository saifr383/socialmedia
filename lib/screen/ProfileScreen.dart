
import 'dart:ui';
import 'package:buddies_gram/model/signin.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/widgets.dart';
import 'package:image/image.dart';
import 'package:provider/provider.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>{
  Future<QuerySnapshot>? posts;
  var isloading=false;
  post(){
    setState(() {
      isloading=true;
    });
    var email;
    email=Provider.of<google>(context,listen: false).Currentuser.email;
    setState(() {
      posts=FirebaseFirestore.instance.collection('post').where('ownerid',isEqualTo: Provider.of<google>(context,listen: false).Currentuser.email).get();
    });
    setState(() {
      isloading=false;
    });



  }
  @override
  void initState() {
    post();
    super.initState();
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            Provider.of<google>(context, listen: false).Currentuser.email!,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        actions:[ FlatButton(

          child: Container(padding:EdgeInsets.all(3),width:40,decoration:BoxDecoration(border: Border.all(color: Colors.white,width: 1)),child: Center(child: Text('Sign out',style: TextStyle(fontSize: 12,color: Colors.white)))),
          onPressed: () {
            Provider.of<google>(context, listen: false).signout();
          },
        )],
      ),
      body: Column(
          children: [

            Container(
              margin: EdgeInsets.all(5),
              child: CircleAvatar(
                  maxRadius: 70,
                  backgroundImage: CachedNetworkImageProvider(
                      Provider.of<google>(context, listen: false)
                          .Currentuser
                          .imageurl!)),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(5),
              child: Text(
                Provider.of<google>(context, listen: false)
                    .Currentuser
                    .profilename!,
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            Container(
              margin: EdgeInsets.all(5),
              child: Text(
                '',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),

            ),
            Divider(color: Colors.white70,),
           isloading?CircularProgressIndicator():  Container(
               child: FutureBuilder(future:posts,
              builder: (context,data){
                QuerySnapshot? d=data.data as QuerySnapshot?;
                if(d==null)
                  return Center(child: CircularProgressIndicator(color: Colors.green,));
                List<UserResult> list=[];
                d.docs.forEach((element) {

                  UserResult user=UserResult(element['image']);
                  list.add(user);
                });

                return GridView.count(children:list,mainAxisSpacing: 10,crossAxisSpacing: 10,childAspectRatio: 1.0,physics: NeverScrollableScrollPhysics(),shrinkWrap: true, crossAxisCount: 3,);
              },))
          ],
        ),
      );
  }
}
class UserResult extends StatelessWidget {
  String image;
  UserResult(this.image);
  @override
  Widget build(BuildContext context) {
    return Container(child: m.Image.network(image,fit: BoxFit.fill,),width: 150,height: 150,);
  }
}

