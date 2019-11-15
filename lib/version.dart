import './level.dart';

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

