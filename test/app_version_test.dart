import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:epura/app_version.dart';

void main() {
  test('display version matches pubspec build name', () {
    final versionLine = File(
      'pubspec.yaml',
    ).readAsLinesSync().firstWhere((line) => line.startsWith('version: '));
    final pubspecVersion = versionLine.substring('version: '.length).trim();
    final pubspecBuildName = pubspecVersion.split('+').first;

    expect(appDisplayVersion, pubspecBuildName);
  });
}
