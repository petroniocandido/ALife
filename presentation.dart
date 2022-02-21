import 'dart:html';
import 'dart:math';

//import 'CellularAutomata.dart';
import 'SierpinskiTriangle.dart';

final _random = Random();

void main() {
  //querySelector("#paragrafo")?.text = "Hello world!";

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
