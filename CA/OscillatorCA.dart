import 'CellularAutomata.dart';
import 'ComplexCellularAutomata.dart';
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

class OscillatorCA extends ComplexCellularAutomata<int, Oscillator> {
  OscillatorCA(int x, int y) : super([x, y]);

  int time = 0;

  double epsilon = 0.05;

  @override
  int cellCreate() {
    return 0;
  }

  @override
  void cellUpdate(int list_index, [Map? args]) {
    double wphase = cellsCurrentInternal[list_index].wave(time);
    List<int> neigh = cellNeighborhood(list_index);
    var n_wphases = <double>[
      for (int i in neigh) cellsCurrentInternal[i].wave(time)
    ];
    int state = [
      for (double i in n_wphases)
        i >= wphase - epsilon && i <= wphase + epsilon ? 1 : 0
    ].reduce((i, j) => i + j);
    cellsWorking[list_index] = state;
  }

  @override
  List<int> cellNeighborhood(int list_index, [Map? args]) {
    var gix = gridIndex(list_index);
    List ix_grid = nextDimensionNeighbors(0, gix);
    var ret = <int>[];
    for (List<int> ix in ix_grid) {
      ret.add(listIndex(ix));
    }
    return ret;
  }

  @override
  Oscillator cellCreateInternal() {
    return Oscillator();
  }

  @override
  List<int> next() {
    time++;
    begin();
    for (int i = 0; i < num_cells; i++) {
      cellUpdate(i);
    }
    commit();
    return cells.toList();
  }

  @override
  List<int> run(int iterations) {
    for (time = 0; time < iterations; time++) {
      begin();
      for (int i = 0; i < num_cells; i++) {
        cellUpdate(i);
      }
      commit();
    }
    return next();
  }
}

void main() {
  print("Inicio");
  var ca = OscillatorCA(5, 5);
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
