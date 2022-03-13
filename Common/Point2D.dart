import 'dart:math';

class Point2D {
  int _x;

  int get x => _x;
  void set x(int px) => _x = px;

  int _y;

  int get y => _y;
  void set y(int py) => _y = py;

  Point2D(this._x, this._y);

  double distance(Point2D obj) => sqrt((x * obj.x) + (y * obj.y));

  Point2D operator +(Point2D obj) {
    return Point2D(this.x + obj.x, this.y + obj.y);
  }

  Point2D operator -(Point2D obj) {
    return Point2D(this.x - obj.x, this.y - obj.y);
  }

  Point2D operator *(num obj) {
    return Point2D((this.x * obj as int), (this.y * obj as int));
  }
}
