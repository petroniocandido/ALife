import 'CellularAutomata.dart';
import 'ComplexCellularAutomata.dart';
import 'dart:math';

final _random = Random();

class Oscillator {
  double _amplitude = 2 * _random.nextDouble();

  double get amplitude => _amplitude;

  void set amplitude(double v) => _amplitude = v;

  double _frequency = _random.nextDouble();

  double get frequency => _frequency;

  void set frequency(double v) => _frequency = v;

  double _phase = (2 * _random.nextDouble()) - 1;

  double get phase => _phase;

  void set phase(double v) => _phase = v;

  double wave(int t) {
    return _amplitude * sin(t * _frequency + _phase);
  }

  List<double> d_wave(int t) {
    return [
      sin(_frequency * t + _phase),
      _amplitude * t * cos(_frequency * t + _phase),
      _amplitude * cos(_frequency * t + _phase)
    ];
  }

  @override
  String toString() {
    return "y(t) = $_amplitude * sin(t * $_frequency + $_phase)";
  }
}

class OscillatorCA extends ComplexCellularAutomata<int, Oscillator> {
  OscillatorCA(int x, int y) : super([x, y]);

  int _adaptionRule = 0;

  int get adaptionRule => _adaptionRule;

  void set adaptionRule(int v) => _adaptionRule = v;

  int time = 0;

  double _epsilon = 0.05;

  double get epsilon => _epsilon;

  void set epsilon(double v) => _epsilon = v;

  double _alpha = 0.01;

  double get alpha => _alpha;

  void set alpha(double v) => _alpha = v;

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
        i >= wphase - _epsilon && i <= wphase + _epsilon ? 1 : 0
    ].reduce((i, j) => i + j);
    cellsWorking[list_index] = state;

    gradientAdaption(list_index, wphase, neigh, n_wphases);

    averageAdaption(list_index, neigh);
  }

  void gradientAdaption(
      int list_index, double wphase, List<int> neigh, List<double> n_wphases) {
    List<double> deriv = cellsCurrentInternal[list_index].d_wave(time);

    for (int i = 0; i < neigh.length; i++) {
      double error = wphase - n_wphases[i];

      cellsWorkingInternal[list_index].amplitude += _alpha * -deriv[0] * error;
      cellsWorkingInternal[list_index].frequency += _alpha * -deriv[1] * error;
      cellsWorkingInternal[list_index].phase += _alpha * -deriv[2] * error;
    }
  }

  void averageAdaption(int list_index, List<int> neigh) {
    for (int i in neigh) {
      cellsWorkingInternal[list_index].amplitude += _alpha *
          (cellsCurrentInternal[i].amplitude -
              cellsWorkingInternal[list_index].amplitude);
      cellsWorkingInternal[list_index].frequency += _alpha *
          (cellsCurrentInternal[i].frequency -
              cellsWorkingInternal[list_index].frequency);
      cellsWorkingInternal[list_index].phase += _alpha *
          (cellsCurrentInternal[i].phase -
              cellsWorkingInternal[list_index].phase);
    }
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
  /*
  var osc = Oscillator();
  print(osc);
  for (int i = 0; i < 10; i++) {
    print(osc.wave(i));
  }*/
}
