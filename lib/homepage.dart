import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mappage.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext ctxt) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Virtual Tours"),
        ),
        body: new HomePageWidget());
  }
}

class HomePageWidget extends StatefulWidget {
  HomePageWidget({Key key}) : super(key: key);

  @override
  _HomePageWidgetState createState() => new _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  String currentCampus;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      child: new Center(
          child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text("Please choose your University: "),
          new Container(
            padding: new EdgeInsets.all(10.0),
          ),
          new StreamBuilder(
            stream: Firestore.instance.collection('Schools').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('Loading');
              List<DropdownMenuItem<String>> campusList = [];
              for (int i = 0; i < snapshot.data.documents.length; i++) {
                DocumentSnapshot snap = snapshot.data.documents[i];
                campusList.add(new DropdownMenuItem(
                    value: snap.documentID,
                    child: new Text(snap.data['SchoolName'])));
              }
              return DropdownButton<String>(
                  value: currentCampus,
                  items: campusList,
                  onChanged: (String newCampus) {
                    setState(() {
                      currentCampus = newCampus;
                    });
                  });
            },
          ),
          new MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(
                            campusName: currentCampus,
                          )),
                );
              },
              child: Text("Tour Campus")),
        ],
      )),
    );
  }
}
