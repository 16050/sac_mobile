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
  OffenderModel offender;

  SACModel({
    this.id,
    this.title,
    this.content,
    this.state,
    this.date,
    this.location,
    this.picture,
    this.offender,
  });

  //copying db data
  SACModel.fromMap(Map<String, dynamic> map) {
    this.id = map['sac_id'];
    this.title = map['title'];
    this.content = map['content'];
    this.date = DateTime.parse(map['date']);
    this.state = map['state'];
    this.location = map['location'];
    this.picture = map['picture'];
    this.offender = OffenderModel(map['offender_id'], map['offender']);
  }

  //add data to db
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sac_id': this.id,
      'title': this.title,
      'content': this.content,
      'state': this.state,
      'date': this.date.toIso8601String(),
      'location': this.location,
      'picture': this.picture,
      'offender_id': this.offender.id,
      'offender': this.offender.name,
    };
  }
}

class OffenderModel {
  int id;
  String name;
  List<SACModel> sacList;

  OffenderModel(id, name) {
    this.id = id;
    this.name = name;
  }

  OffenderModel.fromMap(Map<String, dynamic> map) {
    this.id = map['offender_id'];
    this.name = map['name'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'offender_id': this.id,
      'name': this.name,
    };
  }

  addSAC(SACModel sac) {
    sacList.add(sac);
  }

  removeSAC(SACModel sac) {
    sacList.remove(sac);
  }
}
