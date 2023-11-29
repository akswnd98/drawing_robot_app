class PainterSize {
  static final PainterSize _instance = PainterSize._privateConstructor();
  factory PainterSize() {
    return _instance;
  }
  PainterSize._privateConstructor();
  static List<double>? _size;
  void setSize(List<double> size) {
    _size = size;
  }

  List<double> getSize() {
    if (_size == null) {
      throw Exception('no painter size');
    }
    return _size!;
  }
}
