abstract class Cell<T> {
  
  T _state;
  
  T get state => _state;
  
  Cell(this._state);
  
  void update(List<Cell> neighbors);
  
}

abstract class CellularAutomata<T, C extends Cell<T>> {
  final Set<int> _shape;
  
  List<C> _grid = [];
  
  Set<int> get shape => _shape;
  
  CellularAutomata(this._shape);
  
  List<C> get grid => _grid;
  
  void initialize() {
    int size = _shape.reduce((i,j) => i * j);
    _grid = <C>[];
    for(int i = 0; i < size; i++){
      _grid.add(new C());
    }
  }
  
  int _to_grid_index(int list_index){
    int tmp = list_index;
    for(int i = 0; i < _shape.length; i++){
      tmp = tmp % _shape[i];
    }
  }
  
  List<C> neighborhood(int list_index);
  
  List<T> next(){
    for(var cell in _grid){
      
    }
  }
  
  List<T> run(int iterations){
    for(int i = 0; i < iterations; i++){
      next();
    }
    return _grid;
  }
}

void main() {
  for (int i = 0; i < 5; i++) {
    print('hello ${i + 1}');
  }
}
