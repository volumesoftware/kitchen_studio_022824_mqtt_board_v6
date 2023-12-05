class UserAction {
  final String? _title;
  final String? _message;
  final int? _currentIndex;

  UserAction(this._title, this._message, this._currentIndex);

  String? get title => _title;

  String? get message => _message;

  int? get currentIndex => _currentIndex;

  @override
  String toString() {
    return '{'
        '"title" : $title,'
        '"message" : $message,'
        '"currentIndex" : $currentIndex'
        '}';
  }
}
