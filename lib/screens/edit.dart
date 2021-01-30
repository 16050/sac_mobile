import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/painting.dart' as prefix0;
import 'package:flutter/widgets.dart';
import 'package:flutter_sac_app/data/models.dart';
import 'package:flutter_sac_app/services/database.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/services.dart';

class EditNotePage extends StatefulWidget {
  Function() triggerRefetch;
  NotesModel existingNote;
  EditNotePage({Key key, Function() triggerRefetch, NotesModel existingNote})
      : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.existingNote = existingNote;
  }
  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  bool isDirty = false;
  bool isNoteNew = true;
  FocusNode titleFocus = FocusNode();
  FocusNode contentFocus = FocusNode();

  NotesModel currentNote;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    //var location = getUserLocation();
    super.initState();
    if (widget.existingNote == null) {
      currentNote = NotesModel(
          content: '',
          title: '',
          date: DateTime.now(),
          isImportant: false,
          location: '');
      isNoteNew = true;
    } else {
      currentNote = widget.existingNote;
      isNoteNew = false;
    }
    titleController.text = currentNote.title;
    contentController.text = currentNote.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        ListView(
          children: <Widget>[
            Container(
              height: 80,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                focusNode: titleFocus,
                autofocus: true,
                controller: titleController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onSubmitted: (text) {
                  titleFocus.unfocus();
                  FocusScope.of(context).requestFocus(contentFocus);
                },
                onChanged: (value) {
                  markTitleAsDirty(value);
                },
                textInputAction: TextInputAction.next,
                style: TextStyle(
                    fontFamily: 'ZillaSlab',
                    fontSize: 32,
                    fontWeight: FontWeight.w700),
                decoration: InputDecoration.collapsed(
                  hintText: 'Enter a title',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 32,
                      fontFamily: 'ZillaSlab',
                      fontWeight: FontWeight.w700),
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                focusNode: contentFocus,
                controller: contentController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onChanged: (value) {
                  markContentAsDirty(value);
                },
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                decoration: InputDecoration.collapsed(
                  hintText: 'Start typing...',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                ),
              ),
            )
          ],
        ),
        ClipRect(
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 80,
                color: Theme.of(context).canvasColor.withOpacity(0.3),
                child: SafeArea(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: handleBack,
                      ),
                      Spacer(),
                      IconButton(
                        tooltip: 'Mark note as important',
                        icon: Icon(currentNote.isImportant
                            ? Icons.flag
                            : Icons.outlined_flag),
                        onPressed: titleController.text.trim().isNotEmpty &&
                                contentController.text.trim().isNotEmpty
                            ? markImportantAsDirty
                            : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () {
                          handleDelete();
                        },
                      ),
                      AnimatedContainer(
                        margin: EdgeInsets.only(left: 10),
                        duration: Duration(milliseconds: 200),
                        width: isDirty ? 100 : 0,
                        height: 42,
                        curve: Curves.decelerate,
                        child: RaisedButton.icon(
                          color: Theme.of(context).accentColor,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(100),
                                  bottomLeft: Radius.circular(100))),
                          icon: Icon(Icons.done),
                          label: Text(
                            'SAVE',
                            style: TextStyle(letterSpacing: 1),
                          ),
                          onPressed: handleSave,
                        ),
                      )
                    ],
                  ),
                ),
              )),
        )
      ],
    ));
  }

  Future<String> getUserLocation() async {
    //call this async method from whereever you need
    LocationData myLocation;
    String error;
    Location location = new Location();
    try {
      myLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied- please enable it from app settings';
        print(error);
      }
      myLocation = null;
    }
    LocationData currentLocation = myLocation;
    final coordinates =
        new Coordinates(myLocation.latitude, myLocation.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    String stringLocation = '${first.addressLine}';
    print(stringLocation);
    return stringLocation;
  }

  void handleSave() async {
    String location = await getUserLocation();
    setState(() {
      currentNote.title = titleController.text;
      currentNote.content = contentController.text;
      print('Hey there ${currentNote.content}');
      if (widget.existingNote == null) {
        currentNote.location = location;
        print('salam');
      }
    });
    print('bonjour');
    //await new Future.delayed(const Duration(milliseconds: 1));
    print('hello');
    if (isNoteNew) {
      var latestNote = await NotesDatabaseService.db.addNoteInDB(currentNote);
      setState(() {
        currentNote = latestNote;
      });
    } else {
      await NotesDatabaseService.db.updateNoteInDB(currentNote);
    }
    setState(() {
      isNoteNew = false;
      isDirty = false;
    });
    widget.triggerRefetch();
    titleFocus.unfocus();
    contentFocus.unfocus();
  }

  void markTitleAsDirty(String title) {
    setState(() {
      isDirty = true;
    });
  }

  void markContentAsDirty(String content) {
    setState(() {
      isDirty = true;
    });
  }

  void markLocationAsDirty(String location) {
    setState(() {
      isDirty = true;
    });
  }

  void markImportantAsDirty() {
    setState(() {
      currentNote.isImportant = !currentNote.isImportant;
    });
    handleSave();
  }

  void handleDelete() async {
    if (isNoteNew) {
      Navigator.pop(context);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Text('Delete Note'),
              content: Text('This note will be deleted permanently'),
              actions: <Widget>[
                FlatButton(
                  child: Text('DELETE',
                      style: prefix0.TextStyle(
                          color: Colors.red.shade300,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1)),
                  onPressed: () async {
                    await NotesDatabaseService.db.deleteNoteInDB(currentNote);
                    widget.triggerRefetch();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('CANCEL',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }
  }

  void handleBack() {
    Navigator.pop(context);
  }
}
