# urogue

A Flutter app to play urogue.

Based on my urogue reboot and Marvin Sanchez' rogue flutter demo:

- https://github.com/earlfogel/UltraRogue
- https://github.com/icedman/rogue_flutter

## About Urogue

Urogue is an old ascii-graphics game developed in the 1980s and 1990s.
It is one of the earliest "Roguelikes", in case you are familiar with that
genre.

For more information, see my [urogue github repository](https://github.com/earlfogel/UltraRogue)

## Changelog

- long-press on arrow icons for shift-movement commands
- double-tap on arrow icons for ctrl-movement commands
- long-press on arrow towards monster to 'f'ight
- double-tap on arrow towards monster to 'F'ight
- hold down movement, etc. icons to repeat
- press '@' to switch between light and dark themes
- press '!' to switch between text and graphical views
- redraw/recenter dungeon after rotating phone
- avoid overlap with phone notches, camera, etc.
- improved status display on small screens
- improved display of screens without map (Inventory, Options, Help, ...)
- fix: reset dungeon/player/pack/bag on restart from tombstone screen
- fix: don't duplicate daemons on restart from tombstone screen
- fix: add escape icon to tombstone screen
- fix: rare bug setting SROGUEOPTS options (make boolean options real booleans)
- fix crash when using sprites
- fix: tombstone screen
- fix: only show player stats on screens where rogue shows them
- fix: modernize urogue code to use function prototypes

## To Do

- find a better tileset (or two) for the graphical view
- support pinch zoom and drag gestures to zoom/unzoom and move visible board
- use joystick tool instead of four arrow icons for movement
  (or tap on board to move to that spot)
- show score at end of game
- make help, genocide and makemon single column when screen is narrow

