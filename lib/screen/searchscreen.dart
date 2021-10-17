
import 'package:buddies_gram/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget  {

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin{
  bool get wantKeepAlive=>true;
  TextEditingController scontroler = TextEditingController();
   Future< QuerySnapshot>? Searchlist;
  search(String data){
    var snap=FirebaseFirestore.instance.collection('users').where('profilename',isGreaterThanOrEqualTo:data).get();
    setState(() {
      Searchlist=snap;
    });

  }

  Widget result() {
    return FutureBuilder(
      future: Searchlist,
      builder:  (context, documentsnapshot) {
        if (!documentsnapshot.hasData) return nodata();
        List<UserResult> list = [];
        var data =documentsnapshot.data as QuerySnapshot;
        data.docs.forEach((element) {
          user newuser=user(email: element['email'],profilename: element['profilename'],description: element['description'],imageurl: element['image']);
        UserResult userresult=UserResult(newuser);
        list.add(userresult);
        });

        return ListView(children:list,);

      },
    );
  }
  Widget  nodata () {
  return Center(

      child: Text(
        'Search Users',
        style: TextStyle(fontSize: 30),
      ));}
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        title: TextFormField(
          cursorColor: Colors.white,
          controller: scontroler,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            hintStyle: TextStyle(color: Colors.white),
            hintText: 'Search',
            prefixIcon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                var data=scontroler.text;
                search(data);
              },
            ),
          ),
        ),
      ),
      body: Searchlist==null?nodata():result()

    );
  }
}

class UserResult extends StatelessWidget {
  final user eachuser;
  UserResult(this.eachuser);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Container(
        color: Colors.white54,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {},
              child: ListTile(
                title: Text(eachuser.profilename!,style: TextStyle(fontSize: 20),),
                subtitle:Text(eachuser.email!,style: TextStyle(fontSize: 20),) ,
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage:
                      CachedNetworkImageProvider(eachuser.imageurl!),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
