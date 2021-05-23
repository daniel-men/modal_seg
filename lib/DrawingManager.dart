  enum InteractionMode {
    PAN,
    ZOOM,
    DRAW
  }


class DrawingManager {


  static final DrawingManager _drawingManager = DrawingManager._internal();
    // Drawing options
  bool _panEnabled = true;
  bool _zoomEnabled = false;
  bool _drawingEnabled = false;

  bool? _closeShape = false;
  double? _strokeWidth = 2.0;
  bool? _straightLine = false;
  String _drawingMode = "Line";

  late Function? update;

  InteractionMode _currentMode = InteractionMode.PAN;

  set closeShape(bool? value) => this._closeShape = value;
  bool get closeShape => this._closeShape == null ? false : this._closeShape!;

  set strokeWidth(double? value) => this._strokeWidth = value;
  double get strokeWidth => this._strokeWidth == null ? 1.0 : this._strokeWidth!;

  set straightLine(bool? value) => this._straightLine = value;
  bool get straightLine => this._straightLine == null ? false : this._straightLine!;

  set drawingMode(String mode) => this._drawingMode = mode;
  String get drawingMode => this._drawingMode;

  bool get panEnabled => this._panEnabled;
  bool get zoomEnabled => this._zoomEnabled;
  bool get drawingEnabled => this._drawingEnabled;


  factory DrawingManager({Function? update}) {
    return _drawingManager;
  }

  DrawingManager._internal();

  void enablePanMode() {
    _panEnabled = true;
    _zoomEnabled = false;
    _drawingEnabled = false;
    _currentMode = InteractionMode.PAN;
    update!();
  }

  void enableDrawMode() {
    _panEnabled = false;
    _zoomEnabled = false;
    _drawingEnabled = true;
    _currentMode = InteractionMode.DRAW;
    update!();
  }

  void enableZoomMode() {
    _panEnabled = false;
    _zoomEnabled = true;
    _drawingEnabled = false;
    _currentMode = InteractionMode.ZOOM;
    update!();
  }

  int currentInteractionMode() => _currentMode.index;

}
