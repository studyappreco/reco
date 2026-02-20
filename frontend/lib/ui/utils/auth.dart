import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:frontend/repos/CourseSearchRepo.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:mongo_dart/mongo_dart.dart';

const PROJECT_ID = String.fromEnvironment('PROJECT_ID');
const MONGO_URI = String.fromEnvironment('MONGO_URI');
const CUSTOM_ENDPOINT = "https://apps-tub.de/v1";


class BackendClient {

  static Client? backendClient;

  static Client? getBackendClient() {
    if (backendClient != null) {
        return backendClient;
    } else {
      try{
        backendClient = Client().setProject(PROJECT_ID).setEndpoint(CUSTOM_ENDPOINT);
        return backendClient;
      } on Exception {
        return null;
      }
    }
  }
}

// should be singleton instance. Each client should have its own connection pool as described in this mongoDB documentation
// https://www.mongodb.com/docs/manual/administration/connection-pool-overview/#use-an-instance-of-your-driver-s-mongoclient-object
class DbCLient {
  static const String _databaseName = 'reco_db';

  static Db? mongoDB;

  static Future<Db?> getMongoDBClient() async {
    if (mongoDB != null) {
      if (mongoDB!.isConnected) {
        return mongoDB;
      }
      print("Connection stale retrying");
      await _closeConnection();
    }
    return await _createConnection();
  }

  static Future<void> _closeConnection() async {
    try {
      await mongoDB?.close();
    } catch (e) {
      debugPrint('[DbClient] Error closing stale connection: $e');
    } finally {
      mongoDB = null;
    }
  }

  static Future<Db?> _createConnection({int maxRetries = 5}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final uri = Uri.parse(MONGO_URI);
        final dbUri = uri.replace(path: '/$_databaseName').toString();
        mongoDB = await Db.create(dbUri);
        await mongoDB?.open(secure: true);
        if (mongoDB?.isConnected == true) {
          debugPrint('[DbClient] MongoDB connected successfully');
          return mongoDB;
        }
        await _closeConnection();
      } on Exception catch (e) {
        debugPrint("failure when debugging the when trying to open the connection");
      }
      await Future.delayed(Duration(milliseconds: 500 * attempt));
    }
    return null;
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
  final TranscriptRepository transcriptRepo;
  final CourseSearchRepo courseRepo;

  Session? _session;
  User? _newUser;
  String? _newUserPassword;
  String? _newUserLiteral;

  ClientSession(this.transcriptRepo, this.courseRepo) {
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
    if (_session != null) {
      transcriptRepo.getTranscript(userID: _session!.userId);
      courseRepo.fetchModules(userID: _session!.userId);
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
    notifyListeners();
  }

  void resetNewUser() {
    _newUser = null;
    _newUserPassword = null;
    notifyListeners();
  }

  String? get newUserLiteral => _newUserLiteral;

  void setNewUserLiteral(String? literal) {
    _newUserLiteral = literal;
    notifyListeners();
  }

  String? getUserID(){
    return _session?.userId;
  }

}
