import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:epura/l10n/app_localizations.dart';
import 'package:epura/models/review_item.dart';
import 'package:epura/services/thumbnail_cache.dart';
import 'package:epura/theme/app_theme.dart';
import 'package:epura/widgets/review_card.dart';

import '../test_helpers.dart';

Future<void> _pumpReviewCard(WidgetTester tester, ReviewItem item) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: ThumbnailCache(),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 900,
            child: ReviewCard(
              item: item,
              onKeep: () {},
              onDelete: () {},
              onNeverAskAgain: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ReviewCard opens full-screen preview from the preview area', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    configureTestViewport(tester);
    try {
      final item = testPhotoReviewItem('preview-photo', 'preview-photo.jpg');

      await _pumpReviewCard(tester, item);

      await tester.tap(find.bySemanticsLabel('Open preview'));
      await tester.pumpAndSettle();

      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.text('preview-photo.jpg'), findsOneWidget);
    } finally {
      semantics.dispose();
      resetTestViewport(tester);
    }
  });

  testWidgets('ReviewCard shows video duration when available', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final item = ReviewItem(
      id: 'video-1',
      name: 'clip.mp4',
      path: 'C:/tmp/clip.mp4',
      size: 2048,
      type: FileItemType.video,
      date: DateTime(2026, 5, 31),
      source: ReviewItemSource.mediaLibrary,
      durationSeconds: 125,
    );

    await _pumpReviewCard(tester, item);

    expect(find.text('2:05'), findsOneWidget);
  });

  testWidgets('ReviewCard action buttons use content-sized widths', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    await _pumpReviewCard(
      tester,
      testPhotoReviewItem('compact-actions', 'compact-actions.jpg'),
    );

    final deleteSize = tester.getSize(
      find.byKey(const ValueKey('review-delete-button')),
    );
    final keepSize = tester.getSize(
      find.byKey(const ValueKey('review-keep-button')),
    );
    final cardLeft = tester.getTopLeft(find.byType(ReviewCard)).dx;
    final cardRight = tester.getBottomRight(find.byType(ReviewCard)).dx;
    final deleteLeft = tester
        .getTopLeft(find.byKey(const ValueKey('review-delete-button')))
        .dx;
    final keepRight = tester
        .getBottomRight(find.byKey(const ValueKey('review-keep-button')))
        .dx;

    expect(deleteSize.height, 44);
    expect(keepSize.height, 44);
    expect(deleteSize.width, lessThan(170));
    expect(keepSize.width, lessThan(170));
    expect(deleteLeft, greaterThan(cardLeft + 20));
    expect(deleteLeft, lessThan(cardLeft + 48));
    expect(keepRight, greaterThan(cardRight - 48));
    expect(keepRight, lessThan(cardRight - 20));
  });

  testWidgets('ReviewCard shows duplicate candidate context', (tester) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final item = ReviewItem(
      id: 'dup',
      name: 'dup.jpg',
      path: '/tmp/dup.jpg',
      size: 10,
      type: FileItemType.photo,
      date: DateTime(2026, 5, 31),
      source: ReviewItemSource.mediaLibrary,
      duplicateGroupId: 'group',
      duplicateGroupSize: 2,
      duplicateGroupIndex: 1,
      duplicateRecoverableBytes: 10,
    );

    await _pumpReviewCard(tester, item);

    expect(find.text('Duplicate 1 of 2'), findsOneWidget);
    expect(find.textContaining('content fingerprint'), findsOneWidget);
  });

  testWidgets('ReviewCard shows burst context without quality claims', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final item = testPhotoReviewItem('burst-a', 'burst-a.jpg').copyWith(
      burstGroupId: 'burst:test',
      burstGroupSize: 2,
      burstGroupIndex: 1,
    );

    await _pumpReviewCard(tester, item);

    expect(find.text('Burst 1 of 2'), findsOneWidget);
    expect(
      find.text(
        'Taken close together. Review each shot; Epura will not choose a best photo automatically.',
      ),
      findsOneWidget,
    );
  });
}
