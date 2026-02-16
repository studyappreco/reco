
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/repos/Recommendation.dart';
import 'package:frontend/service/OpenAIService.dart';
import 'package:frontend/utils/RecoLog.dart';

void main() {
  group('Test candidate generation', () {
    setUpAll(() async {
      await dotenv.load(fileName: '.env');
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
      OpenAI.requestsTimeOut = const Duration(minutes: 3);
    });

    test("Test ISM Master Transcript 1", () async {
        String userID =  "695f8904bcac7f16a725";
        var rec = Recommendation();
        var candidates = await rec.candicate_generation(userID);
        RecoLog.info("Got ${candidates?.length} candidates");
        RecoLog.info(candidates);
    });

    test("Test CS Master Transcript 1", () async {
      String userID =  "696fc7786cc80f940621";
      var rec = Recommendation();
      var candidates = await rec.candicate_generation(userID);
      RecoLog.info("Got ${candidates?.length} candidates");
      RecoLog.info(candidates);
    });

    test("Test ISM Master Transcript 2", () async {
      String userID =  "697fcca16cb5002817b1";
      var rec = Recommendation();
      var candidates = await rec.candicate_generation(userID);
      RecoLog.info("Got ${candidates?.length} candidates");
      RecoLog.info(candidates);
    });

    test("Test CS bachelor transcript", () async {
      String userID =  "6967699402af64b787c3";
      var rec = Recommendation();
      var candidates = await rec.candicate_generation(userID);
      RecoLog.info("Got ${candidates?.length} candidates");
      RecoLog.info(candidates);
    });
  });

  group('Test User detail embedding', () {
    setUpAll(() async {
      await dotenv.load(fileName: '.env');
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
      OpenAI.requestsTimeOut = const Duration(minutes: 3);
    });

    test("create userdetail embedding", () async {
       var service = OpenAIService();
       var programLiteral = "ISM";
       var interests = ["Blockchain", "Machine Learning"];
       var embedding = await  service.embedUserdetails(interests, programLiteral);
       expect(embedding , isNotNull);
       expect(embedding?.length, 1536);
    });
  });
}
