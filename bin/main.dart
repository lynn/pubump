#!/usr/bin/env dart

import 'package:pubump/pubump.dart';
import 'dart:io';

Level parseLevel(String levelString) {
  switch (levelString) {
    case 'major':
      return Level.major;
    case 'minor':
      return Level.minor;
    case 'patch':
      return Level.patch;
    case 'build':
      return Level.build;
    default:
      throw ArgumentError('Invalid patch level: $levelString. '
          'Expected one of: major, minor, patch, build.');
  }
}

void usage() {
  stderr.write(
      'usage: pubump [--push] [--publish] <major|minor|patch|build> "Changed X, Y, and Z"\n\n'
      '  * Updates pubspec.yaml\n'
      '  * Updates CHANGELOG.md\n'
      '  * Makes a git commit\n'
      '  * Runs `git push` (if --push is passed)\n'
      '  * Runs `pub publish` (if --publish is passed)\n\n');
}

void main(List<String> arguments) {
  // Parse arguments.
  final push = arguments.contains('--push');
  final publish = arguments.contains('--publish');
  final positional = arguments.where((arg) => !arg.startsWith('--')).toList();

  // Check/interpret arguments.
  if (positional.length != 2) {
    usage();
    exit(2);
  }
  Level level;
  try {
    level = parseLevel(positional[0]);
  } catch (e) {
    usage();
    exit(2);
  }
  final message = positional[1];
  if (message.isEmpty) {
    usage();
    exit(2);
  }

  // Bump version.
  pubump(
    push: push,
    publish: publish,
    level: level,
    message: message,
  );
}
