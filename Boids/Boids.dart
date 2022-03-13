import '../Common/Point2D.dart';

class Boid {
  Point2D _position = Point2D(0, 0);

  Point2D get position => _position;

  Point2D _direction = Point2D(0, 0);

  Point2D get direction => _direction;
}

class BoidSimulation<T extends Boid> {
  var _boids = <T>[];

  List<T> get boids => _boids;

  int _numBoids = 0;

  int get numBoids => _numBoids;
}
