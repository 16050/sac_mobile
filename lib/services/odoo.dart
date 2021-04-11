import 'package:odoo_api/odoo_api.dart';
import 'database.dart';
import 'package:flutter_sac_app/data/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

//var client = OdooClient("http://192.168.1.15:9899");
var db_name = 'xlerp';
var user = 'admin';
var password = 'test123';

odooConnexion() {
  /*client.connect().then((version) {
    print("Connected $version");
  });
  client.authenticate('admin', 'test123', 'xlerp').then((username) {
    print('User $username authentified');
  });*/
  http.post('http://192.168.1.15:9899/xmlrpc/2/common',
      headers: <String, String>{
        'Content-Type': 'application/xml',
      },
      body:
          '<?xml version="1.0"?><methodCall><methodName>login</methodName><params><param><value><string>${db_name}</string></value></param><param><value><string>${user}</string></value></param><param><value><string>${password}</string></value></param></params></methodCall>');
}

/*sendSAC() {
  Future<List<SACModel>> listSAC = SACDatabaseService.db.getNotSendedSAC();
}*/

sendSAC() async {
  List<SACModel> listSAC = await SACDatabaseService.db.getNotSendedSAC();
  for (SACModel sac in listSAC) {
    http.post(
      'http://192.168.1.15:9899/xmlrpc/2/object',
      headers: <String, String>{
        'Content-Type': 'application/xml',
      },
      body:
          '<?xml version="1.0"?><methodCall><methodName>execute</methodName><params><param><value><string>${db_name}</string></value></param><param><value><int>1</int></value></param><param><value><string>${password}</string></value></param><param><value><string>sac_module.sac</string></value></param><param><value><string>create</string></value></param><param><value><struct><member><name>name</name><value><string>${sac.title}</string></value></member><member><name>description</name><value><string>${sac.content}</string></value></member><member><name>adress</name><value><string>${sac.location}</string></value></member></struct></value></param></params></methodCall>',
    );
  }
}
