import 'dart:math';

class Point2D {
  int _x;

  int get x => _x;
  void set x(int px) => _x = px;

  int _y;

  int get y => _y;
  void set y(int py) => _y = py;

  Point2D(this._x, this._y);

  double distance(Point2D obj) => sqrt(pow(x - obj.x, 2) + pow(y - obj.y, 2));

  double angle(Point2D obj) =>
      atan(this.dot(obj) / (this.internal_product() + obj.internal_product()));

  //double angle(Point2D obj) => atan2(y - obj.y, x - obj.x);

  Point2D operator +(Point2D obj) {
    return Point2D(this.x + obj.x, this.y + obj.y);
  }

  Point2D operator -(Point2D obj) {
    return Point2D(this.x - obj.x, this.y - obj.y);
  }

  Point2D operator *(num obj) {
    return Point2D(
        (this.x.toDouble() * obj).toInt(), (this.y.toDouble() * obj).toInt());
  }

  Point2D operator -() {
    return Point2D(-x, -y);
  }

  double dot(Point2D obj) =>
      x.toDouble() * obj.x.toDouble() + y.toDouble() * obj.y.toDouble();

  double internal_product() => sqrt(this.dot(this));

  void restringe(int v) {
    _x = _x > v ? v : _x;
    _x = _x < -v ? -v : _x;
    _y = _y > v ? v : _y;
    _y = _y < -v ? -v : _y;
  }

  @override
  String toString() => "$_x, $_y";
}

double fixAngle(double a) {
  if (-pi < a) {
    return a + (2 * pi);
  } else if (a > pi) {
    return a - (2 * pi);
  }
  return a;
}

void main() {
  var a = Point2D(0, 0);
  var b = Point2D(1, -10);
  b.restringe(2);
  print(b);
}
