import 'dart:convert';
import 'dart:ui';
import 'dart:io' as Io;

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

import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class EditSACPage extends StatefulWidget {
  Function() triggerRefetch;
  SACModel existingSAC;
  EditSACPage({Key key, Function() triggerRefetch, SACModel existingSAC})
      : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.existingSAC = existingSAC;
  }
  @override
  _EditSACPageState createState() => _EditSACPageState();
}

class _EditSACPageState extends State<EditSACPage> {
  bool isDirty = false;
  bool isSACNew = true;
  FocusNode titleFocus = FocusNode();
  FocusNode contentFocus = FocusNode();
  FocusNode offenderFocus = FocusNode();

  SACModel currentSAC;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController offenderController = TextEditingController();

  @override
  void initState() {
    //var location = getUserLocation();
    super.initState();
    _getTypes();
    if (widget.existingSAC == null) {
      currentSAC = SACModel(
          id: 0,
          content: '',
          title: '',
          date: DateTime.now(),
          state: 'Pas encore envoyé',
          location: '',
          offender: new OffenderModel(1, ''));
      isSACNew = true;
    } else {
      currentSAC = widget.existingSAC;
      isSACNew = false;
    }
    titleController.text = currentSAC.title;
    contentController.text = currentSAC.content;
  }

  String offender_type;
  String sac_type;

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
            //title
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
                  FocusScope.of(context).requestFocus(offenderFocus);
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
            //offender
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                focusNode: offenderFocus,
                controller: offenderController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                /*onSubmitted: (text) {
                  titleFocus.unfocus();
                  FocusScope.of(context).requestFocus(contentFocus);
                },
                onChanged: (value) {
                  markTitleAsDirty(value);
                },*/
                textInputAction: TextInputAction.next,
                style: TextStyle(
                    fontFamily: 'ZillaSlab',
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
                decoration: InputDecoration.collapsed(
                  hintText: 'Numéro du contrevenant',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 20,
                      fontFamily: 'ZillaSlab',
                      fontWeight: FontWeight.w700),
                  border: InputBorder.none,
                ),
              ),
            ),
            //type selection
            DropdownButton<String>(
              focusColor: Colors.white,
              value: offender_type,
              //elevation: 5,
              style: TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white,
              items: <String>[
                'oui',
                'non',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              hint: Text(
                "Le contrevenant est il une entreprise?",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
              onChanged: (String value) {
                setState(() {
                  offender_type = value;
                });
              },
            ),
            //type selection
            DropdownButton<String>(
              focusColor: Colors.white,
              value: sac_type,
              //elevation: 5,
              style: TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white,
              items: types.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              hint: Text(
                "Choisir un type",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
              onChanged: (String value) {
                setState(() {
                  sac_type = value;
                });
              },
            ),
            //content
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
            ),
            //camera
            Container(
                child: Column(
              children: <Widget>[
                _decideImageView(),
                RaisedButton(
                  onPressed: () {
                    _showChoiceDialog(context);
                  },
                  child: Text("Image"),
                )
              ],
            ))
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
                      /*IconButton(
                        tooltip: 'Mark note as important',
                        icon: Icon(currentSAC.state
                            ? Icons.flag
                            : Icons.outlined_flag),
                        onPressed: titleController.text.trim().isNotEmpty &&
                                contentController.text.trim().isNotEmpty
                            ? markImportantAsDirty
                            : null,
                      ),*/
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

  Io.File imageFile;
  List<String> base64codes = [];

  List<String> types = [];
  _getTypes() async {
    types = await SACDatabaseService.db.getTypesFromDB();
  }

  _openGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = picture;
      final bytes = imageFile.readAsBytesSync();
      base64codes.add(base64Encode(bytes));
    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      imageFile = picture;
      final bytes = imageFile.readAsBytesSync();
      base64codes.add(base64Encode(bytes));
    });
    Navigator.of(context).pop();
  }

  Widget _decideImageView() {
    if (imageFile == null) {
      return Text("Aucune photo");
    } else {
      return Image.file(imageFile, width: 300, height: 300);
    }
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text("Gallerie"),
                    onTap: () {
                      _openGallery(context);
                    },
                  ),
                  GestureDetector(
                    child: Text("Appareil photo"),
                    onTap: () {
                      _openCamera(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void handleSave() async {
    TypeModel type = await SACDatabaseService.db.getType(sac_type);
    String location = await getUserLocation();
    setState(() {
      currentSAC.title = titleController.text;
      currentSAC.content = contentController.text;
      print('Hey there ${currentSAC.content}');
      if (widget.existingSAC == null) {
        currentSAC.location = location;
        currentSAC.type = type;
        //final bytes = imageFile.readAsBytesSync();
        //currentSAC.picture = base64Encode(bytes);
        print('salam');
      }
    });
    print('bonjour');
    if (isSACNew) {
      OffenderModel latestOffender =
          await SACDatabaseService.db.existingOffender(offenderController.text);
      currentSAC.offender = latestOffender;

      print(currentSAC.offender.id);
      SACModel latestSAC = await SACDatabaseService.db.addSACInDB(currentSAC);
      print(latestSAC.id);
      await SACDatabaseService.db.addPicturesInDB(base64codes, latestSAC.id);
      print('sac added');
      setState(() {
        currentSAC = latestSAC;
      });
    } else {
      await SACDatabaseService.db.updateSACInDB(currentSAC);
    }
    setState(() {
      isSACNew = false;
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

  void handleDelete() async {
    if (isSACNew) {
      Navigator.pop(context);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Text('Delete SAC'),
              content: Text('This note will be deleted permanently'),
              actions: <Widget>[
                FlatButton(
                  child: Text('DELETE',
                      style: prefix0.TextStyle(
                          color: Colors.red.shade300,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1)),
                  onPressed: () async {
                    await SACDatabaseService.db.deleteSACInDB(currentSAC);
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
