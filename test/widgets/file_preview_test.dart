import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:epura/models/review_item.dart';
import 'package:epura/services/thumbnail_cache.dart';
import 'package:epura/theme/app_theme.dart';
import 'package:epura/widgets/file_preview.dart';

import '../test_helpers.dart';

void main() {
  const transparentPngBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC';

  testWidgets('FilePreview rebuilds when thumbnail cache is populated', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final cache = ThumbnailCache();
    final item = ReviewItem(
      id: 'asset-1',
      name: 'photo.jpg',
      path: '/tmp/photo.jpg',
      size: 10,
      type: FileItemType.photo,
      date: DateTime(2026, 4, 13),
      source: ReviewItemSource.mediaLibrary,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cache,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: FilePreview(item: item),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsNothing);

    cache.insertForTesting('asset-1', base64Decode(transparentPngBase64));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('FilePreview fits photo thumbnails without cropping', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final cache = ThumbnailCache()
      ..insertForTesting('photo-fit', base64Decode(transparentPngBase64));
    final item = ReviewItem(
      id: 'photo-fit',
      name: 'photo.jpg',
      path: '/tmp/photo.jpg',
      size: 10,
      type: FileItemType.photo,
      date: DateTime(2026, 4, 13),
      source: ReviewItemSource.mediaLibrary,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cache,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 220,
              child: FilePreview(item: item),
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.contain);
  });

  testWidgets('FilePreview fits video thumbnails without cropping', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final cache = ThumbnailCache()
      ..insertForTesting('video-fit', base64Decode(transparentPngBase64));
    final item = ReviewItem(
      id: 'video-fit',
      name: 'clip.mp4',
      path: '/tmp/clip.mp4',
      size: 10,
      type: FileItemType.video,
      date: DateTime(2026, 4, 13),
      source: ReviewItemSource.mediaLibrary,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cache,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 220,
              child: FilePreview(item: item),
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.contain);
  });
}
