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

  Boid(this._id, this._position, this._direction);

  Point2D operator -(Boid obj) =>
      Point2D(obj.position.x - position.x, obj.position.y - position.y);

  double distance(Boid obj) => position.distance(obj.position);

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

  double _momentum = 0.005;

  double get momentum => _momentum;

  void set momentum(double d) => _momentum = d;

  double _coherence_factor = 1;

  Point2D _avoidance = Point2D(10, 10);

  // Abstract Methods

  void initialize() {
    var dx = shape_dimensions.x ~/ 2;
    var hx = dx ~/ 2;
    var dy = shape_dimensions.y ~/ 2;
    var hy = dy ~/ 2;

    _avoidance.x = shape_dimensions.x ~/ 3;
    _avoidance.y = shape_dimensions.y ~/ 3;

    for (int id = 0; id < numBoids; id++) {
      boids.add(Boid(
          id,
          Point2D(_random.nextInt(dx) + hx, _random.nextInt(dy) + hy),
          Point2D(_random.nextInt(10) - 5, _random.nextInt(10) - 5)));
    }

    _coherence_factor = shape_dimensions.internal_product();

    _actions.add(coherence);
    _actions.add(separation);
    _actions.add(aligment);
    _actions.add(avoidLimits);
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
    obj.direction += v * (v.internal_product() / _coherence_factor) * _momentum;
    return obj;
  }

  Boid separation(Boid obj, BoidSimulation sim) {
    List<Boid> neigh = sim.neighbors(obj);
    for (Boid b in neigh) {
      Point2D v = obj.position - b.position;
      //num scale = 1 - v.internal_product() / radius;
      obj.direction -= v * _momentum; //* scale
    }
/*
    Point2D v = obj.position - midPoint(neigh);
    //num scale = 1 - (v.internal_product() / radius);
    obj.direction -= v;
*/
    return obj;
  }

  Boid aligment(Boid obj, BoidSimulation sim) {
    List<Boid> neigh = sim.neighbors(obj);
    Point2D v = meanVector(neigh);
    obj.direction += v * _momentum;

    return obj;
  }

  Boid avoidLimits(Boid obj, BoidSimulation sim) {
    if (obj.position.x < _avoidance.x) {
      obj.direction.x -= max(_avoidance.x - obj.position.x, 1);
    } else if (obj.position.x > shape_dimensions.x - _avoidance.x) {
      obj.direction.x +=
          max(_avoidance.x - (shape_dimensions.x - obj.position.x), 1);
    }
    if (obj.position.y < _avoidance.y) {
      obj.direction.y -= max(_avoidance.y - obj.position.y, 1);
    } else if (obj.position.y > shape_dimensions.y - _avoidance.y) {
      obj.direction.y +=
          max(_avoidance.y - (shape_dimensions.y - obj.position.y), 1);
    }
    return obj;
  }

  Boid move(Boid obj, BoidSimulation sim) {
    var mod =
        sim.velocity / max(obj.direction.internal_product(), sim.velocity);
    obj.position += obj.direction * mod;

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
        double d = boidA.distance(boidB);
        _distances[i]?[j] = d;
        _distances[j]?[i] = d;
      }
    }
  }

  Boid keepBounds(Boid p) {
    if (p.position.x <= 0 || p.position.x >= shape_dimensions.x) {
      p.direction.x = -p.direction.x;
    }
    if (p.position.y <= 0 || p.position.y >= shape_dimensions.y) {
      p.direction.y = -p.direction.y;
    }
    /*
    p.position.x = p.position.x < 0 ? shape_dimensions.x : p.position.x;
    p.position.y = p.position.y < 0 ? shape_dimensions.y : p.position.y;
    p.position.x = p.position.x >= shape_dimensions.x ? 0 : p.position.x;
    p.position.y = p.position.y >= shape_dimensions.y ? 0 : p.position.y;
    */

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

  Point2D meanVector(List<Boid> swarm) {
    num px = 0;
    num py = 0;
    if (swarm.length > 0) {
      for (Boid boid in swarm) {
        px += boid.direction.x;
        py += boid.direction.y;
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
  for (int i = 0; i < 5; i++) {
    sim.next();
    var boids = [for (Boid b in sim.boids) b.toString()];
    print(boids);
  }
}
