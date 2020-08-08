import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'infoPage.dart';

class MapPage extends StatefulWidget {
  final String campusName;
  MapPage({Key key, @required this.campusName}) : super(key: key);
  @override
  State<StatefulWidget> createState() => MapPageState(campusName);
}

class MapPageState extends State<MapPage> {
  String campusName;
  MapPageState(this.campusName);
  Completer<GoogleMapController> _controller = Completer();
  Visibility mapWindow = Visibility(
    child: Text(''),
  );

  @override
  Widget build(BuildContext context) {
    List<String> selectedSiteTypes = [];
    List<Marker> locationsList = [];
    return StreamBuilder(
        stream: Firestore.instance
            .collection('Schools')
            .where('SchoolName', isEqualTo: campusName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading');
          DocumentSnapshot query = snapshot.data.documents[0];

          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.list),
              onPressed: () {
                print("showlist");
              },
            ),
            appBar: AppBar(
              leading: BackButton(onPressed: () {
                Navigator.pop(context);
              }),
              title: Text(query.data['ShortName']),
              actions: <Widget>[
                _filterButton(context, query, selectedSiteTypes),
              ],
            ),
            body: Stack(
              //This could be changed to a different widget type
              children: <Widget>[
                _buildGoogleMap(context, query, locationsList),
                mapWindow,
                _zoomminusfunction(),
                _zoomplusfunction(),
              ],
            ),
          );
        });
  }

  Widget _zoomminusfunction() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchMinus, color: Color(0xFF212121)),
          onPressed: () async {
            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(CameraUpdate.zoomOut());
          }),
    );
  }

  Widget _zoomplusfunction() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchPlus, color: Color(0xFF212121)),
          onPressed: () async {
            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(CameraUpdate.zoomIn());
          }),
    );
  }

  Widget _buildGoogleMap(BuildContext context, DocumentSnapshot query,
      List<Marker> locationsList) {
    GeoPoint campusLoc = query.data['Location'];
    double campusZoom = query.data['Zoom'].toDouble();
    String docName = 'Schools/' + query.documentID + '/Sites/';
    return StreamBuilder(
      stream: Firestore.instance.collection(docName).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('Loading');
        for (int i = 0; i < snapshot.data.documents.length; i++) {
          DocumentSnapshot snap = snapshot.data.documents[i];
          locationsList.add(markerHelper(snap.data['siteName'],
              snap.data['shortName'], snap.data['location']));
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            zoomGesturesEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
                target: LatLng(campusLoc.latitude, campusLoc.longitude),
                zoom: campusZoom),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationButtonEnabled: false,
            markers: Set.from(locationsList),
            onTap: (argument) {
              setState(() {
                mapWindow = Visibility(visible: false, child: Text(''));
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _gotoLocation(double lat, double long) async {
    //potentially delete later or repurpose
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 20,
      //tilt: 50.0,
      //bearing: 45.0,
    )));
  }

  Marker markerHelper(
    String longName,
    String shortName,
    GeoPoint loc,
  ) {
    return Marker(
      markerId: MarkerId(shortName),
      position: LatLng(loc.latitude, loc.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
      onTap: () {
        setState(() {
          mapWindow = _mapPopUp(true, longName);
        });
      },
    );
  }

  IconButton _filterButton(context, query, selectedSiteTypes) {
    return IconButton(
      icon: Icon(FontAwesomeIcons.filter),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return new AlertDialog(
                title: new Text('Select Filters'),
                content:
                    Wrap(children: _filterOptions(query, selectedSiteTypes)),
                actions: <Widget>[
                  new FlatButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop(); // dismiss dialog
                    },
                  ),
                  new FlatButton(
                    child: Text("Continue"),
                    onPressed: () {
                      //apply filters --> SetState!!!! shown
                    },
                  )
                ],
              );
            });
      },
    );
  }

  List<Widget> _filterOptions(
      DocumentSnapshot query, List<String> selectedSiteTypes) {
    List<ChoiceChip> filterList = [];
    List<String> list = [];
    list = List.from(query.data['buildingTypes']);
    //List<String> selectedSiteTypes = [];
//fix this for the filter list and compartmentalize into own method or widget somehow
    for (String siteType in list) {
      filterList.add(new ChoiceChip(
        label: Text(siteType),
        selected: selectedSiteTypes.contains(siteType),
        onSelected: (bool selected) {
          // setState(() {
          selectedSiteTypes.contains(siteType)
              ? selectedSiteTypes.remove(siteType)
              : selectedSiteTypes.add(siteType);
          // });
        },
      ));
    }
    return filterList;
  }

  Widget _mapPopUp(bool vis, String siteName) {
    if (!vis) return Visibility(child: Scaffold());
    //Update this here
    return Visibility(
        visible: true,
        child: Container(
            constraints: BoxConstraints(
              maxHeight: 50,
            ),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                //Image.network(''),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 0.0),
                      child: Text(
                        '$siteName', //Shortname -- Larger Text
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0.0),
                      child: Text(
                        '', //Type -- Smaller Text
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InfoPage(
                                campusName: campusName,
                                siteName: siteName,
                              )),
                    );
                  },
                ),
              ],
            )));
  }
} //class
