abstract class Cell<T> {
  
  T _state;
  
  T get state => _state;
  
  Cell(this._state);
  
  void update(List<Cell> neighbors);
  
}

abstract class CellularAutomata<T, C extends Cell<T>> {
  final List<int> _shape;
  int num_cells = 0;
  List<int> _shape_dimensions = [];
  
  List<C> _grid = [];
  
  List<int> get shape => _shape;
  
  CellularAutomata(this._shape){
    num_cells = _shape.reduce((i,j) => i * j);
    var tmp1 = 1;
    for(int s in _shape.reversed){
      tmp1 *= s;
      _shape_dimensions.insert(0, tmp1);
    }
  }
  
  List<C> get grid => _grid;
  
  void initialize() {
    _grid = <C>[];
    for(int i = 0; i < num_cells; i++){
      _grid.add(new C());
    }
  }
  
  List<int> _to_grid_index(int list_index){
    var index = <int>[]; 
    int tmp = list_index;
    for(int i = 0; i < _shape.length-1; i++){
      index.add(tmp ~/ _shape_dimensions[i]);
      tmp = tmp % _shape_dimensions[i];
    }
    index.add(tmp);
    return index;
  }
  
  int _to_list_index(List<int> grid_index){
    int index = 0; 
    for(int i = 0; i < _shape.length-1; i++){
      index += grid_index[i] * _shape_dimensions[i];
    }
    index += grid_index[_shape.length-1];
    return index;
  }
  
  List<C> neighborhood(int list_index);
  
  List<T> next(){
    List<T> tmp = [];
    for(int i = 0; i < num_cells; i++){
      var cell = _grid[i];
      cell.update(neighborhood(i));
      tmp.add(cell.state);
    }
    return tmp;
  }
  
  List<T> run(int iterations){
    
    for(int i = 0; i < iterations; i++){
      for(int i = 0; i < num_cells; i++){
        var cell = _grid[i];
        cell.update(neighborhood(i));
      }
    }
    return next();
  }
}

void main() {
  for (int i = 0; i < 5; i++) {
    print('hello ${i + 1}');
  }
}
