import 'CellularAutomata.dart';
import 'dart:math';

final _random = Random();

enum PercolationState { Empty, Solid, Filled }

class PercolationCA extends CellularAutomata<int> {
  PercolationCA(List<int> shape) : super(shape);

  @override
  int cellCreate() {
    double r = _random.nextDouble();
    if (r < .6) {
      return 1;
    }

    return 0;
  }

  @override
  void cellUpdate(int list_index, [Map? args]) {
    if (cells[list_index] == 0) {
      List<int> neighbors = cellNeighborhood(list_index);

      if (neighbors.length > 0) {
        var list = [
          for (var i = 0; i <= neighbors.length - 1; i++) cells[neighbors[i]]
        ];
        if (list.any((element) => element == 2)) {
          cellsWorking[list_index] = 2;
        }
      }
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
  void initialize([Map? args]) {
    super.initialize();
    int initial = _random.nextInt(cells.length - 1);
    while (cells[initial] != 0) {
      initial = _random.nextInt(cells.length - 1);
    }
    print(initial);
    begin();
    cellsWorking[initial] = 2;
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
