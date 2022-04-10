abstract class CellularAutomata<T> {
  // The shape are the dimensions of the simulation grid
  final List<int> _shape;
  List<int> get shape => _shape;

  int num_cells = 0;

  // This variable is used to find the cell neighborhood
  List<int> _shape_dimensions = [];

  List<int> get shape_dimensions => _shape_dimensions;

  // The cell states in the current iteration
  List<T> _cellsCurrent = [];

  List<T> get cells => _cellsCurrent;

  // The cell states being computed for the next iteration
  List<T> _cellsWorking = [];

  List<T> get cellsWorking => _cellsWorking;

  T operator [](int i) => _cellsCurrent[i];

  int padding = 0;

  int _iteration = 0;

  int get iteration => _iteration;

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
  List<int> cellNeighborhood(int list_index, [Map? args]);
  void cellUpdate(int list_index, [Map? args]);

  ///////////////////////////////////////////////
  // BASE METHODS
  ///////////////////////////////////////////////

  void initialize([Map? args]) {
    _iteration = 0;
    _cellsCurrent = [];
    _cellsWorking = [];
    for (int i = 0; i < num_cells; i++) {
      _cellsCurrent.add(cellCreate());
    }
  }

  void begin() {
    _cellsWorking = _cellsCurrent.toList();
  }

  void commit() {
    _cellsCurrent = _cellsWorking.toList();
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
    _iteration++;
    begin();
    for (int i = 0; i < num_cells; i++) {
      cellUpdate(i);
    }
    commit();
    return _cellsCurrent.toList();
  }

  List<T> run(int iterations) {
    for (_iteration = 0; _iteration < iterations; _iteration++) {
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
      for (int y = 0; y < ca.shape[1]; y++) ca.cells[x * ca.shape[1] + y]
    ];
    print(line);
  }
}

void main() {}
