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
  Widget mapWindow = Container();
  double screenWidth;
  List<Widget> testing = [];

  @override
  Widget build(BuildContext context) {
    List<String> selectedSiteTypes = [];
    List<Marker> locationsList = [];
    bool listViewShown = false;
    screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder(
        stream: Firestore.instance
            .collection('Schools')
            .where('SchoolName', isEqualTo: campusName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading');
          DocumentSnapshot query = snapshot.data.documents[0];
          selectedSiteTypes = List.from(query.data['buildingTypes']);
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.list),
              onPressed: () {
                print("showlist");
                setState(() {
                  if (!listViewShown) {
                    _showSiteList();
                  } else {
                    mapWindow = Container();
                  }
                  listViewShown = !listViewShown;
                });
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
                mapWindow = Container();
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
          mapWindow = _mapPopUp(longName);
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
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: Text("Continue"),
                    onPressed: () {
                      setState(() {
                        //apply filters
                      });
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
    for (String siteType in list) {
      filterList.add(new ChoiceChip(
        label: Text(siteType),
        selected: selectedSiteTypes.contains(siteType),
        onSelected: (bool selected) {
          setState(() {
            selectedSiteTypes.contains(siteType)
                ? selectedSiteTypes.remove(siteType)
                : selectedSiteTypes.add(siteType);
          });
        },
      ));
    }
    return filterList;
  }

  Widget _mapPopUp(String siteName) {
    //Inspiration from: Roman Jaquez
    //Source: https://medium.com/flutter-community/add-a-custom-info-window-to-your-google-map-pins-in-flutter-2e96fdca211a
    return StreamBuilder(
        stream: Firestore.instance
            .collection("/Schools/$campusName/Sites")
            .where('siteName', isEqualTo: siteName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading');
          DocumentSnapshot query = snapshot.data.documents[0];
          String community = query.data['community'];
          String imgURL = query.data['ImageURL'];
          return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InfoPage(
                            campusName: campusName,
                            siteName: siteName,
                          )),
                );
              },
              child: Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                          constraints: BoxConstraints(
                            maxHeight: 70,
                            maxWidth: screenWidth * .75,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    blurRadius: 20,
                                    offset: Offset.zero,
                                    color: Colors.grey.withOpacity(0.5))
                              ]),
                          //color: Colors.white,
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                width: 50,
                                height: 50,
                                child: ClipOval(
                                  child: Image.network(
                                    imgURL,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                      child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      '$siteName',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 0.0),
                                    child: Text('$community'),
                                  ),
                                ],
                              ))),
                              Align(
                                alignment: Alignment.center,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_forward),
                                  color: Colors.blue,
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
                              ),
                            ],
                          )))));
        });
  }

  Widget _showSiteList() {
    return null;
  }
} //class
