import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CursorPosition{
  final double x;
  final double y;
  CursorPosition(this.x, this.y);
}

class PositionedCursor extends StatefulWidget {

  final ValueChanged<CursorPosition> onChanged;

  const PositionedCursor({super.key, required this.onChanged});

  @override
  State<PositionedCursor> createState() => _PositionedCursorState();
}

class _PositionedCursorState extends State<PositionedCursor> {
  final GlobalKey _avatar = GlobalKey();
  IconData icon = Icons.arrow_upward;
  int DPI = 15;

  double X = 0;
  double Y = 0;

  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onChanged(CursorPosition(X, Y));

    });

    ServicesBinding.instance.keyboard.addHandler(_onKey);
    super.initState();
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    _avatar.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(

      duration: Duration(milliseconds: 10),
      startDelay: Duration.zero,
      showTwoGlows: true,
      glowColor: Colors.red,
      key: _avatar,
      endRadius: 20,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50), color: Colors.red),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }

  bool _onKey(KeyEvent event) {
    final key = event.logicalKey.keyLabel;

    if (event is KeyUpEvent) {
      setState(() {
        icon = Icons.arrow_upward;
      });
    }
    if (event is KeyRepeatEvent || event is RawKeyDownEvent || event is KeyDownEvent) {
      print("CURSOR $key");
      switch (key) {
        case "Numpad 6":
          {
            setState(() {
              X = X + DPI;
              icon = Icons.arrow_forward;
            });

            break;
          }
        case "Numpad 4":
          {
            setState(() {
              X = X - DPI;
              icon = Icons.arrow_back_sharp;
            });

            break;
          }
        case "Numpad 8":
          {
            setState(() {
              Y = Y - DPI;
              icon = Icons.arrow_upward;
            });

            break;
          }
        case "Numpad 2":
          {
            setState(() {
              Y = Y + DPI;
              icon = Icons.arrow_downward;
            });

            break;
          }
        case "Numpad 5":
          {
            simulateClicking(_avatar);
            break;
          }
      }

      widget.onChanged(CursorPosition(X, Y));

    }
    return false;
  }

  Future<void> simulateClicking(GlobalKey key) async {
    try {
      final RenderObject? renderObj = key.currentContext?.findRenderObject();
      RenderBox renderbox = renderObj as RenderBox;
      Offset position = renderbox.localToGlobal(Offset.zero);
      double x = position.dx;
      double y = position.dy;

      GestureBinding.instance.handlePointerEvent(PointerDownEvent(
            position: Offset(x, y),
          ));
      //trigger button up,
      await Future.delayed(const Duration(milliseconds: 50));
      GestureBinding.instance.handlePointerEvent(PointerUpEvent(
            position: Offset(x, y),
          ));
    } catch (e) {
      print(e);
    }
  }
}
