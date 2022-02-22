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
  void cellUpdate(int list_index) {
    List<int> neighbors = cellNeighborhood(list_index);

    if (neighbors.length > 0) {
      var list = [
        for (var i = 0; i <= neighbors.length - 1; i++) grid[neighbors[i]]
      ];

      int num = list.reduce((i, j) => i + j);

      workingGrid[list_index] = num % 2;
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
}

class SierpinskiTriangle extends BooleanCellularAutomata {
  SierpinskiTriangle(int shape) : super([shape]);

  @override
  void initialize() {
    super.initialize();
    for (int i = 0; i < num_cells ~/ 2; i++) {
      grid[i] = 0;
    }
    grid[num_cells ~/ 2] = 1;
    for (int i = (num_cells ~/ 2) + 1; i < num_cells; i++) {
      grid[i] = 0;
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
  void cellUpdate(int list_index) {
    List<int> neighbors = cellNeighborhood(list_index);

    if (neighbors.length > 1) {
      List<int> lhs = [
        for (var i = 0; i <= neighbors.length - 1; i++) grid[neighbors[i]]
      ];

      lhs.insert(1, grid[list_index]);

      workingGrid[list_index] = rules[lhs.toString()] ?? 0;
    }
  }
}

void main() {
  print("Inicio");
  var ca = SierpinskiTriangle(15);
  ca.initialize();
  print(ca.grid);

  for (int i = 0; i < 20; i++) {
    var tmp = ca.next();
    print(tmp);
  }

  print("Fim");
}
