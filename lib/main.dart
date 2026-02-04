import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'board.dart';
import 'input.dart';
import 'sprites.dart';
import 'ffibridge.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FFIBridge.initialize();
  FFIBridge.initApp();
  FFIBridge.pushKey(' ');

  BoardData board = BoardData();

  Widget app = MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => board),
    ChangeNotifierProvider(
         create: (context) => ThemeProvider(),
	 )
  ], child: Game());

  runApp(app);
}

class Game extends StatelessWidget {
  const Game({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      home: const GameView(),
    );
  }
}

class GameMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BoardData board = Provider.of<BoardData>(context);

    Size screen = MediaQuery.sizeOf(context);
    RenderObject? obj = context.findRenderObject();
    if (obj != null) {
      RenderBox? box = obj as RenderBox;
      screen = box.size;
    }

    // map
    Size size = SpriteSheet.instance().size;
    //board.useSprites = true;
    if (!board.useSprites || !board.hasStats) {
	size = Size(12, 16);
	if (Platform.isAndroid && board.hasStats)
	    size = Size(14,18);
    }

    Offset playerXY =
        Offset(board.player.x * size.width, (board.player.y - 2) * size.height);

    /* Special screens, e.g. inventory, help, options */
    if (!board.hasStats && board.buffer.length >= 3200) {
      int first_row=-1, last_row=-1, first_col=-1, last_col=-1;
      for (int i = 0; i < 25; i++) {
	String line = board.getLine(i).trim();
	if (line.length > 0) {
	  if (first_row < 0) {
	    first_row = i;
	  }
	  last_row = i;
	}
      }
      for (int i = 0; i < 80; i++) {
	String col = board.getCol(i).trim();
	if (col.length > 0) {
	  if (first_col < 0) {
	    first_col = i;
	  }
	  last_col = i;
	}
      }
      /* center, if there's room, otherwise left/top justify */
      if (first_row > -1 && first_row <= last_row
	  && first_col > -1 && first_col <= last_col) {
	int centerX = (first_col + last_col) ~/ 2;
	int centerY = (first_row + last_row) ~/ 2;
	if (screen.width / size.width < last_col - first_col)
	    centerX = first_col + (screen.width ~/ (size.width * 2));
	if ((screen.height - 40) / size.height < last_row - first_row)
	    centerY = first_row + ((screen.height - 40) ~/ (size.height * 2));
	playerXY = Offset(centerX * size.width, centerY * size.height);
      }
    }

    Offset center =
        Offset(screen.width / 2 - playerXY.dx, screen.height / 2 - playerXY.dy);

    List<Widget> map = [];
    for (final c in board.cells) {
	map.add(Positioned(
          top: center.dy + (size.height * (c.y - 2)),
          left: center.dx + (size.width * c.x),
          child: (board.hasStats && board.useSprites && (Sprite(cell: c) != null))?
	    Sprite(cell: c):
	    Text(c.data, style: TextStyle(fontSize: size.width))));
    }

    return Stack(children: map);
  }
}

class GameView extends StatefulWidget {
  const GameView({Key? key}) : super(key: key);

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  void _updateScreen() {
    String buffer = FFIBridge.getScreenBuffer();
    BoardData data = Provider.of<BoardData>(context, listen: false);
    data.parseBuffer(buffer);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _updateScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    BoardData board = Provider.of<BoardData>(context);

    // stats
    double fontSize = (Platform.isAndroid ? 12 : 20);
    TextStyle statStyle = TextStyle(
        // fontFamily: 'PixelFont',
        fontSize: fontSize,
        fontWeight: FontWeight.bold);
    List<Widget> stats = [];
    for (final k in board.stats.keys) {
      String v = board.stats[k] ?? '';
      if (stats.isNotEmpty) {
        stats.add(Expanded(child: Container()));
      }
      stats.add(Row(children: [
        Text((k != "Player")? '$k: ': '', style: statStyle),
        Text('$v  ', style: statStyle)
      ]));
    }

    if (board.hasRip || !board.hasStats) {
      stats = [];
    }

    // commands
    List<InputTool> commands = [
      InputTool(icon: Icons.arrow_back, title: 'Left', cmd: 'h'),
      InputTool(icon: Icons.arrow_downward, title: 'Down', cmd: 'j'),
      InputTool(icon: Icons.arrow_upward, title: 'Up', cmd: 'k'),
      InputTool(icon: Icons.arrow_forward, title: 'Right', cmd: 'l'),
      InputTool(icon: Icons.update, title: 'Rest', cmd: '.'),
      InputTool(icon: Icons.keyboard_arrow_up, title: 'Up stairs', cmd: '<'),
      InputTool(icon: Icons.keyboard_arrow_down, title: 'Down stairs', cmd: '>'),
      InputTool(icon: Icons.space_bar, title: 'Space', cmd: ' '),
      InputTool(icon: Icons.cancel_outlined, title: 'Escape', cmd: '\x1b'),
    ];

    if (board.hasRip) {
      commands = [
        InputTool(icon: Icons.cancel_outlined, title: 'Escape', cmd: '\x1b'),
        InputTool(icon: Icons.play_arrow, title: 'Left', cmd: '',
            onPressed: () {
              FFIBridge.restartApp();
              Future.delayed(const Duration(milliseconds: 500), _updateScreen);
            }),
      ];
    }

    TextStyle messageStyle = const TextStyle(
        fontSize: 18, fontStyle: FontStyle.italic);

    return Scaffold(
        body: OrientationBuilder(
        builder: (context, orientation) {
	    Future.delayed(const Duration(milliseconds: 50), _updateScreen);
	    return SafeArea(
	    child: InputListener(
      toolbar: commands,
      showToolbar: true,
      child: Column(children: [
        // stats
	Row(children: stats),

        // map
        Expanded(child: GameMap()),

	// messages
        Text((board.hasStats)? board.message: "", style: messageStyle),
      ]),
      onKeyDown: (String key,
          {int keyId = 0,
          bool shift = false,
          bool control = false,
          bool softKeyboard = false}) {
        int k = keyId;
        if (
	    (k >= LogicalKeyboardKey.keyA.keyId &&
		k <= LogicalKeyboardKey.keyZ.keyId) ||
            (k + 32 >= LogicalKeyboardKey.keyA.keyId &&
                k + 32 <= LogicalKeyboardKey.keyZ.keyId)) {
	  if (shift) {
	      key = String.fromCharCode(65 + k - LogicalKeyboardKey.keyA.keyId);
	  } else if (control) {
	      key = String.fromCharCode(1 + k - LogicalKeyboardKey.keyA.keyId);
	  } else {
	      key = String.fromCharCode(97 + k - LogicalKeyboardKey.keyA.keyId);
	  }
        }
	if (shift && k == LogicalKeyboardKey.digit1.keyId)
	    key = '!';
	if (shift && k == LogicalKeyboardKey.digit2.keyId)
	    key = '@';
	if (shift && k == LogicalKeyboardKey.digit3.keyId)
	    key = '#';
	if (shift && k == LogicalKeyboardKey.digit4.keyId)
	    key = '\$';
	if (shift && k == LogicalKeyboardKey.digit5.keyId)
	    key = '%';
	if (shift && k == LogicalKeyboardKey.digit6.keyId)
	    key = '^';
	if (shift && k == LogicalKeyboardKey.digit7.keyId)
	    key = '&';
	if (shift && k == LogicalKeyboardKey.digit8.keyId)
	    key = '*';
	if (shift && k == LogicalKeyboardKey.digit9.keyId)
	    key = '(';
	if (shift && k == LogicalKeyboardKey.digit0.keyId)
	    key = ')';

        String s = key;

        switch (key) {
          case 'Arrow Up':
            s = 'k';
	    if (shift) { s = 'K'; }
	    if (control) { s = String.fromCharCode(11); }
            break;
          case 'Arrow Down':
            s = 'j';
	    if (shift) { s = 'J'; }
	    if (control) { s = String.fromCharCode(10); }
            break;
          case 'Arrow Left':
            s = 'h';
	    if (shift) { s = 'H'; }
	    if (control) { s = String.fromCharCode(8); }
            break;
          case 'Arrow Right':
            s = 'l';
	    if (shift) { s = 'L'; }
	    if (control) { s = String.fromCharCode(12); }
            break;
          case 'Space':
            s = ' ';
            break;
          case 'Escape':
            s = '\x1b';
            break;
          case 'Enter':
            s = '\n';
            break;
          case 'Shift Left':
          case 'Shift Right':
          case 'Control Left':
          case 'Control Right':
            break;
          default:
            if (key.length > 1) {
              print(key);
            }
            break;
        }

	if (s == '!') {
	    board.useSprites = !board.useSprites;
	    if (board.useSprites) {
	      Provider.of<ThemeProvider>(context, listen: false).darkTheme(context);
	      board.isDarkTheme = true;
	    } else {
	      Provider.of<ThemeProvider>(context, listen: false).toggleTheme(context);
	      board.isDarkTheme = !board.isDarkTheme;
	    }
	    s = '';
	}

	if (s == '@') {
	  if (!board.useSprites) {
	    Provider.of<ThemeProvider>(context, listen: false).toggleTheme(context);
if (Provider.of<ThemeProvider>(context, listen: false).isDarkTheme(context)) {
    board.isDarkTheme = true;
} else {
    board.isDarkTheme = false;
}
	  }
	    s = '';
	}

        if (s.length == 1) {
          FFIBridge.pushKey(s);
        }
        Future.delayed(const Duration(milliseconds: 50), _updateScreen);
      },
    ));}));
  }
}

//final systemTheme = ThemeMode.system;

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      background: Color.fromARGB(255, 215, 165, 187),
      secondary: Color.fromARGB(255, 215, 165, 187),
    ));

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      background: Colors.grey.shade900,
      secondary: Color.fromARGB(255, 52, 52, 47),
    ));

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void darkTheme(BuildContext context) {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }
  void lightTheme(BuildContext context) {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }
  void toggleTheme(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }
  bool isDarkTheme(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return false;
    } else {
      return true;
    }
  }
}
