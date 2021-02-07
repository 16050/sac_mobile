import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models.dart';

List<Color> colorList = [
  Colors.blue,
  Colors.green,
  Colors.indigo,
  Colors.red,
  Colors.cyan,
  Colors.teal,
  Colors.amber.shade900,
  Colors.deepOrange
];

class SACCardComponent extends StatelessWidget {
  const SACCardComponent({
    this.sacData,
    this.onTapAction,
    Key key,
  }) : super(key: key);

  final SACModel sacData;
  final Function(SACModel sacData) onTapAction;

  @override
  Widget build(BuildContext context) {
    String neatDate = DateFormat.yMd().add_jm().format(sacData.date);
    Color color = colorList.elementAt(sacData.title.length % colorList.length);
    return Container(
        //liste des SAC
        margin: EdgeInsets.fromLTRB(10, 8, 10, 8),
        height: 132,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          //boxShadow: [buildBoxShadow(color, context)],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).dialogBackgroundColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              onTapAction(sacData);
            },
            splashColor: color.withAlpha(20),
            highlightColor: color.withAlpha(10),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${sacData.title.trim().length <= 20 ? sacData.title.trim() : sacData.title.trim().substring(0, 20) + '...'}',
                    style: TextStyle(
                      fontFamily: 'ZillaSlab',
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    child: Text(
                      '${sacData.location}',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade400),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 14),
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: <Widget>[
                        /*Icon(Icons.flag,
                            size: 16,
                            color: sacData.state ? color : Colors.transparent),*/
                        Spacer(),
                        Text(
                          '$neatDate',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade300,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  /*BoxShadow buildBoxShadow(Color color, BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return BoxShadow(
          color: sacData.state == true
              ? Colors.black.withAlpha(100)
              : Colors.black.withAlpha(10),
          blurRadius: 8,
          offset: Offset(0, 8));
    }
    return BoxShadow(
        color:
            sacData.state == true ? color.withAlpha(60) : color.withAlpha(25),
        blurRadius: 8,
        offset: Offset(0, 8));
  }*/
}

class AddSACCardComponent extends StatelessWidget {
  const AddSACCardComponent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //boutton nouvelle sanction
    return Container(
        margin: EdgeInsets.fromLTRB(10, 8, 10, 8),
        height: 110,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        color: Theme.of(context).primaryColor,
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Nouvelle sanction',
                            style: TextStyle(
                                fontFamily: 'ZillaSlab',
                                color: Theme.of(context).primaryColor,
                                fontSize: 20),
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
