import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

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
      Function? this.onPressed});

  IconData? icon;
  String title = '';
  String cmd = '';
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

  @override
  Widget build(BuildContext context) {
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
/*
                  onTapUp: (TapUpDetails details) {
                    lastTap = details.globalPosition;
                  },
                  onTapDown: (TapDownDetails details) {
                    // if (!focusNode.hasFocus) {
                    //   focusNode.requestFocus();
                    //   textFocusNode.unfocus();
                    //   FocusScope.of(context).unfocus();
                    // }
                    // if (!textFocusNode.hasFocus) {
                    //   textFocusNode.requestFocus();
                    // }
                    widget.onTapDown?.call(
                        context.findRenderObject(), details.globalPosition);
                  },
                  onDoubleTap: () {
                    widget.onDoubleTapDown
                        ?.call(context.findRenderObject(), lastTap);
                  },
                  onPanUpdate: (DragUpdateDetails details) {
                    widget.onPanUpdate?.call(
                        context.findRenderObject(), details.globalPosition);
                  },
                  onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
                    widget.onPanUpdate?.call(
                        context.findRenderObject(), details.globalPosition);
                  }
*/
		  )),

          if (Platform.isAndroid || widget.showToolbar) ...[
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
	      MaterialApp(
	        debugShowCheckedModeBanner: false,
		home: GestureDetector(
//		    onTap: () {
//print("tap: " + t.cmd);
//		    },
/* the onTap above doesn't work, so instead IconButton handles onPressed
   events and Gesture detector handles the rest */
		    child: IconButton(
                    icon: Icon(t.icon, size: iconSize),
		    //tooltip: t.title,
                    onPressed: () {
//print("press: " + t.cmd);
                      if (t.cmd.length > 0) {
                        widget.onKeyDown?.call(t.cmd);
                      }
                      t.onPressed?.call();
                    },
		    ),
                    onLongPress: () {
//print("Long press: " + t.cmd);
                      if (t.cmd == 'h') {
                        widget.onKeyDown?.call('H');
                      } else if (t.cmd == 'j') {
                        widget.onKeyDown?.call('J');
                      } else if (t.cmd == 'k') {
                        widget.onKeyDown?.call('K');
                      } else if (t.cmd == 'l') {
                        widget.onKeyDown?.call('L');
                      }
                      t.onPressed?.call();
                    },
                    onDoubleTap: () {
//print("Double tap: " + t.cmd);
                      if (t.cmd == 'h') {
                        widget.onKeyDown?.call(String.fromCharCode(8));
                      } else if (t.cmd == 'j') {
                        widget.onKeyDown?.call(String.fromCharCode(10));
                      } else if (t.cmd == 'k') {
                        widget.onKeyDown?.call(String.fromCharCode(11));
                      } else if (t.cmd == 'l') {
                        widget.onKeyDown?.call(String.fromCharCode(12));
                      }
                      t.onPressed?.call();
                    },
		  )
                  )))
            ]))
          ], // toolbar

          Container(
              width: 1,
              height: 3,
              child: !showKeyboard
                  ? null
                  : TextField(
                      focusNode: textFocusNode,
                      autofocus: true,
                      maxLines: null,
                      enableInteractiveSelection: false,
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
