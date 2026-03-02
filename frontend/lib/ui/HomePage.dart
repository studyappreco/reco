import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/models/UserDetails.dart';
import 'package:frontend/repos/Recommendation.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:frontend/repos/transcriptUtils.dart';
import 'package:frontend/repos/UserRepository.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:frontend/ui/widgets/CourseCard/CourseCard.dart';
import 'package:frontend/ui/widgets/CourseOverview.dart';
import 'package:frontend/ui/widgets/TranscriptMissingCard.dart';
import 'package:frontend/ui/widgets/TranscriptProcessingCard.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final clientSession = context.read<ClientSession>();

    return ChangeNotifierProvider<HomePageViewmodel>(
      create: (_) => HomePageViewmodel(
        context.read(),
        context.read(),
        clientSession,
        context.read(),
        context.read(),
      )..initialize(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Dashboard"),
          actions: [
            IconButton(
              onPressed: () async {
                Client? client = BackendClient.getBackendClient();
                if (client == null) {
                  clientSession.clearUserSession();
                  return;
                }
                Account account = Account(client);
                await account.deleteSession(sessionId: 'current');
                clientSession.clearUserSession();
              },
              iconSize: 30,
              icon: Icon(Icons.account_circle_outlined),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        body: Consumer<HomePageViewmodel>(
          builder: (context, vm, child) {
            return Padding(
              padding: EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 4,
                  children: [
                    Text(
                      "Hello ${vm.username.isNotEmpty ? vm.username : 'there'}",
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                      "Here's your academic overview",
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20),
                    if (vm.transcriptLoading)
                      Center(child: CircularProgressIndicator())
                    else
                      ...[
                        switch (vm.transcriptAvailability) {
                          TranscriptAvailability.undefined => Text("undefined"),
                          TranscriptAvailability.missing => Padding(
                            padding: EdgeInsets.all(4),
                            child: TranscriptMissingCard(
                              onUploadPressed: () =>
                                  context.push("/home/upload-transcript"),
                              onSkipPressed: vm.onSkipUploadTranscript,
                            ),
                          ),
                          TranscriptAvailability.processing => Padding(
                            padding: EdgeInsets.all(4),
                            child: TranscriptProcessingCard(
                              hasFinished:
                                  vm._transcriptAvailability != .processing,
                              onAnimationComplete: () {},
                            ),
                          ),
                          TranscriptAvailability.available => _TranscriptWidget(
                            gpa: vm.gpa,
                            ects: vm.ects,
                            categories: vm.categories,
                          ),
                        },
                      ],
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: .spaceBetween,
                        crossAxisAlignment: .center,
                        children: [
                          Text(
                            "Recommended for you",
                            style: textTheme.titleLarge?.copyWith(
                              color: AppColors.textMain,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "See all",
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (vm.recommendationsLoading)
                      Center(child: CircularProgressIndicator())
                    else if (vm.recommendedModules.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "No recommendations available yet.",
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      ...vm.recommendedModules.take(5).map(
                        (module) => CourseCard(
                          title: module.title,
                          moduleNr: module.moduleNr,
                          credits: module.credits,
                          tags: module.tags,
                          rating: module.rating,
                          isFavorite: module.isFavorite,
                          isPlanned: module.isPlanned,
                          isRecommended: module.isRecommended,
                          onCardTap: () => context.go(
                            '/home/course-details',
                            extra: module.moduleNr,
                          ),
                          onFavoriteTap: () {},
                          onPlanTap: () {},
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TranscriptWidget extends StatelessWidget {
  final double gpa;
  final int ects;
  final List<OverviewCategory> categories;

  const _TranscriptWidget({
    required this.gpa,
    required this.ects,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: AdaptiveButton(
            onPressed: () => context.push("/review-courses"),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "Current GPA",
                        style: textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      gpa.toStringAsFixed(1),
                      style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "Current ECTS",
                        style: textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      ects.toString(),
                      style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: CourseOverview(
            categories: categories,
            detailsButtonDestination: "/review-courses",
          ),
        ),
      ],
    );
  }
}

enum TranscriptAvailability { undefined, missing, processing, available }

class HomePageViewmodel extends ChangeNotifier {
  final TranscriptRepository transcriptRepo;
  final UserRepository userRepo;
  final ClientSession clientSession;
  final TranscriptProcessor transcriptProcessor;
  final Recommendation recommendation;

  HomePageViewmodel(
    this.transcriptRepo,
    this.userRepo,
    this.clientSession,
    this.transcriptProcessor,
    this.recommendation,
  );

  /// Initializes the ViewModel by running init and loading recommendations sequentially.
  /// This prevents concurrent MongoDB operations on the single connection.
  Future<void> initialize() async {
    await _init();
    await _loadRecommendations();
  }

  bool _isDisposed = false;
  bool _transcriptLoading = true;
  TranscriptAvailability _transcriptAvailability = .undefined;
  double _gpa = 0.0;
  int _ects = 0;
  List<OverviewCategory> _categories = [];
  String _username = '';
  String? _userId;
  UserDetails? _userDetails;
  List<Module> _recommendedModules = [];
  bool _recommendationsLoading = true;

  bool get transcriptLoading => _transcriptLoading;
  TranscriptAvailability get transcriptAvailability => _transcriptAvailability;
  double get gpa => _gpa;
  int get ects => _ects;
  List<OverviewCategory> get categories => _categories;
  String get username => _username;
  List<Module> get recommendedModules => _recommendedModules;
  bool get recommendationsLoading => _recommendationsLoading;

  @override
  void dispose() {
    _isDisposed = true;
    transcriptProcessor.removeListener(_listen);
    super.dispose();
  }

  void _safeNotifyListeners() {
    //if (!_isDisposed) {
      notifyListeners();
    //}
  }

  void _listen() {
    if (transcriptProcessor.state == TranscriptProcessingState.processing) {
      _transcriptAvailability = .processing;
      _safeNotifyListeners();
    } else if (transcriptProcessor.state ==
        TranscriptProcessingState.completed) {
      _transcriptAvailability = .undefined;
      transcriptProcessor.removeListener(_listen);
      _loadTranscript(false);
    } else if (transcriptProcessor.state == TranscriptProcessingState.failed) {
      _transcriptAvailability = .undefined;
      transcriptProcessor.removeListener(_listen);
      _safeNotifyListeners();
    }
  }

  Future<void> _init() async {
    _transcriptLoading = true;
    _safeNotifyListeners();

    _userId = clientSession.getUserID();
    if (_userId == null) {
      _transcriptLoading = false;
      _safeNotifyListeners();
      return;
    }

    final username = await userRepo.getUsername(_userId!);
    if (username != null) {
      _username = username;
    }

    _userDetails = await userRepo.getUserDetails(_userId!);

    if (transcriptProcessor.state == TranscriptProcessingState.processing) {
      _transcriptLoading = false;
      _transcriptAvailability = .processing;
      transcriptProcessor.addListener(_listen);
      _safeNotifyListeners();
    } else {
      _loadTranscript(false);
    }
  }

  Future<void> _loadTranscript(bool forceRefresh) async {
    _transcriptLoading = true;
    _safeNotifyListeners();

    final userTranscript = await transcriptRepo.getTranscript(
      userID: _userId!,
      forceRefresh: forceRefresh,
    );
    final dto = userTranscriptToDashboardDTO(
      userTranscript,
      _userDetails?.programLiteral,
    );
    if (dto == null) {
      _transcriptLoading = false;
      _transcriptAvailability = .missing;
      transcriptProcessor.addListener(_listen);
      _safeNotifyListeners();
      return;
    }

    _gpa = dto.gpa ?? 0.0;
    _ects = dto.earnedCredits;
    _categories = dto.categories;
    _transcriptLoading = false;
    _transcriptAvailability = .available;
    transcriptProcessor.removeListener(_listen);
    _safeNotifyListeners();
  }

  Future<void> onSkipUploadTranscript() async {
    _transcriptLoading = true;
    _safeNotifyListeners();

    await transcriptRepo.uploadEmptyTranscript(
      _userId!,
      _userDetails?.programLiteral,
    );
    await _loadTranscript(false);
    _transcriptLoading = false;
    _safeNotifyListeners();
  }

  Future<void> _loadRecommendations() async {
    final userId = clientSession.getUserID();
    if (userId == null) return;

    _recommendationsLoading = true;
    _safeNotifyListeners();

    final modules = await recommendation.getRecommendedModules(userId);
    _recommendedModules = modules ?? [];
    _recommendationsLoading = false;
    _safeNotifyListeners();
  }
}
