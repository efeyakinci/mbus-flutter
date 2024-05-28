class BootlegNotifier {
  Function() _onNotify = () {};

  void notify() {
    _onNotify();
  }

  set onNotify(Function() customOnNotify) {
    _onNotify = customOnNotify;
  }
}