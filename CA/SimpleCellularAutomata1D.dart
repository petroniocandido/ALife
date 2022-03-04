import 'CellularAutomata.dart';
import 'dart:math';

final _random = Random();

class SimpleCellularAutomata1D extends CellularAutomata<int> {
  SimpleCellularAutomata1D(int shape, Map<String, dynamic> _r)
      : super([shape]) {
    _rules = _r;
  }

  Map<String, dynamic> _rules = {};

  Map<String, dynamic> get rules => _rules;

  @override
  void initialize([Map? args]) {
    super.initialize();
    int w = shape[0];
    int init_cells = max(w * (rules["start"] ?? 0.1) as double, 1) as int;
    for (int i = 0; i < init_cells; i++) {
      int list_index = _random.nextInt(w);
      cells[list_index] = 1;
    }
  }

  @override
  int cellCreate() {
    return 0;
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
  void cellUpdate(int list_index, [Map? args]) {
    List<int> neighbors = cellNeighborhood(list_index);

    if (neighbors.length > 1) {
      List<int> lhs = [
        for (var i = 0; i <= neighbors.length - 1; i++) cells[neighbors[i]]
      ];

      lhs.insert(1, cells[list_index]);

      cellsWorking[list_index] = (rules[lhs.toString()] ?? 0) as int;
    }
  }
}

void main() {
  print("Inicio");
  var ca = SimpleCellularAutomata1D(15, {});
  ca.initialize();
  print(ca.cells);

  for (int i = 0; i < 20; i++) {
    var tmp = ca.next();
    print(tmp);
  }

  print("Fim");
}
