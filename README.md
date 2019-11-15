# pubump

A tool for making quick versioned changes to a Dart package.

I found myself often doing this:

```
~ $ git add ...      # Stage a change.
~ $ vi pubspec.yaml  # Manually bump version to 1.3.0.
~ $ vi CHANGELOG.md  # Manually add "## 1.3.0 \n\n * Fix this and that"
~ $ git commit -m "1.3.0: Fix this and that"
```

This tool automates exactly those steps.

```
~ $ git add ...      # Stage a change.
~ $ pubump minor "Fix this and that"
```

## Installing

Clone this repository, then put `alias pubump=/path/to/pubump/bin/main.dart` in your .bashrc (or equivalent).

pubump needs the [Dart VM](https://dart.dev/tools/dart-vm) to run.

## Usage

```
pubump [--push] [--publish] <major|minor|patch|build> "Changed X, Y, and Z"

  * Updates pubspec.yaml
  * Updates CHANGELOG.md
  * Makes a git commit
  * Runs `git push` (if -g or --push is passed)
  * Runs `pub publish` (if -p or --publish is passed)
```