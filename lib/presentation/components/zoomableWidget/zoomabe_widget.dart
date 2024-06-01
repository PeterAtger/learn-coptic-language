import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

class ZoomableWidget extends StatefulWidget {
  final Widget child;

  const ZoomableWidget({Key? key, required this.child}) : super(key: key);
  @override
  _ZoomableWidgetState createState() => _ZoomableWidgetState();
}

class _ZoomableWidgetState extends State<ZoomableWidget> {
  double _scale = 1.0;
  late double _previousScale;
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          _previousScale = _scale;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            _scale = _previousScale * details.scale;
          });
        },
        onScaleEnd: (ScaleEndDetails details) {
          _previousScale = 0;
        },
        child: Transform(
          transform: Matrix4.diagonal3(Vector3(_scale.clamp(1.0, 5.0),
              _scale.clamp(1.0, 5.0), _scale.clamp(1.0, 5.0))),
          alignment: FractionalOffset.center,
          child: widget.child,
        ),
      ),
    );
  }
}
