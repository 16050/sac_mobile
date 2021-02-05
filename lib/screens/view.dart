import 'dart:ui';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sac_app/data/models.dart';
import 'package:flutter_sac_app/screens/edit.dart';
import 'package:flutter_sac_app/services/database.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:share/share.dart';

class ViewSACPage extends StatefulWidget {
  Function() triggerRefetch;
  SACModel currentSAC;
  ViewSACPage({Key key, Function() triggerRefetch, SACModel currentSAC})
      : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.currentSAC = currentSAC;
  }
  @override
  _ViewSACPageState createState() => _ViewSACPageState();
}

class _ViewSACPageState extends State<ViewSACPage> {
  @override
  void initState() {
    super.initState();
    showHeader();
  }

  void showHeader() async {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        headerShouldShow = true;
      });
    });
  }

  bool headerShouldShow = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Container(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, right: 24.0, top: 40.0, bottom: 16),
              child: AnimatedOpacity(
                opacity: headerShouldShow ? 1 : 0,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeIn,
                child: Text(
                  widget.currentSAC.title,
                  style: TextStyle(
                    fontFamily: 'ZillaSlab',
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                  ),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ),
            //date
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: headerShouldShow ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  DateFormat.yMd().add_jm().format(widget.currentSAC.date),
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                ),
              ),
            ),
            //location
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: headerShouldShow ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  widget.currentSAC.location,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                ),
              ),
            ),
            //content
            Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, top: 36, bottom: 24, right: 24),
              child: Text(
                widget.currentSAC.content,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            //image
            Container(
                child: Column(
              children: <Widget>[
                _showImage(),
              ],
            )),
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
                        icon: Icon(widget.currentSAC.state
                            ? Icons.flag
                            : Icons.outlined_flag),
                        onPressed: () {
                          markImportantAsDirty();
                        },
                      ),*/
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: handleDelete,
                      ),
                      /*IconButton(
                        icon: Icon(OMIcons.share),
                        onPressed: handleShare,
                      ),*/
                      IconButton(
                        icon: Icon(OMIcons.edit),
                        onPressed: handleEdit,
                      ),
                    ],
                  ),
                ),
              )),
        )
      ],
    ));
  }

  Widget _showImage() {
    final decodedBytes = base64Decode(widget.currentSAC.picture);
    Widget image = Image.memory(decodedBytes);
    return image;
  }

  void handleSave() async {
    await SACDatabaseService.db.updateSACInDB(widget.currentSAC);
    widget.triggerRefetch();
  }

  /*void markImportantAsDirty() {
    setState(() {
      widget.currentSAC.state = !widget.currentSAC.state;
    });
    handleSave();
  }*/

  void handleEdit() {
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => EditSACPage(
                  existingSAC: widget.currentSAC,
                  triggerRefetch: widget.triggerRefetch,
                )));
  }

  void handleShare() {
    Share.share(
        '${widget.currentSAC.title.trim()}\n(On: ${widget.currentSAC.date.toIso8601String().substring(0, 10)})\n\n${widget.currentSAC.content}\n${widget.currentSAC.location}');
  }

  void handleBack() {
    Navigator.pop(context);
  }

  void handleDelete() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Supprimer la sanction'),
            content: Text('This note will be deleted permanently'),
            actions: <Widget>[
              FlatButton(
                child: Text('Supprimer',
                    style: TextStyle(
                        color: Colors.red.shade300,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
                onPressed: () async {
                  await SACDatabaseService.db.deleteSACInDB(widget.currentSAC);
                  widget.triggerRefetch();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Annuler',
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
