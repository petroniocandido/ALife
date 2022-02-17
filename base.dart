import 'dart:math';

final _random = Random();

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
  
  void initialize(Function() constructor) {
    _grid = <C>[];
    for(int i = 0; i < num_cells; i++){
      _grid.add(constructor());
    }
  }
  
  bool isValidGridIndex(List<int> index){
    for(int di = 0; di < _shape.length; ) {
      if(index[di] < 0 || index[di] == _shape[di]){ return false; }
    }
    return true;
  }
  
  List<int> gridIndex(int list_index){
    var index = <int>[]; 
    int tmp = list_index;
    for(int i = 0; i < _shape.length-1; i++){
      index.add(tmp ~/ _shape_dimensions[i]);
      tmp = tmp % _shape_dimensions[i];
    }
    index.add(tmp);
    return index;
  }
  
  int listIndex(List<int> grid_index){
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

class BooleanCell extends Cell<int> {
  
  BooleanCell(): super(_random.nextInt(1));
  
  @override
  void update(List<Cell> neighbors){
    var list = [for (var i = 1; i <= neighbors.length; i++) neighbors[i].state];
    int num = list.reduce((i,j)=>i+j);
    _state = num % 2;
  }
}

class BooleanCellularAutomata extends CellularAutomata<int, BooleanCell>{
  BooleanCellularAutomata(List<int> shape) : super(shape);
  
  List nextDimensionNeighbors(int dim, List<int> index){
    var neigh = [];
    
    List<int> tmp1 = index;
    tmp1[dim] += 1;
    if(isValidGridIndex(tmp1)){ 
      neigh.add(tmp1);
      if(dim + 1 < _shape.length){
        var neigh2 = nextDimensionNeighbors(dim +1, tmp1);
        for(var v in neigh2){
          neigh.add(v);
        }
      }
    }
    
    List<int> tmp2 = index;
    tmp2[dim] -= 1;
    if(isValidGridIndex(tmp2)){ 
      neigh.add(tmp2);
      if(dim - 1 > 0){
        var neigh2 = nextDimensionNeighbors(dim - 1, tmp2);
        for(var v in neigh2){
          neigh.add(v);
        }
      }
    }
    
    return neigh;
    
    
  }
  
  List<BooleanCell> neighborhood(int list_index) {
    var gix = gridIndex(list_index);
    List ix_grid = nextDimensionNeighbors(0, gix);
    var ret = <BooleanCell>[];
    for(List<int> ix in ix_grid){
      ret.add(_grid[listIndex(ix)]);
    }
    return ret;
  }
}

void main() {
  var ca = BooleanCellularAutomata([10]);
  ca.initialize(() => BooleanCell());
  var tmp = ca.next();
  print(tmp);
}
