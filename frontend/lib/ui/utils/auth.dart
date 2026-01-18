import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/services.dart';
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

  static Db? mongoDB = null;

  static Future<Db?> getMongoDBClient () async {
    if (mongoDB != null) {
      return mongoDB;
    } else {
      try{
        mongoDB = await Db.create(MONGO_URI!);
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
  if (!value.endsWith("gmail.com")) {
    return "Email address is not valid";
  }
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

class ClientSession {
    static Session? userSession = null;

    static void setUserSession(Session session) {
        userSession = session;
    }

    static Session? getClientSession() {
      if (userSession == null) {
        // navigate to login page since session is not set
      }

      if (!userSession!.current) {
        //navigate to login since session is outdated
      }

      return userSession;
  }
}
