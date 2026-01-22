import 'package:mongo_dart/mongo_dart.dart';
import 'package:frontend/models/module.dart';
import 'package:frontend/ui/utils/auth.dart';

class ModuleApi {
  static const String collection_name = "courses";

  // Get all modules from the database (since I don't know exactly how we will make the analysis/recommendation, I think we need to get all the data first and then make the recommendation locally?)
  static Future<List<Module>> fetchAllModules() async {
    final db = await DbCLient.getMongoDBClient();

    if(db == null || !db.isConnected){
      print("Database not connected");
      return [];
    }

    try {
      final collection = db.collection(collection_name);
      final List<Map<String, dynamic>> jsonList = await collection.find().toList();

      print("Loaded ${jsonList.length} courses from DB");

      return jsonList.map((json) => Module.fromMap(json)).toList();

    } catch (e) {
      print("Error fetching modules: $e");
      return [];
    }
  }
}