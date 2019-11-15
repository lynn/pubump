import 'dart:io';
import './level.dart';
import './version.dart';
export './level.dart';

Future<Version> updatePubspec(Level level) async {
  final pubspec = await File('pubspec.yaml');
  final lines = await pubspec.readAsLines();
  final regExp = RegExp(r'(version:\s+)(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$');
  List<String> updatedLines = [];
  Version version;

  for (final line in lines) {
    final match = regExp.firstMatch(line);
    if (match == null) {
      updatedLines.add(line);
    } else {
      final prefix = match.group(1);
      final major = int.parse(match.group(2));
      final minor = int.parse(match.group(3));
      final patch = int.parse(match.group(4));
      final build = int.parse(match.group(5) ?? '0');
      final oldVersion = Version(major, minor, patch, build);
      version = oldVersion.bump(level);
      updatedLines.add(prefix + version.toString());
    }
  }

  await pubspec.writeAsString(updatedLines.join('\n') + '\n');
  return version;
}

Future<void> updateChangelog(Version version, String message) async {
  final changelog = await File('CHANGELOG.MD');
  final content = await changelog.readAsString();
  await changelog.writeAsString('## $version\n\n- $message\n\n$content');
}

Future<bool> anythingUnstaged() async {
  final result = await Process.run('git', ['diff', '--exit-code']);
  return result.exitCode == 1;
}

Future<bool> nothingStaged() async {
  final result = await Process.run('git', ['diff', '--cached', '--exit-code']);
  return result.exitCode == 0;
}

void die(String message) {
  stderr.write('$message\n');
  exit(1);
}

Future<String> coloredDiff() async {
  final result = await Process.run(
      'git', ['--no-pager', 'diff', '--color', 'HEAD^', '--', 'CHANGELOG.md', 'pubspec.yaml']);
  return result.stdout;
}

Future<void> pubump({bool push, bool publish, Level level, String message}) async {
  // if (await anythingUnstaged()) {
  //   die('You have unstaged changes; please stash them.');
  // }
  if (await nothingStaged()) {
    die('Please stage the changes (git add ...) you would like pubump to commit.');
  }
  final version = await updatePubspec(level);
  await updateChangelog(version, message);

  final commit = await Process.run('git', ['commit', '-am', '$version: $message']);
  print(commit.stdout);
  // print(await coloredDiff());
  if (push) {
    await Process.run('git', ['push']);
  }
  if (publish) {
    await Process.run('pub', ['publish']);
  }
  final verbed =
      push ? (publish ? 'Pushed and published' : 'Pushed') : (publish ? 'Published' : 'Created');
  print('$verbed version $version');

  exit(0);
}
