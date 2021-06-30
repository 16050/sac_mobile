//import 'package:odoo_api/odoo_api.dart';
import 'database.dart';
import 'package:flutter_sac_app/data/models.dart';
import 'package:http/http.dart' as http;
//import 'package:json_rpc_2/json_rpc_2.dart';
//import 'package:jsonrpc2/jsonrpc_client.dart';
//import 'package:pedantic/pedantic.dart';
//import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:odoo_api/odoo_api.dart';
import 'dart:convert';
import 'dart:io';

//var socket = WebSocketChannel.connect(Uri.parse('ws://192.168.56.101:9899'));
//var client = Client(socket.cast<String>());

var db_name = 'xlerp';
var user = 'admin';
var password = 'test123';

var json_body = {
  "jsonrpc": "2.0",
  "params": {
    "login": "admin",
    "password": "test123",
    "db": "xlerp",
  }
};

/*jsonrpc() async {
  var echo = await client.sendRequest('echo', {
    "jsonrpc": "2.0",
    "method": "call",
    "params": {
      "model": "sac_module.sac",
      "method": "write",
      "args": {
        "name": "Coca-Cola 50cl OK",
        "adress": "adress",
        "description": "description"
      },
      "kwargs": {"context: {}"},
      "session_id": "f48b00a031fc4920af0b3e4ec04d9497"
    },
    "id": "r6",
    "params": {
      "login": "admin",
      "password": "test123",
      "db": "xlerp",
    }
  });
}*/

Map data = {"name": "Gaurav", "adress": "adress", "description": "description"};
sendSAC() {
  var client = OdooClient("http://192.168.56.101:9899");
  client.connect().then((version) {
    print("Connected $version");
  });
  //client.authenticate('admin', 'test123', 'xlerp').then((username) {
  // print('User $username authentified');
  //});
  //client.create('sac_module.sac', data);

  /*http.post('http://192.168.56.101:9899/jsonrpc',
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "opts": {"login": "admin", "password": "test123", "db": "xlerp"},
        "moduleDetail": {
          "model": "sac_module.sac",
          "method": "create",
          "args": {
            "name": "Gaurav",
            "adress": "adress",
            "description": "description"
          },
          "filter": "",
          "fields": "",
          "domain": "",
          "offset": "",
          "limit": "",
          "sort": "",
          "resource_id": ""
        }
      }));*/
}

/*sendSAC() {
  Future<List<SACModel>> listSAC = SACDatabaseService.db.getNotSendedSAC();
}*/

sendSAC_xml() async {
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

Future<List<TypeModel>> getTypeSAC() async {
  List<TypeModel> type_list;
  final response = await http
      .get(Uri.parse('http://192.168.56.101:9899/sac_module/get_sac_type'));

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);
    List<dynamic> type_sac = json["result"]["response"];
    type_sac.forEach((i) {
      type_list.add(TypeModel.fromMap(i));
    });
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

Future<List<UserModel>> getUsers() async {
  List<UserModel> user_list;
  final response = await http
      .get(Uri.parse('http://192.168.56.101:9899/sac_module/get_users'));

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);
    List<dynamic> users = json["result"]["response"];
    users.forEach((user) {
      user_list.add(UserModel.fromMap(user));
    });
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

Future<List<SACModel>> getSACs() async {
  List<SACModel> sac_list;
  final response = await http
      .get(Uri.parse('http://192.168.56.101:9899/sac_module/get_sac'));

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);
    List<dynamic> sac = json["result"]["response"];
    sac.forEach((i) {
      sac_list.add(SACModel.fromMap(i));
    });
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
