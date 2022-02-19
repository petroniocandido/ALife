import 'CellularAutomata.dart';

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
