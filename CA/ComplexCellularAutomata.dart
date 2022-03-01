import 'CellularAutomata.dart';

abstract class ComplexCellularAutomata<ExternalT, InternalT>
    extends CellularAutomata<ExternalT> {
  ComplexCellularAutomata(List<int> shape) : super(shape);

  List<InternalT> _cellsCurrentInternal = [];

  List<InternalT> get cellsCurrentInternal => _cellsCurrentInternal;

  List<InternalT> _cellsWorkingInternal = [];

  List<InternalT> get cellsWorkingInternal => _cellsWorkingInternal;

  InternalT cellCreateInternal();

  @override
  void initialize([Map? args]) {
    for (int i = 0; i < num_cells; i++) {
      _cellsCurrentInternal.add(cellCreateInternal());
      cells.add(cellCreate());
    }
  }

  @override
  void begin() {
    super.begin();
    _cellsWorkingInternal = _cellsCurrentInternal.toList();
  }

  void commit() {
    super.commit();
    _cellsCurrentInternal = _cellsWorkingInternal.toList();
  }
}
