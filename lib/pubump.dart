import 'dart:io';

enum Level {
  build,
  patch,
  minor,
  major,
}

class Version {
  int major;
  int minor;
  int patch;
  int build;
  Version(this.major, this.minor, this.patch, this.build);

  Version bump(Level level) {
    switch (level) {
      case Level.build:
        return Version(this.major, this.minor, this.patch, this.build + 1);
      case Level.patch:
        return Version(this.major, this.minor, this.patch + 1, 0);
      case Level.minor:
        return Version(this.major, this.minor + 1, 0, 0);
      case Level.major:
        return Version(this.major + 1, 0, 0, 0);
      default:
        throw ArgumentError();
    }
  }

  @override
  String toString() {
    if (build == 0) {
      return '$major.$minor.$patch';
    } else {
      return '$major.$minor.$patch+$build';
    }
  }
}

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

Future<void> gitPush() async {}
Future<void> pubPublish() async {}

Future<Version> pubump({bool push, bool publish, Level level, String message}) async {
  final version = await updatePubspec(level);
  await updateChangelog(version, message);
  final commit = await Process.run('git', ['commit', '-am', '$version: $message']);
  print(commit.stdout);
  final diff = await Process.run(
      'git', ['--no-pager', 'diff', '--color', 'HEAD^', '--', 'CHANGELOG.md', 'pubspec.yaml']);
  print(diff.stdout);
  if (push) {
    await gitPush();
  }
  if (publish) {
    await pubPublish();
  }
  final verbed =
      push ? (publish ? 'Pushed and published' : 'Pushed') : (publish ? 'Published' : 'Created');
  stderr.write('$verbed version $version\n');

  return version;
}
