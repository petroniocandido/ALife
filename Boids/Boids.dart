import '../Common/Point2D.dart';
import 'dart:math';

final _random = Random();

class Boid {
  Point2D _position = Point2D(0, 0);

  Point2D get position => _position;

  void set position(Point2D p) => _position = p;

  double _direction = 0;

  double get direction => _direction;

  void set direction(double d) => _direction = d;

  int _id = 0;

  int get id => _id;

  Boid(this._id, this._position, this._direction);

  Point2D vector(int length) => Point2D(
      position.x + (length * cos(direction)) as int,
      position.y + (length * sin(direction)) as int);

  @override
  String toString() => "($_position, $_direction)";
}

typedef Boid BoidAction(Boid obj, BoidSimulation sun);

class BoidSimulation {
  Point2D _shape_dimensions = Point2D(0, 0);

  Point2D get shape_dimensions => _shape_dimensions;

  BoidSimulation(this._numBoids, int _x, int _y) {
    _shape_dimensions = Point2D(_x, _y);
  }

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
          Point2D(_random.nextInt(shape_dimensions.x),
              _random.nextInt(shape_dimensions.y)),
          _random.nextDouble()));
    }

    _actions.add(coherence);
    _actions.add(separation);
    _actions.add(move);
  }

  Boid coherence(Boid obj, BoidSimulation sim) {
    double a = obj.position.angle(sim.swarmMidPoint);
    obj.direction = obj.direction + a;
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
    if (mid.internal_product() > 0) {
      double a = obj.position.angle(mid);
      //double da = obj.direction - a;
      obj.direction = obj.direction - a;
    }
    return obj;
  }

  Boid move(Boid obj, BoidSimulation sim) {
    obj.position.x += (sim.velocity * cos(obj.direction)).toInt();
    obj.position.y += (sim.velocity * sin(obj.direction)).toInt();
    obj.position = keepBounds(obj.position);
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

  Point2D keepBounds(Point2D p) {
    p.x = p.x < 0 ? p.x + shape_dimensions.x : p.x;
    p.y = p.y < 0 ? p.y + shape_dimensions.y : p.y;
    p.x = p.x > shape_dimensions.x ? p.x - shape_dimensions.x : p.x;
    p.y = p.y > shape_dimensions.y ? p.y - shape_dimensions.y : p.y;
    return p;
  }

  Point2D midPoint(List<Boid> swarm) {
    num px = 0;
    num py = 0;
    if (swarm.length > 0) {
      for (Boid boid in swarm) {
        px += boid.position.x;
        py += boid.position.y;
      }
      px = px / swarm.length;
      py = py / swarm.length;
    }

    return Point2D(px.toInt(), py.toInt());
  }

  void next() {
    mapDistances();
    _swarmMidPoint = midPoint(boids);
    for (Boid boid in _boids) {
      for (BoidAction func in _actions) {
        boid = func.call(boid, this);
      }
    }
  }
}

void main() {
  var sim = BoidSimulation(3, 10, 10);
  sim.velocity = 2;
  sim.initialize();
  for (int i = 0; i < 1; i++) {
    sim.next();
    var boids = [for (Boid b in sim.boids) b.toString()];
    print(boids);
  }
}
