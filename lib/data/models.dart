import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:flutter_sac_app/services/database.dart';

var gps = new Location();

class SACModel {
  int id;
  String title;
  String content;
  String state;
  DateTime date;
  String location;
  List<PictureModel> pictureList;
  OffenderModel offender;
  int offender_id;
  TypeModel type;
  String type_name;

  SACModel({
    this.id,
    this.title,
    this.content,
    this.state,
    this.date,
    this.location,
    this.offender,
    this.type,
  });

  //copying db data
  SACModel.fromMap(Map<String, dynamic> map) {
    var test = getType(map['type']);
    this.id = map['sac_id'];
    this.title = map['title'];
    this.content = map['content'];
    this.date = DateTime.parse(map['date']);
    this.state = map['state'];
    this.location = map['location'];
    this.offender_id = map['offender_id'];
    this.type_name = map['type'];
  }

  getType(String name) async {
    type = await SACDatabaseService.db.getType(name);
  }

  getOffender(int id) async {
    offender = await SACDatabaseService.db.getOffender(id);
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
      'offender_id': this.offender_id,
      'type': this.type_name,
    };
  }

  addSAC(PictureModel picture) {
    pictureList.add(picture);
  }

  removeSAC(PictureModel picture) {
    pictureList.remove(picture);
  }
}

class PictureModel {
  int id;
  String base64code;

  PictureModel.fromMap(Map<String, dynamic> map) {
    this.id = map['picture_id'];
    this.base64code = map['base64code'];
  }

  PictureModel(int id, String base64code, SACModel sac) {
    this.id = id;
    this.base64code = base64code;
  }
}

class TypeModel {
  int id;
  String name;
  int price;

  TypeModel.fromMap(Map<String, dynamic> map) {
    this.id = map['type_id'];
    this.name = map['name'];
    this.price = map['price'];
  }

  TypeModel(int id, String name, int price) {
    this.id = id;
    this.name = name;
    this.price = price;
  }
}

class OffenderModel {
  int id;
  String name;
  List<SACModel> sacList;
  String type;

  OffenderModel(int id, String name, String type) {
    this.id = id;
    this.name = name;
    this.type = type;
  }

  OffenderModel.fromMap(Map<String, dynamic> map) {
    this.id = map['offender_id'];
    this.name = map['name'];
    this.type = map['type'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'offender_id': this.id,
      'name': this.name,
      'type': this.type,
    };
  }

  addSAC(SACModel sac) {
    sacList.add(sac);
  }

  removeSAC(SACModel sac) {
    sacList.remove(sac);
  }
}

class UserModel {
  int id;
  String email;
  String password;

  UserModel(int id, String email, String password) {
    this.id = id;
    this.email = email;
    this.password = password;
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    this.id = map['user_id'];
    this.email = map['email'];
    this.password = map['password'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': this.id,
      'email': this.email,
      'password': this.password,
    };
  }
}
