import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'board.dart';

class CustomEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    return const TextSpan();
  }
}

class InputTool {
  InputTool(
      {IconData? this.icon,
      String this.title = '',
      String this.cmd = '',
      Color this.color = Colors.white,
      Function? this.onPressed});

  IconData? icon;
  String title = '';
  String cmd = '';
  Color color = Colors.white;
  Function? onPressed;
}

class InputListener extends StatefulWidget {
  late Widget child;
  Function? onKeyDown;
  Function? onKeyUp;
  Function? onTapDown;
  Function? onDoubleTapDown;
  Function? onPanUpdate;

  bool showToolbar = false;
  List<InputTool> toolbar = [];

  InputListener(
      {required Widget this.child,
      Function? this.onKeyDown,
      Function? this.onKeyUp,
      Function? this.onTapDown,
      Function? this.onDoubleTapDown,
      Function? this.onPanUpdate,
      bool this.showToolbar = false,
      List<InputTool> this.toolbar = const []});
  @override
  _InputListener createState() => _InputListener();
}

class _InputListener extends State<InputListener> {
  late FocusNode focusNode;
  late FocusNode textFocusNode;
  late TextEditingController controller;
  late ScrollController hscroller;

  bool showKeyboard = false;
  Offset lastTap = const Offset(0, 0);
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    textFocusNode = FocusNode();
    controller = CustomEditingController();

    controller.addListener(() {
      final t = controller.text;
      if (t.isNotEmpty) {
        widget.onKeyDown?.call(t,
            keyId: 0, shift: false, control: false, softKeyboard: true);
      }
      controller.text = '';
    });

    hscroller = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    textFocusNode.dispose();
    controller.dispose();
    hscroller.dispose();
  }

  /*
   * Is the player about to longPress into a monster?
   */
  bool hasMonst(String cmd) {
    BoardData board = Provider.of<BoardData>(context, listen: false);
    final pattern = RegExp("[a-zA-Z]");
    String c;
    int x = board.player.x;
    int y = board.player.y;
    if (board.hasMore)
	return false;
    if ("hjkl".contains(cmd)) { // check direction of travel
	if (cmd == 'h')
	  c = board.getCharAt(y, x - 1);
	else if (cmd == 'j')
	  c = board.getCharAt(y + 1, x);
	else if (cmd == 'k')
	  c = board.getCharAt(y - 1, x);
	else
	  c = board.getCharAt(y, x + 1);
	if (pattern.hasMatch(c))
	  return true;
    } else {  // check all directions
	c = board.getCharAt(y, x - 1);  // h
	if (pattern.hasMatch(c))
	  return true;
	c = board.getCharAt(y + 1, x);  // j
	if (pattern.hasMatch(c))
	  return true;
	c = board.getCharAt(y - 1, x);  // k
	if (pattern.hasMatch(c))
	  return true;
	c = board.getCharAt(y, x + 1);  // l
	if (pattern.hasMatch(c))
	  return true;
    }
    return false;
  }

  int delay = 500;

  void LongPressAction(InputTool t) {
    BoardData board = Provider.of<BoardData>(context, listen: false);
    if (_isPressed) {
      if ("hjkl".contains(t.cmd)) {
	if (board.hasMore)
	  widget.onKeyDown?.call(' ');
	else if (hasMonst(t.cmd)) {
	  if (delay > 250)
	    delay -= 50; // speed up long fights
	  widget.onKeyDown?.call(t.cmd.toUpperCase());  // Fight
	} else if (delay < 300) // a long fight just ended
	  widget.onKeyDown?.call(t.cmd);
	else
	  widget.onKeyDown?.call(t.cmd.toUpperCase());  // Run
      } else {
	widget.onKeyDown?.call(t.cmd);
      }
      if (t.cmd == '.') {  // Rest
	if (hasMonst(t.cmd))
	  delay = 500;  // reset if a monster arrives
	else
	  delay = 200; // speed up long rests
      } else if (!hasMonst(t.cmd)) {
	delay = 500;  // reset after a fight
      }
      //t.onPressed?.call();
      if (_isPressed) {
	Future.delayed(Duration(milliseconds: delay), () {
	  if (_isPressed)
	    LongPressAction(t);
	});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    BoardData board = Provider.of<BoardData>(context, listen: false);
    double iconSize = 28.0;
    return Focus(
        onFocusChange: (focused) {
          // if (focused && !textFocusNode.hasFocus) {
          //   textFocusNode.requestFocus();
          // }
        },
        child: Column(children: [
          Expanded(
              child: GestureDetector(
                  child: widget.child,
		  )),

          if (/* Platform.isAndroid || */ widget.showToolbar) ...[
            SingleChildScrollView(
          controller: hscroller,
          scrollDirection: Axis.horizontal,
                child: Row(children: [
              IconButton(
                  icon:
                      Icon(Icons.keyboard, size: iconSize),
                  onPressed: () {
                    setState(() {
                      showKeyboard = !showKeyboard;
                      if (showKeyboard) {
                        Future.delayed(Duration(milliseconds: 50), () {
                          textFocusNode.requestFocus();
                        });
                      }
                    });
                  }),
              ...(widget.toolbar.map((t) =>
		GestureDetector(
		    // use IconButton for onPressed events
		    // and Gesture detector for the rest
		    child: IconButton(
                    icon: Icon(t.icon, size: iconSize, color: t.color),
		    //tooltip: t.title,
                    onPressed: () {
		      if (t.cmd.length > 0) {
			if (board.hasMore)
			  widget.onKeyDown?.call(' ');
			else if ("hjkl".contains(t.cmd) && board.hasStar)
			  widget.onKeyDown?.call('*');
			else if (t.cmd == '.')
			  widget.onKeyDown?.call('s');  // search instead
			else
			  widget.onKeyDown?.call(t.cmd);
		      }
		      t.onPressed?.call();
                    },
		    ),
                    onLongPress: () {
		      _isPressed = true;
		      delay = 500;
		      LongPressAction(t);
                    },
                    onDoubleTap: () {
//		      if (hasMonst(t.cmd))
//			  widget.onKeyDown?.call('f');
//		      else
		      if (t.cmd == 'h')
			widget.onKeyDown?.call(String.fromCharCode(8));
		      else if (t.cmd == 'j')
			widget.onKeyDown?.call(String.fromCharCode(10));
		      else if (t.cmd == 'k')
			widget.onKeyDown?.call(String.fromCharCode(11));
		      else if (t.cmd == 'l')
			widget.onKeyDown?.call(String.fromCharCode(12));
                      t.onPressed?.call();
                    },
                    onLongPressEnd: (details) {
                      _isPressed = false;
                    },
                    onTapUp: (details) {
                      _isPressed = false;
                    },
                    onTapCancel: () {
                      _isPressed = false;
                    },
		  )
                  ))
            ]))
          ], // toolbar

          Container(
              width: 1,
              height: 1,
              child: !showKeyboard
                  ? null
                  : TextField(
                      focusNode: textFocusNode,
                      autofocus: true,
                      maxLines: null,
                      enableInteractiveSelection: false,
		      //enableSuggestions: false,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      controller: controller))
        ]),
        focusNode: focusNode,
        autofocus: true,
        onKey: (FocusNode node, RawKeyEvent event) {
          // if (textFocusNode.hasFocus) {
          //   return KeyEventResult.ignored;
          // }
          if (event.runtimeType.toString() == 'RawKeyUpEvent') {
            widget.onKeyDown?.call(event.logicalKey.keyLabel,
                keyId: event.logicalKey.keyId,
                shift: event.isShiftPressed,
                control: event.isControlPressed);
          }
          // if (event.runtimeType.toString() == 'RawKeyUpEvent') {
          //   widget.onKeyUp?.call();
          // }
          return KeyEventResult.handled;
        });
  }
}
