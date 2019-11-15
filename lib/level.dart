enum Level {
  build,
  patch,
  minor,
  major,
}

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
