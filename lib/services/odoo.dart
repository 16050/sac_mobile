import 'package:odoo_api/odoo_api.dart';
import 'database.dart';

var client = OdooClient("http://192.168.1.15:9899");

odooConnexion() {
  client.connect().then((version) {
    print("Connected $version");
  });
  client.authenticate('admin', 'test123', 'xlerp').then((username) {
    print('User $username authentified');
  });
}
