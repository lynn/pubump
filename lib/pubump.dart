import 'dart:io';
import './level.dart';
import './version.dart';
export './level.dart';

/// Print an error message to STDERR and exit with exit code 1.
void die(String message) {
  stderr.write('$message\n');
  exit(1);
}

/// Expect a ProcessResult to be successful, aborting if it isn't.
ProcessResult successfully(ProcessResult result) {
  if (result.exitCode != 0) {
    die(result.stderr);
  }
  return result;
}

/// Update the working directory's pubspec by the given level.
Future<Version> updatePubspec(Level level) async {
  var pubspec;
  var lines;
  try {
    pubspec = await File('pubspec.yaml');
    lines = await pubspec.readAsLines();
  } catch (e) {
    die("Error: Couldn't find pubspec.yaml. Run pubump from your package root.");
  }
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

/// Return `true` if no files are staged in git.
Future<bool> nothingStaged() async {
  final result = await Process.run('git', ['diff', '--cached', '--exit-code']);
  return result.exitCode == 0;
}

Future<String> coloredDiff() async {
  final result = await Process.run(
      'git', ['--no-pager', 'diff', '--color', 'HEAD^', '--', 'CHANGELOG.md', 'pubspec.yaml']);
  return result.stdout;
}

Future<void> pubump({bool push, bool publish, Level level, String message}) async {
  // Don't allow an empty version bump.
  if (await nothingStaged()) {
    die('Error: Please stage the changes (git add ...) you would like pubump to commit.');
  }

  // Update files.
  final version = await updatePubspec(level);
  if (version == null) {
    die("Error parsing pubspec.yaml: Didn't find a `version: 1.2.3+4` line to bump.");
  }
  var changelog, content;
  try {
    changelog = await File('CHANGELOG.md');
    content = await changelog.readAsString();
  } catch (e) {
    die("Error: Couldn't find CHANGELOG.md. Run pubump from your package root, and create a CHANGELOG.md file there.");
  }
  await changelog.writeAsString('## $version\n\n- $message\n\n$content');

  // Create a commit.
  final commit = successfully(await Process.run('git', ['commit', '-am', '$version: $message']));
  print(commit.stdout); // print(await coloredDiff());

  // Optional post-bump actions.
  if (push) {
    print('Running `git push`...');
    successfully(await Process.run('git', ['push']));
  }
  if (publish) {
    print('Running `pub publish --force`...');
    successfully(await Process.run('pub', ['publish', '--force']));
  }

  // Report success.
  final verbed =
      push ? (publish ? 'Pushed and published' : 'Pushed') : (publish ? 'Published' : 'Created');
  print('All done! $verbed version $version.');
  exit(0);
}
