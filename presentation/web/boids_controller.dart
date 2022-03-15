import 'dart:html';
import 'dart:convert';
import 'dart:math';
import 'dart:async';

//import 'CellularAutomata.dart';
import '../../Boids/Boids.dart';
import '../../Common/Point2D.dart';

final _random = Random();

num animation_request_id = 0;

BoidSimulation simulation = BoidSimulation(0, 0);

Map<String, dynamic> rules = {};

void main() {
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

  simulation = BoidSimulation(canvasWidth, canvasHeight);
  simulation.initialize();

  window.requestAnimationFrame(boids_animation);
}

void boids_animation(num timestamp) {
  var canvas = querySelector("#canvas") as CanvasElement?;
  var context = canvas?.getContext('2d') as CanvasRenderingContext2D?;
  int canvasWidth = canvas?.width ?? 100;
  int canvasHeight = canvas?.height ?? 100;
  context?.clearRect(0, 0, canvasWidth, canvasHeight);

  simulation.next();

  for (Boid boid in simulation.boids) {
    Point2D vec = boid.vector(10);
    canvas_arrow(context, boid.position.x, boid.position.y, vec.x, vec.y,
        boid.direction);
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
