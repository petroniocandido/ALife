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
      index += grid_index[i] * _shape_dimensions[i];
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

    // Keep the dimension as is
    if (dim + 1 < _shape.length) {
      var neigh2 = nextDimensionNeighbors(dim + 1, grid_index.toList());
      for (var v in neigh2) {
        neigh.add(v);
      }
    }

    // Move one cell to the right
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

    // Move one cell to the left
    List<int> tmp2 = grid_index.toList();
    tmp2[dim] -= 1;
    if (isValidGridIndex(tmp2)) {
      neigh.add(tmp2);
      if (dim + 1 < _shape.length) {
        var neigh2 = nextDimensionNeighbors(dim + 1, tmp2);
        for (var v in neigh2) {
          neigh.add(v);
        }
      }
    }

    return neigh;
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

void main() {}
