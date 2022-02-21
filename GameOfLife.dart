import 'CellularAutomata.dart';

class GameOfLife extends CellularAutomata<int> {
  GameOfLife(int width, int height) : super([width, height]);

  @override
  int cellCreate() {
    // TODO: implement cellCreate
    throw UnimplementedError();
  }

  @override
  List<int> cellNeighborhood(int list_index) {
    // TODO: implement cellNeighborhood
    throw UnimplementedError();
  }

  @override
  void cellUpdate(int list_index) {
    // TODO: implement cellUpdate
  }
}
