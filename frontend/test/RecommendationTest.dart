import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/repos/CourseSearchRepo.dart';
import 'package:frontend/repos/Recommendation.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:frontend/repos/UserRepository.dart';
import 'package:frontend/service/MongoService.dart';
import 'package:frontend/service/OpenAIService.dart';
import 'package:frontend/utils/RecoLog.dart';

void main() {
  final openAIService = OpenAIService();
  final mongoService = MongoService();
  final transcriptRepo = TranscriptRepository(openAIService: openAIService, mongoService: mongoService);
  final courseSearchRepo = CourseSearchRepo(mongoService: mongoService);
  final userRepo = UserRepository(mongoService: mongoService, transcriptRepo: transcriptRepo);

  group('Test candidate generation', () {
    setUpAll(() async {
      await dotenv.load(fileName: '.env');
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
      OpenAI.requestsTimeOut = const Duration(minutes: 3);
    });

    test("Test ISM Master Transcript 1", () async {
      String userID = "695f8904bcac7f16a725";
      var rec = Recommendation(
          openAIService: openAIService,
          mongoService: mongoService,
          courseRepo: courseSearchRepo,
          userRepo: userRepo
      );
      var candidates = await rec.candicate_generation(userID);
      RecoLog.info("Got ${candidates?.length} candidates");
      RecoLog.info(candidates);
    });

    test("Test CS Master Transcript 1", () async {
      String userID = "696fc7786cc80f940621";
      var rec = Recommendation(
          openAIService: openAIService,
          mongoService: mongoService,
          courseRepo: courseSearchRepo,
          userRepo: userRepo
      );
      var candidates = await rec.candicate_generation(userID);
      RecoLog.info("Got ${candidates?.length} candidates");
      RecoLog.info(candidates);
    });

    test("Test ISM Master Transcript 2", () async {
      String userID = "697fcca16cb5002817b1";
      var rec = Recommendation(
          openAIService: openAIService,
          mongoService: mongoService,
          courseRepo: courseSearchRepo,
          userRepo: userRepo
      );
      var candidates = await rec.candicate_generation(userID);
      RecoLog.info("Got ${candidates?.length} candidates");
      RecoLog.info(candidates);
    });

    test("Test CS bachelor transcript", () async {
      String userID = "6967699402af64b787c3";
      var rec = Recommendation(
          openAIService: openAIService,
          mongoService: mongoService,
          courseRepo: courseSearchRepo,
          userRepo: userRepo
      );
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
      var embedding = await service.embedUserdetails(interests, programLiteral);
      expect(embedding, isNotNull);
      expect(embedding?.length, 1536);
    });
  });

  group("Test KNN mongo vector query", () {
    setUpAll(() async {
      await dotenv.load(fileName: '.env');
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
      OpenAI.requestsTimeOut = const Duration(minutes: 3);
    });

    test("Query for embedding", () async {
      var service = OpenAIService();
      var mongoService = MongoService();
      var programLiteral = "ISM";
      var interests = ["Blockchain", "Machine Learning"];
      var embedding = await service.embedUserdetails(interests, programLiteral);
      if (embedding == null) {
        print("embedding was null");
      }
      var res = await mongoService.vectorSearchCourses(
        queryVector: embedding!,
        candidateModules: ["40009", "40021", "40036"],
      );
      print(res);
    });

    group("Fuzzy match the exams on the transcript with the course titles", () {
      setUpAll(() async {
        await dotenv.load(fileName: '.env');
        OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
        OpenAI.requestsTimeOut = const Duration(minutes: 3);
      });

      test("test two similar names", () async {
        var mongoService = MongoService();
        var examNamesToTest = [
          "Natural Language Processing",
          "Blockchain-Technologie und Dezentrale Anwendungen",
        ];
        var expectedModulesNrs = ["41047", "40888"];

        var matchedModules = await mongoService.fuzzyMatchExamNames(
          examNamesToTest,
        );
        print("Matched modules: $matchedModules");

        expect(matchedModules.length, expectedModulesNrs.length);
        for (var i = 0; i < expectedModulesNrs.length; i++) {
          expect(matchedModules[i], expectedModulesNrs[i]);
        }
      });

      test("test two non-similar names", () async {
        var mongoService = MongoService();
        var examNamesToTest = [
          "Natural Language",
          "Blockchain-Technologie und Dezentrale",
        ];
        var expectedModulesNrs = ["41047", "40888"];

        var matchedModules = await mongoService.fuzzyMatchExamNames(
          examNamesToTest,
        );
        print("Matched modules: $matchedModules");

        expect(matchedModules.length, expectedModulesNrs.length);
        for (var i = 0; i < expectedModulesNrs.length; i++) {
          expect(matchedModules[i], expectedModulesNrs[i]);
        }
      });
    });
  });

  group("Test candidate ranking prompt execution", () {
    setUpAll(() async {
      await dotenv.load(fileName: '.env');
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
      OpenAI.requestsTimeOut = const Duration(minutes: 3);
    });

    test("rank candidates based on interests and exams taken", () async {
      var service = OpenAIService();

      // Mock exam history
      var examsTaken = [
        "Introduction to Programming",
        "Data Structures and Algorithms",
        "Database Systems",
      ];

      // Mock interests
      var interests = ["Machine Learning", "Data Science", "Cloud Computing"];

      // Mock candidate modules
      var candidates = [
        Module(
          id: "1",
          url: "https://example.com/ml",
          title: "Machine Learning Fundamentals",
          moduleNr: "40001",
          credits: "6",
          examType: "Written Exam",
          matchPercentage: 0,
          tags: [],
          learnContent:
              "Introduction to supervised and unsupervised learning algorithms",
          learnResult: "Students can implement basic ML models",
        ),
        Module(
          id: "2",
          url: "https://example.com/acf",
          title: "Advanced Corporate Finance",
          moduleNr: "40002",
          credits: "6",
          examType: "Written Exam",
          matchPercentage: 0,
          tags: [],
          learnContent: "Financial analysis and corporate valuation",
          learnResult: "Students understand corporate finance principles",
        ),
        Module(
          id: "3",
          url: "https://example.com/dl",
          title: "Deep Learning",
          moduleNr: "40003",
          credits: "6",
          examType: "Portfolio Exam",
          matchPercentage: 0,
          tags: [],
          learnContent: "Neural networks, CNNs, RNNs, and transformers",
          learnResult: "Students can build deep learning models",
        ),
        Module(
          id: "4",
          url: "https://example.com/cloud",
          title: "Cloud Computing",
          moduleNr: "40004",
          credits: "6",
          examType: "Portfolio Exam",
          matchPercentage: 0,
          tags: [],
          learnContent: "AWS, Azure, distributed systems in the cloud",
          learnResult: "Students can deploy cloud-native applications",
        ),
      ];

      var rankedModules = await service.candidateRankingPromptExecution(
        examsTaken,
        interests,
        candidates,
        3, // Top 3
      );

      print("Ranked modules: $rankedModules");

      // Verify we got results
      expect(rankedModules, isNotNull);
      expect(rankedModules!.length, 3);

      // Verify the returned values are valid module numbers from our candidates
      var validModuleNrs = candidates.map((m) => m.moduleNr).toSet();
      for (var moduleNr in rankedModules) {
        expect(
          validModuleNrs.contains(moduleNr),
          isTrue,
          reason: "Returned module $moduleNr not in candidates",
        );
      }
    });
  });

  group("Test full recommendation pipeline - candidate generation", () {
    setUpAll(() async {
      await dotenv.load(fileName: '.env');
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
      OpenAI.requestsTimeOut = const Duration(minutes: 3);
    });

    test("generate candidates for user", () async {
      String userID = "696fc7786cc80f940621";
      var rec = Recommendation(
          openAIService: openAIService,
          mongoService: mongoService,
          courseRepo: courseSearchRepo,
          userRepo: userRepo
      );
      var candidates = await rec.candicate_generation(userID);

      print("Generated ${candidates?.length} candidates");
      print("Candidates: $candidates");

      expect(candidates, isNotNull);
      expect(candidates!.isNotEmpty, isTrue);
    });
  });

  group("Test full recommendation pipeline - candidate ranking", () {
    setUpAll(() async {
      await dotenv.load(fileName: '.env');
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
      OpenAI.requestsTimeOut = const Duration(minutes: 3);
    });

    test("rank candidates for user", () async {
      String userID = "696fc7786cc80f940621";
      var rec = Recommendation(
          openAIService: openAIService,
          mongoService: mongoService,
          courseRepo: courseSearchRepo,
          userRepo: userRepo
      );

      var candidates = await rec.candicate_generation(userID);
      expect(candidates, isNotNull);
      print("Generated ${candidates!.length} candidates");

      var interests = ["Machine Learning", "Data Science"];
      var programLiteral = "ISM";
      var embedding = await openAIService.embedUserdetails(
        interests,
        programLiteral,
      );
      expect(embedding, isNotNull);

      var rankedCandidates = await rec.candidate_ranking(
        userID,
        candidates,
        embedding!,
      );

      print("Ranked ${rankedCandidates?.length} candidates");
      print("Ranked candidates: $rankedCandidates");

      expect(rankedCandidates, isNotNull);
      expect(rankedCandidates!.isNotEmpty, isTrue);
    });
  });

  group("Test getRecommendedModules API", () {
    setUpAll(() async {
      await dotenv.load(fileName: '.env');
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
      OpenAI.requestsTimeOut = const Duration(minutes: 3);
    });

    test("get recommended modules for user with existing recommendations", () async {
      String userID = "696fc7786cc80f940621";
      var rec = Recommendation(
        openAIService: openAIService,
        mongoService: mongoService,
        courseRepo: courseSearchRepo,
        userRepo: userRepo,
      );

      var modules = await rec.getRecommendedModules(userID);

      print("Got ${modules?.length} recommended modules");
      if (modules != null) {
        for (var m in modules) {
          print("- ${m.moduleNr}: ${m.title}");
        }
      }

      expect(modules, isNotNull);
    });

    test("get recommended modules for user without recommendations", () async {
      String userID = "697fcca16cb5002817b1";
      var rec = Recommendation(
        openAIService: openAIService,
        mongoService: mongoService,
        courseRepo: courseSearchRepo,
        userRepo: userRepo,
      );

      var modules = await rec.getRecommendedModules(userID);

      print("Got ${modules?.length} recommended modules");
      if (modules != null) {
        for (var m in modules) {
          print("- ${m.moduleNr}: ${m.title}");
        }
      }
    });
  });
}
