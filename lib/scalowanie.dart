import 'package:flutter/material.dart';

class ScaleNotifier with ChangeNotifier {
  double _scale = 1.0;

  double get scale => _scale;

  void setScale(double newScale) {
    _scale = newScale;
    notifyListeners();
  }

  void zoomIn() {
    _scale = (_scale + 0.07).clamp(0.5, 1.28);
    // print("Zoom In: $_scale"); 
    notifyListeners();
  }

  void zoomOut() {
    _scale = (_scale - 0.07).clamp(0.72, 1.10);
    // print("Zoom Out: $_scale"); 
    notifyListeners();
  }
}
