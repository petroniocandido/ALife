import '../Common/Point2D.dart';
import 'dart:math';

final _random = Random();

num eps = 0.00001;

class Boid {
  Point2D _position = Point2D(0, 0);

  Point2D get position => _position;

  void set position(Point2D p) => _position = p;

  Point2D _direction = Point2D(0, 0);

  Point2D get direction => _direction;

  void set direction(Point2D p) => _direction = p;

  int _id = 0;

  int get id => _id;

  Boid(this._id, this._position);

  Point2D operator -(Boid obj) =>
      Point2D(obj.position.x - position.x, obj.position.y - position.y);

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

  var _workingBoids = <Boid>[];

  List<Boid> get workingBoids => _workingBoids;

  int _numBoids = 0;

  int get numBoids => _numBoids;

  var _actions = <BoidAction>[];

  Map<int, Map<int, double>> _distances = {};

  double _momentum = 0.01;

  // Abstract Methods

  void initialize() {
    for (int id = 0; id < numBoids; id++) {
      boids.add(Boid(
          id,
          Point2D(_random.nextInt(shape_dimensions.x),
              _random.nextInt(shape_dimensions.y))));
    }

    _actions.add(coherence);
    _actions.add(separation);
    _actions.add(move);
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

  Boid coherence(Boid obj, BoidSimulation sim) {
    Point2D v = obj.position - sim.swarmMidPoint;
    obj.direction += (v * _momentum);
    return obj;
  }

  Boid separation(Boid obj, BoidSimulation sim) {
    List<Boid> neigh = sim.neighbors(obj);
    for (Boid b in neigh) {
      Point2D v = obj.position - b.position;
      num scale = radius / (v.internal_product() + eps);
      obj.direction -= (v * scale);
    }
    return obj;
  }

  Boid move(Boid obj, BoidSimulation sim) {
    /*obj.direction = fixAngle(obj.direction);
    obj.position.x += (sim.velocity * cos(obj.direction)).toInt();
    obj.position.y += (sim.velocity * sin(obj.direction)).toInt();
    */
    obj.position += obj.direction * _momentum;
    obj = keepBounds(obj);
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

  Boid keepBounds(Boid p) {
    /*if (p.position.x <= 0 ||
        p.position.y <= 0 ||
        p.position.x >= shape_dimensions.x ||
        p.position.y >= shape_dimensions.y) {
      p.direction = 2 * pi - p.direction;
    }

    p.position.x = p.position.x < 0 ? 0 : p.position.x;
    p.position.y = p.position.y < 0 ? 0 : p.position.y;
    p.position.x =
        p.position.x >= shape_dimensions.x ? shape_dimensions.x : p.position.x;
    p.position.y =
        p.position.y >= shape_dimensions.y ? shape_dimensions.y : p.position.y;
*/
    p.position.x = p.position.x < 0 ? shape_dimensions.x : p.position.x;
    p.position.y = p.position.y < 0 ? shape_dimensions.y : p.position.y;
    p.position.x = p.position.x >= shape_dimensions.x ? 0 : p.position.x;
    p.position.y = p.position.y >= shape_dimensions.y ? 0 : p.position.y;

    return p;
  }

/*
  Point2D keepBounds(Point2D p) {
    p.x = p.x < 0 ? p.x + shape_dimensions.x : p.x;
    p.y = p.y < 0 ? p.y + shape_dimensions.y : p.y;
    p.x = p.x > shape_dimensions.x ? p.x - shape_dimensions.x : p.x;
    p.y = p.y > shape_dimensions.y ? p.y - shape_dimensions.y : p.y;
    return p;
  }
*/
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
    _workingBoids = _boids.toList();
    mapDistances();
    _swarmMidPoint = midPoint(boids);
    for (Boid boid in _workingBoids) {
      for (BoidAction func in _actions) {
        boid = func.call(boid, this);
      }
    }
    _boids = _workingBoids.toList();
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