import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

final PROJECT_ID = dotenv.env['PROJECT_ID'];
final MONGO_URI = dotenv.env['MONGO_URI'];
const CUSTOM_ENDPOINT = "https://apps-tub.de/v1";


class BackendClient {

  static Client? backendClient = null;

  static Client? getBackendClient() {
    if (backendClient != null) {
        return backendClient;
    } else {
      try{
        backendClient = Client().
        setProject(PROJECT_ID!).setEndpoint(CUSTOM_ENDPOINT);
        return backendClient;
      } on Exception catch (e){
        return null;
      }
    }
  }
}

// should be singleton instance. Each client should have its own connection pool as described in this mongoDB documentation
// https://www.mongodb.com/docs/manual/administration/connection-pool-overview/#use-an-instance-of-your-driver-s-mongoclient-object
class DbCLient {
  static const String _databaseName = 'reco_db';

  static Db? mongoDB = null;

  static Future<Db?> getMongoDBClient () async {
    if (mongoDB != null) {
      return mongoDB;
    } else {
      try{
        // Parse URI and insert database name before query parameters
        final uri = Uri.parse(MONGO_URI!);
        final dbUri = uri.replace(path: '/$_databaseName').toString();
        mongoDB = await Db.create(dbUri);
        await mongoDB?.open();
        return mongoDB;
      } on Exception catch (e) {
        print(e.toString());
        return null;
      }
    }
  }
}

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter an email address";
  }
  /*if (!value.endsWith("gmail.com")) {
    return "Email address is not valid";
  }*/
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Password cannot be empty";
  }
  if (value.length < 10) {
    return "Password must at least have 10 characters";
  }
  return null;
}

class ClientSession extends ChangeNotifier {
  Session? _session;
  User? _newUser;
  String? _newUserPassword;

  ClientSession() {
    _initUserSession();
  }

  Future<void> _initUserSession() async {
    try {
      Client? client = BackendClient.getBackendClient();
      if (client == null) throw Exception("Backend client could not be initialized");
      Account account = Account(client);
      _session = await account.getSession(sessionId: 'current');
    } catch (e) {
      _session = null;
    }
    notifyListeners();
  }

  Session? get session => _session;

  bool get isLoggedIn => _session?.current == true;

  void setUserSession(Session session) {
    _session = session;
    notifyListeners();
  }

  void clearUserSession() {
    _session = null;
    notifyListeners();
  }

  User? get newUser => _newUser;
  String? get newUserPassword => _newUserPassword;

  void setNewUser(User user, String password) {
    _newUser = user;
    _newUserPassword = password;
  }

  void resetNewUser() {
    _newUser = null;
    _newUserPassword = null;
  }
}
