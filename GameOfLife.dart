import 'CellularAutomata.dart';
import 'dart:math';

final _random = Random();

class GameOfLife extends CellularAutomata<int> {
  GameOfLife(int width, int height) : super([width, height]);

  @override
  int cellCreate() {
    return _random.nextInt(2);
  }

  @override
  List<int> cellNeighborhood(int list_index) {
    var gix = gridIndex(list_index);
    List ix_grid = nextDimensionNeighbors(0, gix);
    var ret = <int>[];
    for (List<int> ix in ix_grid) {
      ret.add(listIndex(ix));
    }
    ret.sort();
    return ret;
  }

  @override
  void cellUpdate(int list_index) {
    List<int> neighbors = cellNeighborhood(list_index);

    if (neighbors.length > 0) {
      var list = [
        for (var i = 0; i <= neighbors.length - 1; i++) grid[neighbors[i]]
      ];

      int num = list.reduce((i, j) => i + j);

      if (num < 2) {
        workingGrid[list_index] = 0;
      } else if (num > 3) {
        workingGrid[list_index] = 0;
      } else if (num == 3) {
        workingGrid[list_index] = 1;
      }
    }
  }
}

void main() {
  print("Inicio");
  var ca = GameOfLife(5, 5);
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
