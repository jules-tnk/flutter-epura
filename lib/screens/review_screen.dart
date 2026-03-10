import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../providers/review_provider.dart';
import '../services/database_service.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/review_card.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  bool _completing = false;

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final l = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.leaveReview),
        content: Text(l.leaveReviewMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.leave),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _checkCompletion() {
    if (_completing) return;
    final review = context.read<ReviewProvider>();
    if (review.isComplete) {
      _completing = true;
      final db = context.read<DatabaseService>();
      final settings = context.read<SettingsProvider>();
      review.completeSession(db, settings).then((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, EpuraApp.routeSummary);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final review = context.watch<ReviewProvider>();
    final l = AppLocalizations.of(context)!;

    if (review.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkCompletion();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                navigator.pop();
              }
            },
          ),
          title: Text(review.progress),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: review.queue.isEmpty
                    ? 0
                    : review.currentIndex / review.queue.length,
                backgroundColor: AppTheme.divider,
                color: AppTheme.accent,
                minHeight: 3,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMD),
                  child: CardSwiper(
                    controller: _swiperController,
                    cardsCount: review.queue.length,
                    initialIndex: review.currentIndex,
                    numberOfCardsDisplayed: 1,
                    isLoop: false,
                    backCardOffset: const Offset(0, 0),
                    allowedSwipeDirection:
                        const AllowedSwipeDirection.symmetric(
                      horizontal: true,
                      vertical: false,
                    ),
                    onSwipe: (previousIndex, currentIndex, direction) {
                      if (direction == CardSwiperDirection.left) {
                        review.deleteCurrent();
                      } else if (direction == CardSwiperDirection.right) {
                        review.keepCurrent();
                      }
                      return true;
                    },
                    cardBuilder: (context, index, percentThresholdX,
                        percentThresholdY) {
                      if (index >= review.queue.length) {
                        return const SizedBox.shrink();
                      }
                      final item = review.queue[index];
                      return ReviewCard(
                        item: item,
                        onKeep: () {
                          _swiperController.swipe(CardSwiperDirection.right);
                        },
                        onDelete: () {
                          _swiperController.swipe(CardSwiperDirection.left);
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spaceMD),
                child: TextButton(
                  onPressed: () {
                    review.skipCurrent();
                    if (!review.isComplete) {
                      _swiperController.swipe(CardSwiperDirection.top);
                    }
                  },
                  child: Text(l.skipForLater),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
