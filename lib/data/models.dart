import 'dart:math';
import 'package:location/location.dart';

var gps = new Location();

class NotesModel {
  int id;
  String title;
  String content;
  bool isImportant;
  DateTime date;
  String location;

  NotesModel(
      {this.id,
      this.title,
      this.content,
      this.isImportant,
      this.date,
      this.location});

  NotesModel.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.title = map['title'];
    this.content = map['content'];
    this.date = DateTime.parse(map['date']);
    this.isImportant = map['isImportant'] == 1 ? true : false;
    this.location = map['location'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'title': this.title,
      'content': this.content,
      'isImportant': this.isImportant == true ? 1 : 0,
      'date': this.date.toIso8601String(),
      'location': this.location,
    };
  }

  NotesModel.random() {
    this.id = Random(10).nextInt(1000) + 1;
    this.title = 'Lorem Ipsum ' * (Random().nextInt(4) + 1);
    this.content = 'Lorem Ipsum ' * (Random().nextInt(4) + 1);
    this.isImportant = Random().nextBool();
    this.date = DateTime.now().add(Duration(hours: Random().nextInt(100)));
    //this.location = 'Lorem Ipsum ' * (Random().nextInt(4) + 1);
  }
}
