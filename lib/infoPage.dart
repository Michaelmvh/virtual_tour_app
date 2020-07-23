import 'package:flutter/material.dart';
import 'mappage.dart';

class Bar extends StatelessWidget {
  final String data;

  Bar({this.data});

  @override
  Widget build(BuildContext context) {
    return Text(data);
  }
}
