import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'mappage.dart';
import 'DescriptionTextWidget.dart';

class InfoPage extends StatelessWidget {
  final String campusName;
  InfoPage({Key key, @required this.campusName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("/Schools/University of Wisconsin - Madison/Sites")
            .where('shortName', isEqualTo: 'Leopold')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading');
          DocumentSnapshot query = snapshot.data.documents[0];
          String imgURL = query.data['ImageURL'];
          List<String> roomLayouts = List.from(query.data['roomLayouts']);
          String siteDescription = query.data['description'];
          String community = query.data['community'];
          String name = query.data['siteName'];
          Map<String, String> details = Map.from(query.data['details']);

          return Scaffold(
              appBar: AppBar(
                title: new Text(query.data['shortName']),
              ),
              body: ListView(
                children: <Widget>[
                  _siteImage(imgURL),
                  _sectionDivider(),
                  _siteName(name, community),
                  _sectionDivider(),
                  _siteDescription(siteDescription),
                  _sectionDivider(),
                  _siteTourButtons(roomLayouts),
                  _sectionDivider(),
                  _siteDetails(details),
                ],
              ));
        });
  }

  Widget _sectionDivider() {
    return Divider();
  }

  Widget _siteTourButtons(List<String> roomTypes) {
    List<Widget> buttons = [];
    for (var rm in roomTypes) {
      buttons.add(new RaisedButton(
        child: Text('$rm Room'),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ));
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 3.0),
          child: Text(
            'View Rooms',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: buttons,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Image _siteImage(String imgURL) {
    return Image.network(imgURL);
  }

  Widget _siteName(String heading, String subheading) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 3.0),
          child: Text(heading,
              style: TextStyle(
                fontSize: 25,
              )),
        ),
        Padding(
          padding: EdgeInsets.only(left: 3.0),
          child: Text(
            subheading,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _siteDescription(String description) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 3.0),
          child: Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DescriptionTextWidget(text: description),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _siteDetails(Map<String, String> details) {
    List<Widget> detailList = details.entries.map((entry) {
      var key = entry.key;
      var value = entry.value;
      return Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(
          '$key - $value',
          //style: TextStyle(
          // fontSize: 20,
          //),
        ),
      );
    }).toList();
    print(detailList);
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 3.0),
          child: Text(
            'Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          children: detailList,
          crossAxisAlignment: CrossAxisAlignment.start,
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
