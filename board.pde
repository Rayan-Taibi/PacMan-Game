enum TypeCell 
{
  EMPTY, WALL, DOT, SUPER_DOT , VOID, BONUS // others ? ,  BONUS pour le bonus
}

class Board 
{
  TypeCell _cells[][];
  PVector _position;
  int _nbCellsX;
  int _nbCellsY;
  int _cellSize; // cells should be square

  int _nbPointsTotal; // nombre des points au depart 
  int _nbPointsManges; // nombre de  points manges

  PVector _bonusPosition; // position du bonus
  boolean _bonusVisible; 

  PVector _departPacman; 
  ArrayList<PVector> _departFantomes;

  
  Board(PVector position, int nbCellsX, int nbCellsY, int cellSize) {
    _position = position;
    _nbCellsX = nbCellsX;
    _nbCellsY = nbCellsY;
    _cellSize = cellSize;
    _cells = new TypeCell[_nbCellsX][_nbCellsY];
    _nbPointsTotal = 0;
    _nbPointsManges = 0;
    _bonusPosition = null;
    _bonusVisible = false;
    _departPacman = new PVector(0,0); // initialisation de la postion de pacman
    _departFantomes = new ArrayList<PVector>(); // par defaut
    
    // initialisation des cellules a vide
    for (int i=0 ; i<_nbCellsX ; i++){
      for (int j=0 ; j<_nbCellsY ; j++){
        _cells[i][j] = TypeCell.EMPTY;
      }
    }
  }
  
  void chargeLevel(String filename) {
    String [] lignes = loadStrings (filename);

    int startLine = 1 ; // Premiere ligne est skippee
    
    _nbCellsY = lignes.length - startLine;
    _nbCellsX = lignes[startLine].length();
    _cells = new TypeCell[_nbCellsX][_nbCellsY]; 

    for (int i = 0  ; i < _nbCellsY ; i++){
      String  ligne = lignes [startLine + i ];
      for (int j = 0 ; j < min(ligne.length(), _nbCellsX); j++){       //protecttion de l'erreur IndexOutOfBounds
        char c = ligne.charAt(j);
        switch (c){
          case 'x':
          _cells[i][j] = TypeCell.WALL;
          break;
          case 'o':
          _cells[i][j] = TypeCell.DOT;
          _nbPointsTotal++;
          break;
          case 'O': // erreur ici O majuscule pas 0 zero
          _cells[i][j]= TypeCell.SUPER_DOT;
          _nbPointsTotal++;
          break;
          case 'P':
          _cells[i][j] = TypeCell.EMPTY;
          _departPacman = new PVector(j,i); // on mis j et i parceque i est la ligne (y) et j est la colonne (x)
          break;
          case 'G': 
          _cells[i][j] = TypeCell.EMPTY;
          _departFantomes.add(new PVector(j,i)); // meme choses ici
          break;
          case 'V':
          _cells[i][j] = TypeCell.VOID;
          break;
          case 'B':
          _cells[i][j] = TypeCell.BONUS;
          _bonusPosition = new PVector(j,i); // meme choses ici
          break;
          default:
          _cells[i][j] = TypeCell.EMPTY;
          break;

        }
      }
    }

  }
  // retourne la position centrale de la cellule (i,j)
  PVector getCellCenter(int i, int j) {

    float x = _position.x + j * _cellSize + _cellSize / 2; 
    float y = _position.y + i * _cellSize + _cellSize / 2;
    return new PVector(x, y);
  }
  TypeCell getCellType(int i, int j) {
    if (i < 0 || i >= _nbCellsY || j < 0 || j >= _nbCellsX) {
      return TypeCell.WALL; // hors limites, on considere comme mur
    }
    return _cells[i][j];
  }

  // methode pour manger un point
  void mangerPoint(int i , int j){
    if(i >=0 && i < _nbCellsX && j >=0 && j <_nbCellsY){
      if(_cells[i][j] == TypeCell.DOT || _cells[i][j] == TypeCell.SUPER_DOT){
        _cells[i][j] = TypeCell.EMPTY;
        _nbPointsManges++;
      }
    }
  }
  // methode pour manger le bonus
  void mangerBonus(int i, int j){
    if(i >=0 && i < _nbCellsX && j >=0 && j <_nbCellsY){
      if(_cells[i][j] == TypeCell.BONUS){
        _cells[i][j] = TypeCell.EMPTY;
        _bonusVisible = false;
      }
    }
  }
  //  methode pour afficher le bonus
  void afficherBonus(){
    ArrayList<PVector> videPositions = new ArrayList<PVector>();
    for (int i=0 ; i<_nbCellsX ; i++){
      for (int j=0 ; j<_nbCellsY ; j++){
        if(_cells[i][j] == TypeCell.EMPTY){
          videPositions.add(new PVector(j,i));
        }
      }
    }
    // 
    if(videPositions.size()> 0){
      int ranIndex = int(random(videPositions.size()));
      _bonusPosition = videPositions.get(ranIndex);
      _cells[int(_bonusPosition.y)][int(_bonusPosition.x)] = TypeCell.BONUS;
      _bonusVisible = true;
    }
  }
  boolean estMur(int i , int j){
    return getCellType(i,j) == TypeCell.WALL;
  }
  // Pour les fantômes : les VOID ne sont pas des murs (ils peuvent passer à travers)
  boolean isWallForGhost(int i, int j) {
    TypeCell cell = getCellType(i, j);
    return cell == TypeCell.WALL;
  }
  boolean tousPointsManges(){
    return _nbPointsManges >= _nbPointsTotal;
  }

  void drawIt() {
    for(int i=0 ; i<_nbCellsX ; i++){
      for (int j=0 ; j<_nbCellsY ; j++){
        
        float x = _position.x + j * _cellSize;
        float y = _position.y + i * _cellSize;

        TypeCell cell = _cells[i][j];
        if (cell == null){
          fill(0);
          noStroke();
          rect(x, y, _cellSize, _cellSize);
          continue;
        }

        switch (cell){
          case WALL:
            fill(0,0,255);// bleu pour les murs
            stroke(50,50,200); // bordure un peu plus claire
            strokeWeight(2); 
            rect(x, y, _cellSize, _cellSize);
            break;

          case DOT:
            fill(0);
            noStroke();
            rect(x, y, _cellSize, _cellSize);
            fill(255,255,0); // jaune pour les points
            ellipse(x + _cellSize/2, y + _cellSize/2, _cellSize * 0.2, _cellSize * 0.2);
            break;

          case SUPER_DOT:
           fill(0);
            noStroke();
            rect(x, y, _cellSize, _cellSize);
            fill(255,255,0); // jaune pour les points
            ellipse(x + _cellSize/2, y + _cellSize/2, _cellSize * 0.4, _cellSize * 0.4);
            break;

          case BONUS: //  cerise comme bonus
            fill(0);
            noStroke();
            rect(x, y, _cellSize, _cellSize);
            
            fill(255, 0, 0); // Rouge
            ellipse(x + _cellSize/2 - 3, y + _cellSize/2 + 2, _cellSize * 0.3, _cellSize * 0.3);
            ellipse(x + _cellSize/2 + 3, y + _cellSize/2 + 2, _cellSize * 0.3, _cellSize * 0.3);
            // Tige
            stroke(0, 255, 0);
            strokeWeight(1);
            line(x + _cellSize/2 - 3, y + _cellSize/2, x + _cellSize/2, y + _cellSize/2 - 4);
            line(x + _cellSize/2 + 3, y + _cellSize/2, x + _cellSize/2, y + _cellSize/2 - 4);
            noStroke();
            break;
          
          case VOID:
            fill(20); 
            noStroke();
            rect(x, y, _cellSize, _cellSize);
            break;
            
          case EMPTY:
            fill(0); 
            noStroke();
            rect(x, y, _cellSize, _cellSize);
            break;
        }
      }
    }
  }
}
