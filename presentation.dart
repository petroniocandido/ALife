import 'dart:html';
import 'dart:math';

//import 'CellularAutomata.dart';
import 'SierpinskiTriangle.dart';
import 'GameOfLife.dart';

final _random = Random();

GameOfLife ca = GameOfLife(0, 0);

void main() {
  //querySelector("#paragrafo")?.text = "Hello world!";

  querySelector("#caWidth")?.onChange.listen((event) {
    changeLabel("caWidth", "lblcaWidth");
  });

  querySelector("#caHeight")?.onChange.listen((event) {
    changeLabel("caHeight", "lblcaHeight");
  });

  querySelector("#run_conway")?.onClick.listen((event) {
    conway_start(event);
  });
}

void changeLabel(String id_input, String id_output) {
  querySelector("#$id_output")?.text =
      (querySelector("#$id_input") as InputElement?)?.value;
}

void conway_start(MouseEvent event) {
  var w_ele = querySelector("#caWidth") as InputElement?;
  var h_ele = querySelector("#caHeight") as InputElement?;
  int w = int.parse(w_ele?.value ?? "0");
  int h = int.parse(h_ele?.value ?? "0");

  ca = GameOfLife(w, h);
  ca.initialize();

  //querySelector("#out")?.text = "$w, $h";

  window.requestAnimationFrame(conway_animation_boxes);
}

void conway_animation_boxes(num timestamp) {
  var canvas = querySelector("#canvas") as CanvasElement?;
  var context = canvas?.getContext('2d') as CanvasRenderingContext2D?;
  int canvasWidth = canvas?.width ?? 100;
  int canvasHeight = canvas?.height ?? 100;
  context?.clearRect(0, 0, canvasWidth, canvasHeight);

  double boxW = canvasWidth / ca.shape[0];
  double boxH = canvasHeight / ca.shape[1];

  var img = ca.next();
  for (int y = 0; y < ca.shape[1]; y++) {
    for (int x = 0; x < ca.shape[0]; x++) {
      int state = img[ca.listIndex([x, y])];
      context?.setFillColorRgb(state * 255, state * 255, state * 255);
      context?.fillRect(x * boxW, y * boxH, boxW, boxH);
    }
  }
  window.requestAnimationFrame(conway_animation_boxes);
}

void conway_animation_image(num timestamp) {
  var canvas = querySelector("#canvas") as CanvasElement?;
  var context = canvas?.getContext('2d') as CanvasRenderingContext2D?;
  int canvasWidth = canvas?.width ?? 100;
  int canvasHeight = canvas?.height ?? 100;
  context?.clearRect(0, 0, canvasWidth, canvasHeight);
  var id = context?.getImageData(0, 0, canvasWidth, canvasHeight) as ImageData;
  var pixels = id.data;

  var img = ca.next();
  for (int y = 0; y < ca.shape[0]; y++) {
    for (int x = 0; x < ca.shape[1]; x++) {
      var r = img[x * ca.shape[0] + y] * (_random.nextDouble() * 256).round();
      var g = img[x * ca.shape[0] + y] * (_random.nextDouble() * 256).round();
      var b = img[x * ca.shape[0] + y] * (_random.nextDouble() * 256).round();
      var off = (y * id.width + x) * 4;
      pixels[off.toInt()] = r;
      pixels[(off + 1).toInt()] = g;
      pixels[(off + 2).toInt()] = b;
      pixels[(off + 3).toInt()] = 255;
    }
  }
  context?.putImageData(id, 0, 0);
  window.requestAnimationFrame(conway_animation_image);
}

void sierpinski() {
  var canvas = querySelector("#canvas") as CanvasElement?;
  var context = canvas?.getContext('2d') as CanvasRenderingContext2D?;
  int canvasWidth = canvas?.width ?? 100;
  int canvasHeight = canvas?.height ?? 100;
  context?.clearRect(0, 0, canvasWidth, canvasHeight);
  var id = context?.getImageData(0, 0, canvasWidth, canvasHeight) as ImageData;
  var pixels = id.data;

  var ca = SierpinskiTriangle(canvasWidth);
  ca.initialize();

  for (int y = 0; y < canvasHeight; y++) {
    var line = ca.next();
    for (int x = 0; x < canvasWidth; x++) {
      var r = line[x] * (_random.nextDouble() * 256).round();
      var g = line[x] * (_random.nextDouble() * 256).round();
      var b = line[x] * (_random.nextDouble() * 256).round();
      var off = (y * id.width + x) * 4;
      pixels[off.toInt()] = r;
      pixels[(off + 1).toInt()] = g;
      pixels[(off + 2).toInt()] = b;
      pixels[(off + 3).toInt()] = 255;
    }
  }
  context?.putImageData(id, 0, 0);
}
