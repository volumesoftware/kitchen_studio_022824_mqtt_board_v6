import 'dart:async';

class GlobalLoaderService {

  GlobalLoaderService._privateConstructor();
  static final GlobalLoaderService _instance =
  GlobalLoaderService._privateConstructor();
  static GlobalLoaderService get instance => _instance;
  StreamController<bool> _loaderStateChange = StreamController<bool>.broadcast();
  Stream<bool> get loaderState => _loaderStateChange.stream;
  bool _show = false;

  bool get show => _show;

  set show(bool value) {
    _show = value;
  }

  void showLoading(){
    _loaderStateChange.sink.add(true);
    _show = true;
  }

  void hideLoading(){
    _loaderStateChange.sink.add(false);
    _show = false;
  }


}