import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:epura/models/review_item.dart';
import 'package:epura/services/thumbnail_cache.dart';
import 'package:epura/theme/app_theme.dart';
import 'package:epura/widgets/file_preview.dart';

import '../test_helpers.dart';

void main() {
  const validPngBytes = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41,
    0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
    0x00, 0x03, 0x01, 0x01, 0x00, 0xC9, 0xFE, 0x92,
    0xEF, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
    0x44, 0xAE, 0x42, 0x60, 0x82,
  ];

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

    cache.insertForTesting('asset-1', Uint8List.fromList(validPngBytes));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
  });
}
