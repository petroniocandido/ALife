import 'CellularAutomata.dart';
import 'dart:math';

final _random = Random();

class Oscillator {
  double _amplitude = _random.nextDouble() * 10;

  double get amplitude => _amplitude;

  double _frequency = _random.nextDouble();

  double get frequency => _frequency;

  double _phase = _random.nextDouble();

  double get phase => _phase;

  double wave(int t) {
    return _amplitude * sin(t * _frequency + _phase);
  }
}

class OscillatorCA extends CellularAutomata<Oscillator> {
  OscillatorCA(int x, int y) : super([x, y]);

  @override
  Oscillator cellCreate() {
    return Oscillator();
  }

  @override
  void cellUpdate(int list_index) {
    if (grid[list_index] == 0) {
      List<int> neighbors = cellNeighborhood(list_index);

      if (neighbors.length > 0) {
        var list = [
          for (var i = 0; i <= neighbors.length - 1; i++) grid[neighbors[i]]
        ];
        if (list.any((element) => element == 2)) {
          workingGrid[list_index] = 2;
        }
      }
    }
  }

  @override
  List<int> cellNeighborhood(int list_index) {
    var gix = gridIndex(list_index);
    List ix_grid = nextDimensionNeighbors(0, gix);
    var ret = <int>[];
    for (List<int> ix in ix_grid) {
      ret.add(listIndex(ix));
    }
    return ret;
  }

  @override
  void initialize() {
    super.initialize();
    int initial = _random.nextInt(grid.length - 1);
    while (grid[initial] != 0) {
      initial = _random.nextInt(grid.length - 1);
    }
    print(initial);
    begin();
    workingGrid[initial] = 2;
    commit();
  }
}

void main() {
  print("Inicio");
  var ca = PercolationCA([5, 5]);
  ca.initialize();
  printGrid(ca);

  print("");

  for (int i = 0; i < 3; i++) {
    ca.next();
    printGrid(ca);
    print("");
  }

  print("Fim");
}
