import 'dart:math';

final _random = Random();

abstract class CellularAutomata<T> {
  final List<int> _shape;
  List<int> get shape => _shape;

  int num_cells = 0;
  List<int> _shape_dimensions = [];

  List<int> get shape_dimensions => _shape_dimensions;

  List<T> _grid_current = [];

  List<T> get grid => _grid_current;

  List<T> _grid_working = [];

  List<T> get workingGrid => _grid_working;

  int padding = 0;

  CellularAutomata(this._shape) {
    num_cells = _shape.reduce((i, j) => i * j);

    for (int i = 0; i < _shape.length - 1; i++) {
      int tmp = 1;
      for (int j = i + 1; j < _shape.length; j++) {
        tmp *= _shape[j];
      }
      _shape_dimensions.add(tmp);
    }
  }

  ///////////////////////////////////////////////
  // ABSTRACT METHODS
  ///////////////////////////////////////////////

  T cellCreate();
  List<T> cellNeighborhood(int list_index);
  void cellUpdate(int list_index);

  ///////////////////////////////////////////////
  // BASE METHODS
  ///////////////////////////////////////////////

  void initialize() {
    _grid_current = [];
    _grid_working = [];
    for (int i = 0; i < num_cells; i++) {
      _grid_current.add(cellCreate());
    }
  }

  void begin() {
    _grid_working = _grid_current.toList();
  }

  void commit() {
    _grid_current = _grid_working.toList();
  }

  bool isValidGridIndex(List<int> index) {
    for (int di = 0; di < _shape.length; di++) {
      if (index[di] < 0 || index[di] == _shape[di]) {
        return false;
      }
    }
    return true;
  }

  List<int> gridIndex(int list_index) {
    var index = <int>[];
    int tmp = list_index;
    for (int i = 0; i < _shape.length - 1; i++) {
      index.add(tmp ~/ _shape_dimensions[i]);
      tmp = tmp % _shape_dimensions[i];
    }
    index.add(tmp);
    return index;
  }

  int listIndex(List<int> grid_index) {
    int index = 0;
    for (int i = 0; i < _shape.length - 1; i++) {
      index += grid_index[i + 1] * _shape_dimensions[i];
    }
    index += grid_index[_shape.length - 1];
    return index;
  }

  List<T> next() {
    begin();
    for (int i = 0; i < num_cells; i++) {
      cellUpdate(i);
    }
    commit();
    return _grid_current.toList();
  }

  List<T> run(int iterations) {
    for (int i = 0; i < iterations; i++) {
      begin();
      for (int i = 0; i < num_cells; i++) {
        cellUpdate(i);
      }
      commit();
    }
    return next();
  }

  List nextDimensionNeighbors(int dim, List<int> grid_index) {
    List neigh = [];

    List<int> tmp1 = grid_index.toList();
    tmp1[dim] += 1;
    if (isValidGridIndex(tmp1)) {
      neigh.add(tmp1);
      if (dim + 1 < _shape.length) {
        var neigh2 = nextDimensionNeighbors(dim + 1, tmp1);
        for (var v in neigh2) {
          neigh.add(v);
        }
      }
    }

    List<int> tmp2 = grid_index.toList();
    tmp2[dim] -= 1;
    if (isValidGridIndex(tmp2)) {
      neigh.add(tmp2);
      if (dim - 1 > 0) {
        var neigh2 = nextDimensionNeighbors(dim - 1, tmp2);
        for (var v in neigh2) {
          neigh.add(v);
        }
      }
    }

    return neigh;
  }
}

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
        for (var i = 0; i <= neighbors.length - 1; i++)
          _grid_current[neighbors[i]]
      ];

      int num = list.reduce((i, j) => i + j);

      _grid_working[list_index] = num % 2;
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

void printGrid(CellularAutomata ca) {
  for (int x = 0; x < ca.shape[0]; x++) {
    var line = [
      for (int y = 0; y < ca.shape[1]; y++) ca.grid[x * ca.shape[1] + y]
    ];
    print(line);
  }
}

void main() {
  print("Inicio");
  var ca = BooleanCellularAutomata([5, 5]);
  ca.initialize();
  //print(ca.listIndex([5]));
  //print(ca.nextDimensionNeighbors(0,[5]));
  //print(ca.shape_dimensions);

  /*print(ca.grid);
  for (int i = 0; i < ca.grid.length; i++) {
    print(i);
    print(ca.cellNeighborhood(i));
  }*/

  for (int i = 0; i < 10; i++) {
    ca.next();
    //print(tmp);
    print('Iteracao');
    printGrid(ca);
  }
  print("Fim");
}
