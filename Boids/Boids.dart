import '../Common/Point2D.dart';
import 'dart:math';

final _random = Random();

class Boid {
  Point2D _position = Point2D(0, 0);

  Point2D get position => _position;

  double _direction = 0;

  double get direction => _direction;

  void set direction(double d) => _direction = d;

  int _id = 0;

  int get id => _id;

  Boid(this._id, this._position, this._direction);
}

typedef Boid BoidAction(Boid obj, BoidSimulation sun);

class BoidSimulation {
  List<int> _shape_dimensions = [];

  List<int> get shape_dimensions => _shape_dimensions;

  int _velocity = 1;

  int get velocity => _velocity;

  void set velocity(int v) => _velocity = v;

  double _radius = 2.0;

  double get radius => _radius;

  void set radius(double r) => _radius = r;

  Point2D _swarmMidPoint = Point2D(0, 0);

  Point2D get swarmMidPoint => _swarmMidPoint;

  var _boids = <Boid>[];

  List<Boid> get boids => _boids;

  int _numBoids = 0;

  int get numBoids => _numBoids;

  var _actions = <BoidAction>[];

  Map<int, Map<int, double>> _distances = {};

  // Abstract Methods

  void initialize() {
    for (int id = 0; id < numBoids; id++) {
      boids.add(Boid(
          id,
          Point2D(_random.nextInt(shape_dimensions[0]),
              _random.nextInt(shape_dimensions[1])),
          (4 * pi * _random.nextDouble()) - 2 * pi));
    }

    _actions.add(coherence);
    _actions.add(separation);
    _actions.add(move);
  }

  Boid coherence(Boid obj, BoidSimulation sim) {
    double a = obj.position.angle(sim.swarmMidPoint);
    double da = obj.direction - a;
    obj.direction += da;
    return obj;
  }

  List<Boid> neighbors(Boid boid) {
    List<Boid> ix = [];
    for (int j = 0; j < boids.length; j++) {
      if (j != boid.id && (_distances[boid.id]?[j] ?? 0) <= radius) {
        ix.add(boids[j]);
      }
    }
    return ix;
  }

  Boid separation(Boid obj, BoidSimulation sim) {
    List<Boid> neigh = sim.neighbors(obj);
    Point2D mid = sim.midPoint(neigh);
    double a = obj.position.angle(mid);
    double da = obj.direction - a;
    obj.direction += -da;
    return obj;
  }

  Boid move(Boid obj, BoidSimulation sim) {
    List<Boid> neigh = sim.neighbors(obj);
    Point2D mid = sim.midPoint(neigh);
    double a = obj.position.angle(mid);
    double da = obj.direction - a;
    obj.direction += -da;
    return obj;
  }

  // Concrete Methods

  void mapDistances() {
    for (int i = 0; i < boids.length; i++) {
      var boidA = boids[i];
      _distances[boids[i].id] = {};
      _distances[i]?[i] = -1;
      for (int j = i + 1; j < boids.length; j++) {
        var boidB = boids[j];
        double d = boidA.position.distance(boidB.position);
        _distances[i]?[j] = d;
        _distances[j]?[i] = d;
      }
    }
  }

  Point2D midPoint(List<Boid> swarm) {
    int px = 0;
    int py = 0;
    for (Boid boid in swarm) {
      px += boid.position.x;
      py += boid.position.y;
    }
    px = (px / swarm.length) as int;
    py = (py / swarm.length) as int;

    return Point2D(px, py);
  }

  void next() {
    for (Boid boid in _boids) {
      for (BoidAction func in _actions) {
        func.call(boid, this);
      }
    }
  }
}
