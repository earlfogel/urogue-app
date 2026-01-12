# urogue

A Flutter app to play urogue.

Based on Marvin Sanchez rogue flutter demo:
- https://github.com/icedman/rogue_flutter

## To Do

- redraw/recenter dungeon after rotating phone
- support pinch zoom and drag gestures to zoom/unzoom and move visible board
- use joystick tool instead of four arrow icons for movement
  (or tap on board to move to that spot)
- fix crash when using sprites
- switch between text and graphical views
- show score at end of game
- press <space> to choose a random character class
  (or use arrow keys?)

## Changelog

- double-tap arrow icons for <ctrl>-movement commands
- fix: tombstone screen
- fix: don't show stats on screens without them
- left-justify board if player not visible (Inventory, Options, Help screens)
- long-tap arrow icons for <shift>-movement commands
- support for light and dark themes
- switch to text view since sprites are broken
- support more shift and control commands

## Flutter Help

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
