
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/repos/Recommendation.dart';
import 'package:frontend/utils/RecoLog.dart';

void main() {
  group('Test candidate generation', () {
    setUpAll(() async {
      await dotenv.load(fileName: '.env');
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
}
