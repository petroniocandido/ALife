import 'CellularAutomata.dart';
import 'dart:math';

final _random = Random();

class BooleanCellularAutomata extends CellularAutomata<int> {
  BooleanCellularAutomata(List<int> shape) : super(shape);

  @override
  int cellCreate() {
    return _random.nextInt(2);
  }

  @override
  void cellUpdate(int list_index, [Map? args]) {
    List<int> neighbors = cellNeighborhood(list_index);

    if (neighbors.length > 0) {
      var list = [
        for (var i = 0; i <= neighbors.length - 1; i++) cells[neighbors[i]]
      ];

      int num = list.reduce((i, j) => i + j);

      cellsWorking[list_index] = num % 2;
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
}

class SierpinskiTriangle extends BooleanCellularAutomata {
  SierpinskiTriangle(int shape) : super([shape]);

  @override
  void initialize([Map? args]) {
    super.initialize();
    for (int i = 0; i < num_cells ~/ 2; i++) {
      cells[i] = 0;
    }
    cells[num_cells ~/ 2] = 1;
    for (int i = (num_cells ~/ 2) + 1; i < num_cells; i++) {
      cells[i] = 0;
    }
  }

  final Map<String, int> rules = {
    '[0, 0, 0]': 0,
    '[0, 0, 1]': 1,
    '[0, 1, 0]': 0,
    '[0, 1, 1]': 1,
    '[1, 0, 0]': 1,
    '[1, 0, 1]': 0,
    '[1, 1, 0]': 1,
    '[1, 1, 1]': 0
  };

  @override
  void cellUpdate(int list_index, [Map? args]) {
    List<int> neighbors = cellNeighborhood(list_index);

    if (neighbors.length > 1) {
      List<int> lhs = [
        for (var i = 0; i <= neighbors.length - 1; i++) cells[neighbors[i]]
      ];

      lhs.insert(1, cells[list_index]);

      cellsWorking[list_index] = rules[lhs.toString()] ?? 0;
    }
  }
}

void main() {
  print("Inicio");
  var ca = SierpinskiTriangle(15);
  ca.initialize();
  print(ca.cells);

  for (int i = 0; i < 20; i++) {
    var tmp = ca.next();
    print(tmp);
  }

  print("Fim");
}
