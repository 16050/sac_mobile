import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_sac_app/components/faderoute.dart';
import 'package:flutter_sac_app/data/models.dart';
import 'package:flutter_sac_app/screens/edit.dart';
import 'package:flutter_sac_app/screens/view.dart';
import 'package:flutter_sac_app/services/database.dart';
import 'settings.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import '../components/cards.dart';

import 'package:flutter_sac_app/screens/home.dart';

class OffenderPage extends StatefulWidget {
  Function() triggerRefetch;
  OffenderModel currentOffender;
  OffenderPage({Key key, OffenderModel currentOffender}) : super(key: key) {
    this.currentOffender = currentOffender;
  }
  @override
  _OffenderPageState createState() => _OffenderPageState();
}

class _OffenderPageState extends State<OffenderPage> {
  bool headerShouldHide = false;
  List<SACModel> sacsList = [];

  @override
  void initState() {
    super.initState();
    SACDatabaseService.db.init();
    setSACFromDB();
  }

  setSACFromDB() async {
    print("Entered setSAC");
    var fetchedSAC =
        await SACDatabaseService.db.getOffenderSAC(widget.currentOffender);
    setState(() {
      sacsList = fetchedSAC;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          gotoEditSAC();
        },
        label: Text('Synchronisation'.toUpperCase()),
        icon: Icon(Icons.add),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              buildHeaderWidget(context),
              //buildButtonRow(),
              //buildImportantIndicatorText(),
              Container(height: 32),
              ...buildSACComponentsList(),
              GestureDetector(onTap: gotoEditSAC, child: AddSACCardComponent()),
              Container(height: 100)
            ],
          ),
          margin: EdgeInsets.only(top: 2),
          padding: EdgeInsets.only(left: 15, right: 15),
        ),
      ),
    );
  }

//titre
  Widget buildHeaderWidget(BuildContext context) {
    return Row(
      children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeIn,
          margin: EdgeInsets.only(top: 8, bottom: 32, left: 10),
          width: headerShouldHide ? 0 : 300,
          child: Text(
            'Sanctions de ' + widget.currentOffender.name,
            style: TextStyle(
                fontFamily: 'ZillaSlab',
                fontWeight: FontWeight.w700,
                fontSize: 30,
                color: Theme.of(context).primaryColor),
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
      ],
    );
  }

  /*Widget buildImportantIndicatorText() {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 200),
      firstChild: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Only showing sacs marked important'.toUpperCase(),
          style: TextStyle(
              fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
        ),
      ),
      secondChild: Container(
        height: 2,
      ),
      crossFadeState:
          isFlagOn ? CrossFadeState.showFirst : CrossFadeState.showSecond,
    );
  }*/

  List<Widget> buildSACComponentsList() {
    List<Widget> sacComponentsList = [];
    sacsList.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    /*if (isFlagOn) {
      sacsList.forEach((sac) {
        if (sac.state)
          sacComponentsList.add(SACCardComponent(
            sacData: sac,
            onTapAction: openSACToRead,
          ));
      });
    }*/
    sacsList.forEach((sac) {
      sacComponentsList.add(SACCardComponent(
        sacData: sac,
        onTapAction: openSACToRead,
      ));
    });
    return sacComponentsList;
  }

  void gotoEditSAC() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                EditSACPage(triggerRefetch: refetchSACFromDB)));
  }

  void refetchSACFromDB() async {
    await setSACFromDB();
    print("Refetched sacs");
  }

  openSACToRead(SACModel sacData) async {
    setState(() {
      headerShouldHide = true;
    });
    await Future.delayed(Duration(milliseconds: 230), () {});
    Navigator.push(
        context,
        FadeRoute(
            page: ViewSACPage(
                triggerRefetch: refetchSACFromDB, currentSAC: sacData)));
    await Future.delayed(Duration(milliseconds: 300), () {});

    setState(() {
      headerShouldHide = false;
    });
  }
}
