import 'dart:html';
import 'dart:convert';
import 'dart:math';
import 'dart:async';

//import 'CellularAutomata.dart';
import '../../Boids/Boids.dart';

final _random = Random();

num animation_request_id = 0;

BoidSimulation simulation = BoidSimulation(100, 0, 0);

Map<String, dynamic> rules = {};

void main() {
  querySelector("#num_boids")?.onChange.listen((event) {
    changeLabel("num_boids", "lbl_num_boids");
  });

  querySelector("#velocity")?.onChange.listen((event) {
    changeLabel("velocity", "lbl_velocity");
  });

  querySelector("#momentum")?.onChange.listen((event) {
    changeLabel("momentum", "lbl_momentum");
  });

  querySelector("#radius")?.onChange.listen((event) {
    changeLabel("radius", "lbl_radius");
  });

  querySelector("#run_boids")?.onClick.listen((event) {
    boids_start(event);
  });

  querySelector("#stop_boids")?.onClick.listen((event) {
    stop_simulation(event);
  });
}

void changeLabel(String id_input, String id_output) {
  querySelector("#$id_output")?.text =
      (querySelector("#$id_input") as InputElement?)?.value;
}

void stop_simulation(MouseEvent event) {
  window.cancelAnimationFrame(animation_request_id as int);
}

void boids_start(MouseEvent event) {
  var canvas = querySelector("#canvas") as CanvasElement?;
  int canvasWidth = canvas?.width ?? 100;
  int canvasHeight = canvas?.height ?? 100;

  var num_boids = querySelector("#num_boids") as InputElement?;
  int n = int.parse(num_boids?.value ?? "100");

  simulation = BoidSimulation(n, canvasWidth * 3, canvasHeight * 3);

  var momentum = querySelector("#momentum") as InputElement?;

  simulation.momentum = int.parse(momentum?.value ?? "0") / 1000;

  var velocity = querySelector("#velocity") as InputElement?;

  simulation.velocity = int.parse(velocity?.value ?? "5");

  var radius = querySelector("#radius") as InputElement?;

  simulation.radius = double.parse(radius?.value ?? "20");

  simulation.initialize();

  window.requestAnimationFrame(boids_animation);
}

void boids_animation(num timestamp) {
  var canvas = querySelector("#canvas") as CanvasElement?;
  var context = canvas?.getContext('2d') as CanvasRenderingContext2D?;
  int canvasWidth = canvas?.width ?? 100;
  int hw = canvasWidth ~/ 2;
  int canvasHeight = canvas?.height ?? 100;
  int hh = canvasHeight ~/ 2;
  context?.clearRect(0, 0, canvasWidth, canvasHeight);

  simulation.next();

  for (Boid boid in simulation.boids) {
    context?.setFillColorRgb(0, 0, 0);
    context?.fillRect(boid.position.x ~/ 3, boid.position.y ~/ 3, 3, 3);
  }
  animation_request_id = window.requestAnimationFrame(boids_animation);
}

// This function is adapted from https://stackoverflow.com/questions/808826/draw-arrow-on-canvas-tag
void canvas_arrow(CanvasRenderingContext2D? context, num fromx, num fromy,
    num tox, num toy, num r) {
  var x_center = tox;
  var y_center = toy;

  var angle;
  var x;
  var y;

  context?.beginPath();

  angle = atan2(toy - fromy, tox - fromx);
  x = r * cos(angle) + x_center;
  y = r * sin(angle) + y_center;

  context?.moveTo(x, y);

  angle += (1 / 3) * (2 * pi);
  x = r * cos(angle) + x_center;
  y = r * sin(angle) + y_center;

  context?.lineTo(x, y);

  angle += (1 / 3) * (2 * pi);
  x = r * cos(angle) + x_center;
  y = r * sin(angle) + y_center;

  context?.lineTo(x, y);

  context?.closePath();

  context?.fill();
}
