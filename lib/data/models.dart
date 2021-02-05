import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';

var gps = new Location();

class SACModel {
  int id;
  String title;
  String content;
  String state;
  DateTime date;
  String location;
  String picture;

  SACModel({
    this.id,
    this.title,
    this.content,
    this.state,
    this.date,
    this.location,
    this.picture,
  });

  SACModel.fromMap(Map<String, dynamic> map) {
    this.id = map['sac_id'];
    this.title = map['title'];
    this.content = map['content'];
    this.date = DateTime.parse(map['date']);
    this.state = map['state'];
    this.location = map['location'];
    this.picture = map['picture'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sac_id': this.id,
      'title': this.title,
      'content': this.content,
      'state': this.state,
      'date': this.date.toIso8601String(),
      'location': this.location,
      'picture': this.picture,
    };
  }
}
