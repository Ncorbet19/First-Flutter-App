import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Initialize Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

// MyApp widget
class MyApp extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyApp> {
// Initialize variables
  String _text = "";
  String _reversedText = "";
  String _dataList = "";

// Reverse text function
  void _reverseText() {
    setState(() {
      _reversedText = _text.split('').reversed.join();
      sendDataToFirestore(_text, _reversedText);
    });
  }

// Get data from Firestore
  void getDataFromFirestore() async {
    _dataList = "";
    await FirebaseFirestore.instance
        .collection("text_reverser") // collection name
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((DocumentSnapshot document) {
        _dataList = _dataList + document.data().toString() + "\n";
      });
    });
    setState(() {
      _dataList = _dataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Reverse A String'),
        ),
        body: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
              // Input text field
                Padding(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _text = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Input String',
                      hintText: 'Enter text here',
                    ),
                  ),
                ),
                // Output text field
                Padding(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: (_reversedText == "")
                          ? 'Output String'
                          : '$_reversedText',
                    ),
                  ),
                ),
                // Reverse button
                ElevatedButton(
                  child: Text('Reverse'),
                  onPressed: _reverseText,
                ),
                // PhotoView container
                Container(
                    padding: EdgeInsets.all(20),
                    height: 300,
                    width: 200,
                    child: PhotoView(
                      imageProvider: AssetImage("assets/images/bob.png"),
                    )),
                  // Retrieve data from Firestore
                ElevatedButton(
                  child: Text('Retrieve from Database'),
                  onPressed: getDataFromFirestore,
                ),
                // Display data from Firestore
                Expanded(
                  child: Container(
                      padding: EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Text(_dataList),
                      )),
                ),
              ],
            )));
  }
}

// Send data to Firestore
Future<void> sendDataToFirestore(String text, String reversedText) async {
  FirebaseFirestore.instance.collection("text_reverser").add({
    "text": text,
    "reversed_text": reversedText,
  });
}
