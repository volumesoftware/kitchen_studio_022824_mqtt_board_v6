import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class KeyService {
  KeyService._privateConstructor();
  static final KeyService _instance =
  KeyService._privateConstructor();
  static KeyService get instance => _instance;
  BuildContext? _context;


  addKeyHandler(BuildContext context){
    _context = context;
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  removeHandler(){
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
  }

  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      var _event =  event as KeyDownEvent;
      print(_event.logicalKey);
      if (_event.logicalKey == LogicalKeyboardKey.home) {
        Navigator.of(_context!).pop();
      }
    }
    return false;
  }
}
