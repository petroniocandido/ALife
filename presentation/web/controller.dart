import 'dart:html';
import 'dart:convert';
import 'dart:math';
import 'dart:async';

//import 'CellularAutomata.dart';
import '../../CA/CellularAutomata.dart';
import '../../CA/SierpinskiTriangle.dart';
import '../../CA/SimpleCellularAutomata1D.dart';
import '../../CA/GameOfLife.dart';
import '../../CA/PercolationCA.dart';
import '../../CA/OscillatorCA.dart';

final _random = Random();

CellularAutomata ca = GameOfLife(0, 0);

Map<String, dynamic> rules = {};

void main() {
  querySelector("#caWidth")?.onChange.listen((event) {
    changeLabel("caWidth", "lblcaWidth");
  });

  querySelector("#caHeight")?.onChange.listen((event) {
    changeLabel("caHeight", "lblcaHeight");
  });

  querySelector("#run_sierpinski")?.onClick.listen((event) {
    //sierpinski_start(event);
    ca1d_start(event);
  });

  querySelector("#run_conway")?.onClick.listen((event) {
    conway_start(event);
  });

  querySelector("#run_percolation")?.onClick.listen((event) {
    percolation_start(event);
  });

  querySelector("#run_oscillator")?.onClick.listen((event) {
    oscillator_start(event);
  });

  querySelector("#alpha")?.onChange.listen((event) {
    changeLabel("alpha", "lblAlpha");
  });

  querySelector("#epsilon")?.onChange.listen((event) {
    changeLabel("epsilon", "lblEpsilon");
  });

  readRulesFromJSON();
}

void readRulesFromJSON() async {
  try {
    final jsonString = await HttpRequest.getString(
        "https://petroniocandido.github.io/ALife/presentation/web/ca1d.json");
    rules = json.decode(jsonString) as Map<String, dynamic>;
  } catch (e) {
    print("Couldn't open");
  }

  var sel = querySelector("#CellularAutomata1D") as SelectElement;

  for (String key in rules.keys) {
    var opt = document.createElement("option") as OptionElement;
    opt.value = key;
    opt.innerText = key;
    sel.append(opt);
  }
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

void ca1d_start(MouseEvent event) {
  var w_ele = querySelector("#caWidth") as InputElement?;
  int w = int.parse(w_ele?.value ?? "0");

  var t = querySelector("#teste") as Element;

  var sel = querySelector("#CellularAutomata1D") as SelectElement;

  String key = sel.options[sel.selectedIndex ?? 0].value;

  Map<String, dynamic> r = rules[key];

  t.text = r.toString();
  ca = SimpleCellularAutomata1D(w, r);
  ca.initialize();

  window.requestAnimationFrame(sierpinski_animation_boxes);
}

void sierpinski_start(MouseEvent event) {
  var w_ele = querySelector("#caWidth") as InputElement?;
  int w = int.parse(w_ele?.value ?? "0");

  ca = SierpinskiTriangle(w);
  ca.initialize();

  window.requestAnimationFrame(sierpinski_animation_boxes);
}

void sierpinski_animation_boxes(num timestamp) {
  var canvas = querySelector("#canvas") as CanvasElement?;
  var context = canvas?.getContext('2d') as CanvasRenderingContext2D?;
  int canvasWidth = canvas?.width ?? 100;
  int canvasHeight = canvas?.height ?? 100;
  context?.clearRect(0, 0, canvasWidth, canvasHeight);

  double boxW = canvasWidth / ca.shape[0];
  double boxH = canvasHeight / ca.shape[0];

  for (int y = 0; y < canvasHeight; y++) {
    var img = ca.next();
    for (int x = 0; x < ca.shape[0]; x++) {
      int state = img[x];
      context?.setFillColorRgb(state * 255, state * 255, state * 255);
      context?.fillRect(x * boxW, y * boxH, boxW, boxH);
    }
  }
  window.requestAnimationFrame(sierpinski_animation_boxes);
}

void sierpinski_animation_image(num timestamp) {
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

void percolation_start(MouseEvent event) {
  var w_ele = querySelector("#caWidth") as InputElement?;
  var h_ele = querySelector("#caHeight") as InputElement?;
  int w = int.parse(w_ele?.value ?? "0");
  int h = int.parse(h_ele?.value ?? "0");

  ca = PercolationCA(<int>[w, h]);
  ca.initialize();

  window.requestAnimationFrame(percolation_animation_boxes);
}

void percolation_animation_boxes(num timestamp) {
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
      switch (state) {
        case 0:
          context?.setFillColorRgb(255, 255, 255);
          break;

        case 1:
          context?.setFillColorRgb(0, 0, 0);
          break;

        case 2:
          context?.setFillColorRgb(0, 0, 255);
          break;
      }
      context?.fillRect(x * boxW, y * boxH, boxW, boxH);
    }
  }
  window.requestAnimationFrame(percolation_animation_boxes);
}

void oscillator_start(MouseEvent event) {
  var w_ele = querySelector("#caWidth") as InputElement?;
  var h_ele = querySelector("#caHeight") as InputElement?;
  int w = int.parse(w_ele?.value ?? "0");
  int h = int.parse(h_ele?.value ?? "0");

  ca = OscillatorCA(w, h);

  var a_ele = querySelector("#alpha") as InputElement?;
  var e_ele = querySelector("#epsilon") as InputElement?;
  double a = double.parse(a_ele?.value ?? "1") / 1000;
  double e = double.parse(e_ele?.value ?? "5") / 100;

  var t_ele = querySelector("#adaption_type") as InputElement?;

  int t = int.parse(t_ele?.value ?? "0");

  (ca as OscillatorCA).alpha = a;
  (ca as OscillatorCA).epsilon = e;
  (ca as OscillatorCA).adaptionRule = t;

  ca.initialize();

  window.requestAnimationFrame(oscillator_animation_boxes);
}

void oscillator_animation_boxes(num timestamp) {
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
      context?.setFillColorRgb(31 * state, 31 * state, 31 * state);
      context?.fillRect(x * boxW, y * boxH, boxW, boxH);
    }
  }
  window.requestAnimationFrame(oscillator_animation_boxes);
}
