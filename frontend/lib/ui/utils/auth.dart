import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/repos/CourseSearchRepo.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Log;

final PROJECT_ID = dotenv.env['PROJECT_ID'];
final MONGO_URI = dotenv.env['MONGO_URI'];
const CUSTOM_ENDPOINT = "https://apps-tub.de/v1";


class BackendClient {

  static Client? backendClient;

  static Client? getBackendClient() {
    if (backendClient != null) {
        return backendClient;
    } else {
      try{
        backendClient = Client().
        setProject(PROJECT_ID!).setEndpoint(CUSTOM_ENDPOINT);
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
  static Completer<Db?>? _connectionCompleter;

  static Future<Db?> getMongoDBClient() async {
    // Fast path: already connected AND healthy
    if (mongoDB != null && await _isConnectionHealthy()) {
      return mongoDB;
    }

    // If a connection attempt is already in progress, wait for it
    if (_connectionCompleter != null) {
      return _connectionCompleter!.future;
    }

    // Start a new connection attempt
    _connectionCompleter = Completer<Db?>();

    try {
      if (mongoDB != null) {
        debugPrint('[DbClient] Connection stale, retrying');
        await _closeConnection();
      }
      final db = await _createConnection();
      _connectionCompleter!.complete(db);
      return db;
    } catch (e) {
      _connectionCompleter!.completeError(e);
      return null;
    } finally {
      _connectionCompleter = null;
    }
  }

  /// Health check - verify connection exists and is marked as connected.
  /// Note: We avoid running a ping command here because it can trigger
  /// reconnection logic while other operations are in-flight.
  static Future<bool> _isConnectionHealthy() async {
    return mongoDB != null && mongoDB!.isConnected;
  }

  /// Public method to verify/restore connection (useful for app lifecycle)
  static Future<void> ensureConnected() async {
    if (!await _isConnectionHealthy()) {
      await _closeConnection();
      await getMongoDBClient();
    }
  }

  /// Public method to close connection (useful for app termination/background)
  static Future<void> closeConnection() async {
    await _closeConnection();
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
        final uri = Uri.parse(MONGO_URI!);
        final dbUri = uri.replace(path: '/$_databaseName').toString();
        mongoDB = await Db.create(dbUri);
        await mongoDB?.open(secure: true);
        if (mongoDB?.isConnected == true) {
          debugPrint('[DbClient] MongoDB connected successfully');
          return mongoDB;
        }
        await _closeConnection();
      } on Exception catch (e) {
        debugPrint('[DbClient] Connection attempt $attempt failed: $e');
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
      await transcriptRepo.getTranscript(userID: _session!.userId);
      await courseRepo.fetchModules(userID: _session!.userId);
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
