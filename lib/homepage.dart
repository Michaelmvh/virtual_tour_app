import 'package:flutter/material.dart';
import 'mappage.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext ctxt) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Virtual Tours"),
        ),
        body: new SettingsWidget());
  }
}

class SettingsWidget extends StatefulWidget {
  SettingsWidget({Key key}) : super(key: key);

  @override
  _SettingsWidgetState createState() => new _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  List _campuses = [
    "University of Wisconsin - Madison",
    "Ohio State University",
    "Purdue",
    "More Coming Soon"
  ]; //Change this to use Firebase eventually

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentSelected;

  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _currentSelected = _dropDownMenuItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String campus in _campuses) {
      items.add(new DropdownMenuItem(value: campus, child: new Text(campus)));
    }
    return items;
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
          new DropdownButton(
            value: _currentSelected,
            items: _dropDownMenuItems,
            onChanged: changedDropDownItem,
          ),
          new MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(_currentSelected)),
                );
              },
              child: Text("Tour University")),
        ],
      )),
    );
  }

  void changedDropDownItem(String selected) {
    setState(() {
      _currentSelected = selected;
    });
  }
}
