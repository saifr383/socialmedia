import 'package:buddies_gram/model/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fs;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as im;
class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> with AutomaticKeepAliveClientMixin{
  bool get wantKeepAlive=>true;
  XFile? file;
  captureimage() async {
    Navigator.pop(context);
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 680, maxWidth: 970);
    setState(() {
      file = image;
    });
  }

  selectimage() async {
    Navigator.pop(context);
    XFile? select = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxHeight: 680, maxWidth: 970);
    setState(() {
      file = select;
    });
  }

  dialog(ncontext) {
    return showDialog(
        context: ncontext,
        builder: (context) => SimpleDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              title: Text(
                'New post',
                style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.grey[800],
              children: [
                SimpleDialogOption(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('Capture Image From Camera',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ))),
                  onPressed: captureimage,
                ),
                new Divider(
                  height: 5,
                  color: Colors.white54,
                  thickness: 2,
                ),
                SimpleDialogOption(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('Select Image From Gallery',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ))),
                  onPressed: selectimage,
                ),
                new Divider(
                  height: 5,
                  color: Colors.white54,
                  thickness: 2,
                ),
                SimpleDialogOption(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('Cancel',
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  uploadscreen() {
    return Container(
      margin: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.add_a_photo,
            color: Colors.white70,
            size: 300,
          ),
          RaisedButton(
            onPressed: () => dialog(context),
            child: Text(
              'Upload Image',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            color: Colors.green,
          )
        ],
      ),
    );
  }
  String postid=Uuid().v4();
  TextEditingController lcontroller = TextEditingController();
  TextEditingController ccontroller = TextEditingController();var uploading=false;
  uploadandsave() async {
    setState(() {
      uploading=true;
    });
    final tdirectory=await getTemporaryDirectory();
    final path=tdirectory.path;
    im.Image? Imagefile=im.decodeImage(File(file!.path).readAsBytesSync());
    final compressimagefile=File('$path/img_$postid.jpg')..writeAsBytesSync(im.encodeJpg(Imagefile!,quality: 90));
    setState(() {
      file=XFile(compressimagefile.path);
    });
   fs.UploadTask reference=FirebaseStorage.instance.ref().child('Post Pic').child('post_$postid.jpg').putFile(File(file!.path));
   fs.TaskSnapshot snapshot=await reference.whenComplete(() => null);
   String downloadurl=await snapshot.ref.getDownloadURL();
   FirebaseFirestore.instance.collection('post').doc(postid).set(
       {'postid':postid,'ownerid':Provider.of<google>(context,listen: false).Currentuser.email,'likes':[],'comments':{},'image':downloadurl,'location':lcontroller.text,'caption':ccontroller.text});
  lcontroller.clear();
  ccontroller.clear();
  setState(() {
    file=null;

      uploading=false;

    postid=Uuid().v4();
  });
    Fluttertoast.showToast(
        msg: 'Upload Sucessful',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }
  getlocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    lcontroller.text =
        "${place.subLocality},${place.locality}, ${place.country}";
  }

  savescreen() {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {  lcontroller.clear();
            ccontroller.clear();
              setState(() {
              file=null;
            });},
            iconSize: 30,
          ),
          title: Text(
            'New Post',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.share,
                color: Colors.white,
              ),
              onPressed: () {uploadandsave();},
              iconSize: 30,
            )
          ],
        ),
        body: Container(
          color: Colors.grey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              uploading?Center(child: LinearProgressIndicator(color: Colors.green,),):Text(''),
              AspectRatio(
                aspectRatio: 16 / 13,
                child: Image.file(
                  File(file!.path),
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  controller: lcontroller,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      hintText: "Location",
                      hintStyle: TextStyle(color: Colors.white),
                      focusColor: Colors.white,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.add_location,
                        color: Colors.white,
                      )),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  controller: ccontroller,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      hintText: "Caption",
                      hintStyle: TextStyle(color: Colors.white),
                      focusColor: Colors.white,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.add_location,
                        color: Colors.white,
                      )),
                ),
              ),
              Container(
                  margin: EdgeInsets.all(30),
                  child: RaisedButton(
                      onPressed: () {
                        getlocation();
                      },
                      child: Text(
                        'Set Current location',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.green)),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        body: file == null ? uploadscreen() : savescreen());
  }
}
