# pubump

A tool for making quick versioned changes to a Dart package.

I found myself often doing this:

```
~/project $ git add ...       # Stage a change.
~/project $ vi pubspec.yaml   # Manually bump version to 1.3.0.
~/project $ vi CHANGELOG.md   # Manually add: "## 1.3.0 \n\n * Fix such and such issue."
~/project $ git commit -m "1.3.0: Fix such-and-such issue."
```

This tool simply does exactly that!

```
~/project $ git add ...       # Stage a change.
~/project $ pubump minor "Fix such-and-such issue."
```

## Usage

```
usage: pubump [--push] [--publish] <major|minor|patch|build> "Changed X, Y, and Z"

  * Updates pubspec.yaml
  * Updates CHANGELOG.md
  * Makes a git commit
  * Runs `git push` (if --push is passed)
  * Runs `pub publish` (if --publish is passed)
```

