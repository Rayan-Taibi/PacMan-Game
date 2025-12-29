enum TypeCell 
{
  EMPTY, WALL, DOT, SUPER_DOT // others ?
}

class Board 
{
  TypeCell _cells[][];
  PVector _position;
  int _nbCellsX;
  int _nbCellsY;
  int _cellSize; // cells should be square
  
  Board(PVector position, int nbCellsX, int nbCellsY, int cellSize) {
  }
  
  PVector getCellCenter(int i, int j) {
    return null;
  }
  
  void drawIt() {
  }
}
