import 'package:flutter/material.dart';
import 'mappage.dart';

class InfoPage extends StatelessWidget {
  final String dormName;
  InfoPage({Key key, @required this.dormName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("data"),
        ),
        body: Stack(
          children: <Widget>[
            new Image.network(//replace with URL from db
                'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png'),
            roomButtons(3) //room num from db,
          ],
        ));
  }

  ButtonBar roomButtons(int numRooms) {
    List<Widget> buttons = [];
    for (int i = 0; i < numRooms; i++) {
      buttons.add(new FlatButton());
    }
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: buttons,
    );
  }
}
