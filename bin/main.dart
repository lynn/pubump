#!/usr/bin/env dart

import 'package:pubump/pubump.dart';
import 'dart:io';
import 'package:args/args.dart';

void usage() {
  stderr.write(
      'usage: pubump [--push] [--publish] <major|minor|patch|build> "Changed X, Y, and Z"\n\n'
      '  * Updates pubspec.yaml\n'
      '  * Updates CHANGELOG.md\n'
      '  * Makes a git commit\n'
      '  * Runs `git push` (if -g or --push is passed)\n'
      '  * Runs `pub publish` (if -p or --publish is passed)\n\n');
  exit(2);
}

void main(List<String> arguments) {
  final parser = ArgParser();
  parser.addFlag('push', abbr: 'g');
  parser.addFlag('publish', abbr: 'p');
  final options = parser.parse(arguments);
  
  // Check/interpret arguments.
  if (options.rest.length != 2) {
    usage();
  }
  Level level;
  try {
    level = parseLevel(options.rest[0]);
  } catch (e) {
    usage();
  }
  final message = options.rest[1];
  if (message.isEmpty) {
    usage();
  }

  // Bump version.
  pubump(
    push: options['push'],
    publish: options['publish'],
    level: level,
    message: message,
  );
}
