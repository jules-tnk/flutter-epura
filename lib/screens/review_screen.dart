import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../providers/file_service.dart';
import '../providers/review_provider.dart';
import '../providers/settings_provider.dart';
import '../services/database_service.dart';
import '../services/thumbnail_cache.dart';
import '../theme/app_theme.dart';
import '../widgets/epura_components.dart';
import '../widgets/review_card.dart';

enum LeaveReviewChoice { cancel, saveAndExit, discardAndExit }

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  static const int _thumbnailPrefetchWindow = 10;
  final CardSwiperController _swiperController = CardSwiperController();
  bool _completing = false;
  double _completionProgress = 0.0;
  int _deletionsDone = 0;
  int _deletionsTotal = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchThumbnailWindow();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<LeaveReviewChoice> _showLeaveDialog() async {
    final l = AppLocalizations.of(context)!;
    final result = await showDialog<LeaveReviewChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.leaveReview),
        content: Text(l.leaveReviewMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, LeaveReviewChoice.cancel),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, LeaveReviewChoice.discardAndExit),
            child: Text(l.discardAndExit),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, LeaveReviewChoice.saveAndExit),
            child: Text(l.saveAndExit),
          ),
        ],
      ),
    );
    return result ?? LeaveReviewChoice.cancel;
  }

  Future<void> _syncAfterCompletion(
    FileService fileService,
    ReviewCompletionResult result,
    SettingsProvider settings,
    DatabaseService db,
  ) async {
    await fileService.resolveImportedDocumentsAfterReview(result);
    await fileService.refreshAllFiles(settings, db: db);
  }

  void _syncAfterCompletionInBackground(
    FileService fileService,
    ReviewCompletionResult result,
    SettingsProvider settings,
    DatabaseService db,
  ) {
    unawaited(
      _syncAfterCompletion(fileService, result, settings, db).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'review_completion',
            context: ErrorDescription(
              'while syncing files after review completion',
            ),
          ),
        );
      }),
    );
  }

  void _prefetchThumbnailWindow() {
    if (_completing) return;

    final review = context.read<ReviewProvider>();
    if (review.isComplete) return;

    final items = review.queue
        .skip(review.currentIndex)
        .take(_thumbnailPrefetchWindow)
        .toList();
    if (items.isEmpty) return;

    unawaited(context.read<ThumbnailCache>().prefetch(items));
  }

  bool _handleSwipe(ReviewProvider review, CardSwiperDirection direction) {
    switch (direction) {
      case CardSwiperDirection.left:
        review.deleteCurrent();
      case CardSwiperDirection.right:
        review.keepCurrent();
      default:
        return true;
    }

    _prefetchThumbnailWindow();
    return true;
  }

  void _handleSkip(ReviewProvider review) {
    review.skipCurrent();
    _prefetchThumbnailWindow();
    if (!review.isComplete) {
      _swiperController.swipe(CardSwiperDirection.top);
    }
  }

  void _handleNeverAskAgain(ReviewProvider review) {
    review.neverAskAgainCurrent();
    _prefetchThumbnailWindow();
    if (!review.isComplete) {
      _swiperController.swipe(CardSwiperDirection.top);
    }
  }

  Widget _buildCompletionScreen(AppLocalizations l) {
    if (_deletionsTotal == 0) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXL),
          child: EpuraPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EpuraIconBubble(icon: Icons.delete_sweep_outlined, size: 64),
                const SizedBox(height: AppTheme.spaceMD),
                Text(
                  l.cleaningUp,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTheme.spaceMD),
                LinearProgressIndicator(
                  value: _completionProgress,
                  backgroundColor: Theme.of(context).dividerColor,
                  color: Theme.of(context).colorScheme.primary,
                  minHeight: 3,
                ),
                const SizedBox(height: AppTheme.spaceSM),
                Text(
                  l.filesRemovalProgress(_deletionsDone, _deletionsTotal),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeletionFailureBanner(
    BuildContext context,
    AppLocalizations l,
    int failedDeletionCount,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMD,
        AppTheme.spaceMD,
        AppTheme.spaceMD,
        0,
      ),
      child: Material(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceSM),
          child: Text(
            l.filesCouldNotBeDeleted(failedDeletionCount),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _promptLeaveReview() async {
    final choice = await _showLeaveDialog();
    await _handleLeaveChoice(choice);
  }

  Future<void> _startCompletionFlow() async {
    if (_completing) return;

    final review = context.read<ReviewProvider>();
    final fileService = context.read<FileService>();
    final db = context.read<DatabaseService>();
    final settings = context.read<SettingsProvider>();
    setState(() {
      _completing = true;
      _deletionsDone = 0;
      _deletionsTotal = review.pendingDeletionCount;
      _completionProgress = _deletionsTotal > 0 ? 0.0 : 1.0;
    });

    final result = await review.completeSession(
      db,
      settings,
      onProgress: (done, total) {
        if (!mounted) return;
        setState(() {
          _deletionsDone = done;
          _completionProgress = total > 0 ? done / total : 1.0;
        });
      },
    );

    _syncAfterCompletionInBackground(fileService, result, settings, db);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, EpuraApp.routeSummary);
  }

  Future<void> _handleLeaveChoice(LeaveReviewChoice choice) async {
    if (choice == LeaveReviewChoice.cancel || _completing) return;

    if (choice == LeaveReviewChoice.saveAndExit) {
      await _startCompletionFlow();
    } else {
      context.read<ReviewProvider>().discardSession();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final review = context.watch<ReviewProvider>();
    final l = AppLocalizations.of(context)!;

    if (review.isComplete && !_completing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_startCompletionFlow());
      });
    }

    if (_completing || review.isComplete) {
      return _buildCompletionScreen(l);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _promptLeaveReview();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _promptLeaveReview,
          ),
          title: Text(l.review),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spaceMD,
                  AppTheme.spaceMD,
                  AppTheme.spaceMD,
                  AppTheme.spaceXS,
                ),
                child: _ReviewStatusPanel(review: review, localizations: l),
              ),
              if (review.lastFailedDeletionCount > 0)
                _buildDeletionFailureBanner(
                  context,
                  l,
                  review.lastFailedDeletionCount,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spaceMD,
                    AppTheme.spaceXS,
                    AppTheme.spaceMD,
                    AppTheme.spaceXS,
                  ),
                  child: CardSwiper(
                    controller: _swiperController,
                    cardsCount: review.queue.length,
                    padding: EdgeInsets.zero,
                    initialIndex: review.currentIndex,
                    numberOfCardsDisplayed: 1,
                    isLoop: false,
                    backCardOffset: const Offset(0, 0),
                    allowedSwipeDirection:
                        const AllowedSwipeDirection.symmetric(
                          horizontal: true,
                          vertical: false,
                        ),
                    onSwipe: (previousIndex, currentIndex, direction) =>
                        _handleSwipe(review, direction),
                    cardBuilder:
                        (context, index, percentThresholdX, percentThresholdY) {
                          if (index >= review.queue.length) {
                            return const SizedBox.shrink();
                          }
                          final item = review.queue[index];
                          return ReviewCard(
                            item: item,
                            onKeep: () {
                              _swiperController.swipe(
                                CardSwiperDirection.right,
                              );
                            },
                            onDelete: () {
                              _swiperController.swipe(CardSwiperDirection.left);
                            },
                            onNeverAskAgain: () => _handleNeverAskAgain(review),
                          );
                        },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spaceMD,
                  0,
                  AppTheme.spaceMD,
                  AppTheme.spaceSM,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => _handleSkip(review),
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(l.skipForLater),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewStatusPanel extends StatelessWidget {
  final ReviewProvider review;
  final AppLocalizations localizations;

  const _ReviewStatusPanel({required this.review, required this.localizations});

  @override
  Widget build(BuildContext context) {
    final total = review.queue.length;
    final current = total == 0
        ? 0
        : (review.isComplete ? total : review.currentIndex + 1);
    final progressValue = total == 0 ? 0.0 : review.currentIndex / total;

    return EpuraPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: Theme.of(context).dividerColor,
            color: Theme.of(context).colorScheme.primary,
            minHeight: 4,
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Wrap(
            spacing: AppTheme.spaceSM,
            runSpacing: AppTheme.spaceXS,
            children: [
              EpuraPill(
                icon: Icons.rate_review_outlined,
                label: localizations.reviewProgress(current, total),
              ),
              EpuraPill(
                icon: Icons.delete_outline,
                label: localizations.filesMarkedForDeletion(
                  review.pendingDeletionCount,
                ),
                color: review.pendingDeletionCount > 0
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
