import 'package:flutter/material.dart';
import 'sprites.dart';
import 'ffibridge.dart';

class Cell {
  String data = '';
  int x = 0;
  int y = 0;
  int sprite = 0;
  Color color = Colors.white;
}

class BoardData extends ChangeNotifier {
  String buffer = '';
  String message = '';
  bool hasMore = false;
  bool hasStats = false;
  bool hasStar = false;
  bool hasStairs = false;
  bool onStairs = false;
  bool useSprites = true;
  bool hasRip = false;
  //bool hasDir = false;
  bool isDarkTheme = true;
  String oldBuffer = '';
  bool oldUseSprites = false;
  bool oldIsDarkTheme = false;
  bool orientationChanged = false;
  var defaultColor = Colors.white;
  Map<String, String> stats = {};
  List<Cell> cells = [];

  Cell player = Cell();

  String getLine(int l) {
    if (buffer.length == 0)
      return '';
    final tmpbuf = StringBuffer('');
    for (int i = 0; i < 80; i++) {
      tmpbuf.write(buffer[l * 80 + i]);
    }
    return tmpbuf.toString();
  }

  String getCol(int c) {
    if (buffer.length == 0)
      return '';
    final tmpbuf = StringBuffer('');
    for (int l = 0; l < 25; l++) {
      tmpbuf.write(buffer[l * 80 + c]);
    }
    return tmpbuf.toString();
  }

  bool isWall(String c, String c2) {
    return c == '-' || c == '|' || c == '+' || (c == '@' && c2 == '|');
  }

  String getCharAt(int y, int x) {
    if (x < 0 || x >= 80) return '?';
    if (y < 0 || y >= 25) return '?';
    return buffer[(y * 80) + x];
  }

  void modifyWeaponTiles() {
    for (int r = 0; r < 25; r++) {
      for (int c = 0; c < 80; c++) {
        int idx = (r * 80) + c;
        String cc = buffer[idx];
        String nc = cc;

        if (cc != ')') {
          continue;
        }

        int wt = FFIBridge.whatThing(r, c);
        switch (wt) {
          case 0: // MACE
          case 21: // CLUB
          case 25: // HAMMER
          case 27: // MORNING STAR
            nc = '6';
            break;
          case 2: // BOW
          case 7: // SLING
          case 9: // CROSSBOW
          case 41: // FOOTBOW
            nc = '4';
            break;
          case 3: // ARROW
          case 8: // DART
          case 10: // BOLT
          case 19: // SILVER ARROW
          case 42: // FOOTBOW BOLT
            nc = '5';
            break;
          case 5: // Rock
            nc = '7';
            break;
          default: // 1 sword
            break;
        }

        if (nc != cc) {
          buffer = buffer.substring(0, idx) + nc + buffer.substring(idx + 1);
        }
      }
    }
  }

  void modifyCornerTiles() {
    for (int r = 0; r < 25; r++) {
      for (int c = 0; c < 80; c++) {
        int idx = (r * 80) + c;
        String cc = buffer[idx];
        String nc = cc;

        if (cc != '-') {
          continue;
        }

        String left = getCharAt(r, c - 1);
        String right = getCharAt(r, c + 1);
        String up = getCharAt(r - 1, c);
        String down = getCharAt(r + 1, c);
        String up2 = getCharAt(r - 2, c);
        String down2 = getCharAt(r + 2, c);

        if (!isWall(left, '|') && isWall(right, '|') && isWall(down, down2)) {
          nc = '0';
        } else if (isWall(left, '|') &&
            !isWall(right, '|') &&
            isWall(down, down2)) {
          nc = '1';
        } else if (!isWall(left, '|') &&
            isWall(right, '|') &&
            isWall(up, up2)) {
          nc = '2';
        } else if (isWall(left, '|') &&
            !isWall(right, '|') &&
            isWall(up, up2)) {
          nc = '3';
        }

        if (nc != cc) {
          buffer = buffer.substring(0, idx) + nc + buffer.substring(idx + 1);
        }
      }
    }
  }

  void parseBuffer(String buf) {
    if (buf == oldBuffer && useSprites == oldUseSprites && isDarkTheme == oldIsDarkTheme
	&& !orientationChanged)
	return;  // nothing changed
    else {
	oldBuffer = buf;
	oldUseSprites = useSprites;
	oldIsDarkTheme = isDarkTheme;
	orientationChanged = false;
    }

    SpriteSheet sheet = SpriteSheet.instance();
    buffer = buf;

    // r.i.p.
    hasRip = buffer.contains('PEACE');

    // parse the message
    message = getLine(0).trim();
    hasMore = buffer.contains('--More--');
    hasStar = message.contains('* for list');
    //hasDir = buffer.contains('Which direction?');
    if (buffer.contains('Press space')) hasMore = true;
    //hasStairs = FFIBridge.foundStairs();
    hasStairs = false;
    for (int y = 1; y < 23; y++) {
	if (getLine(y).contains('%'))
	    hasStairs = true;
    }
    onStairs = FFIBridge.onStairs();
    hasStats = false;
    stats = {};

    // parse status > Level: 1  Gold: 0      Hp: 12(12)  Str: 16(16)  Arm: 4   Exp: 1/0
    String status = getLine(23) + " " + getLine(24);
    RegExp regExp = RegExp(
    //r"(([a-zA-Z]{0,9}):\s{0,8}([0-9()/]{0,9}))",
      r"(([a-zA-Z]{0,9}):\s{0,8}([^ ]+))",
      caseSensitive: false,
      multiLine: false,
    );
    final matches = regExp.allMatches(status);
    for (final m in matches) {
      var g = m.groups([2, 3]);
      if (g.length == 2) {
	RegExp statpat = RegExp(r'^([0-9]+)/([0-9]+)$');
	var match = statpat.firstMatch(g[1] ?? '-');
	if (match != null && match![1] == match![2])	// e.g. Hp: 18/18
	  g[1] = match[1] ?? ' ';		// becomes Hp: 18
        stats[g[0] ?? '-'] = g[1] ?? '';
      }
      hasStats = true;
    }

    // clear the map
    cells.clear();

    // change color based on theme
    defaultColor = Colors.white;
    if (!isDarkTheme) {
	defaultColor = Colors.black;
    }

    if (buffer.length >= 2000) {
      if (!hasRip && useSprites && hasStats) {
        modifyCornerTiles();
        modifyWeaponTiles();
      }

      // start at 1 - skips the message
      // end before 23 - skips the stats
      int start = (hasStats)? 1: 0;
      int end = (hasStats)? 23: 25;
      final isAlpha = RegExp("[a-zA-Z]");
      for (int y = start; y < end; y++) {
        for (int x = 0; x < 80; x++) {
          String c = buffer[y * 80 + x];
          if (c != ' ') {
            Color clr = sheet.colorMap[c] ?? defaultColor;
	    if (!isDarkTheme) {
		if (c == '@' || c == '_' || c == '\'')
		    clr = Colors.yellow.shade600;
	    }
            Cell cell = Cell()
              ..data = c
              ..x = x
              ..y = y
              ..sprite = sheet.tilesetMap[c] ?? 0
              ..color = clr;
	    if (useSprites && hasStats && isAlpha.hasMatch(c)) {
		int mnum = FFIBridge.whichMonst(y, x);
		if (mnum > 0) {
		    // show the right tile
		    cell.sprite = sheet.monstTile[mnum];
		    cell.color = sheet.monstStyle[mnum];
		} else {
		    cell.sprite = 0;
		    //cell.color = defaultColor;
		}
	    }
	    /* is it a trap or a magical item? */
	    if (useSprites && hasStats && "<\$>".contains(c)) {
		int wt = FFIBridge.whichThing(y, x);
		if (wt > 0) {
		    String nc = String.fromCharCode(wt);
		    cell.sprite = sheet.tilesetMap[nc] ?? 0;
		    if (c == '<')
			cell.color = Colors.red;
		    else if (c == '>')
			cell.color = Colors.green;
		    else
			cell.color = Colors.blue;
		} else {
		    int mnum = FFIBridge.whichMonst(y, x);
		    if (mnum > 0) { // monster holding magic item?
			cell.sprite = sheet.monstTile[mnum];
			if (c == '<')
			    cell.color = Colors.red;
			else if (c == '>')
			    cell.color = Colors.green;
			else
			    cell.color = Colors.blue;
		    }
		}
	    }
            cells.add(cell);
            if (c == '@' || c == '_' || c == '\'') {
              player = cell;
            }
          }
        }
      }
    }

    if (hasRip) {
      message = '';
      hasMore = false;
    }

    notifyListeners();
  }
}
