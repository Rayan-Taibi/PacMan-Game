class Hero {
  // position sur l'ecran
  PVector _position;
  PVector _posOffset;
  // position sur le board
  int _cellX, _cellY;
  float _size;  // taille de l'ecran

  
  // info pour le deplacement
  PVector _direction;
  boolean _moving; 
  PVector _nextDirection; 
  float _vitesse;
  
  float _angleBouche; // pour l'anim de la bouche
  float _vitesseBouche;
  boolean _mouthOpen; // bouche ouverte ou non

  // constructeur
  Hero() {
    _position = new PVector(0,0);
    _posOffset = new PVector(0,0); // sert a gérer le decalage lors du mouvement
    _cellX = 0;
    _cellY = 0;
    _size = CELL_SIZE * 0.8; // 80% de la taille d'une cellule
    _direction = new PVector(0,0);
    _nextDirection = new PVector(0,0);
    _moving = false;
    _vitesse = 2.0;

    _angleBouche = 0;
    _vitesseBouche = 0.2;
    _mouthOpen = true;
  }

  // mettre le hero a une position initiale sur le board
  void initialisation(int cellX, int cellY , Board board) {
    _cellX = cellX;
    _cellY = cellY;
    PVector center = board.getCellCenter(_cellY, _cellX); 
    _position = center.copy(); // copie le centre dans _position
    _posOffset = new PVector(0,0);
    _direction = new PVector(0,0);
    _nextDirection = new PVector(0,0);
    _moving = false;
  }
  
  // lancer un deplacement dans une direction
  void launchMove(PVector dir) {
    _nextDirection = dir.copy();   // copie la direction
  }

  // verifie si le hero peut bouger dans une direction
  boolean canMove(Board board, PVector dir) {
    int nextX = _cellX + int(dir.x); 
    int nextY = _cellY + int(dir.y);
    return !board.estMur(nextY, nextX); // retourne vrai si pas de mur
  }
  
  // deplacement du hero
  void move(Board board) {
    if(!_moving){
      if(_nextDirection.mag() != 0 && canMove(board, _nextDirection)){
        _direction = _nextDirection.copy();
        _moving = true;
      }
    }
    if(_moving){
      _posOffset.add(PVector.mult(_direction, _vitesse));
      // voir si on a atteint la prochaine cellule
      if(_posOffset.mag() >= CELL_SIZE){
        // update de la cellule courante
        _cellX += int(_direction.x);
        _cellY += int(_direction.y);
        
        // teleportation si sortie du board horizontal
        if(_cellX < 0){
          _cellX = board._nbCellsX -1;
          _position = board.getCellCenter(_cellY, _cellX).copy();
          _posOffset.set(0,0);
        }else if(_cellX >= board._nbCellsX){
          _cellX = 0;
          _position = board.getCellCenter(_cellY, _cellX).copy();
          _posOffset.set(0,0);
        }
        // pareil pour vertical
        if(_cellY < 0){
          _cellY = board._nbCellsY -1;
          _position = board.getCellCenter(_cellY, _cellX).copy();
          _posOffset.set(0,0);
        }else if(_cellY >= board._nbCellsY){
          _cellY = 0;
          _position = board.getCellCenter(_cellY, _cellX).copy();
          _posOffset.set(0,0);
        }
        _posOffset.set(0,0);

        // recalcule position precise
        PVector center = board.getCellCenter(_cellY, _cellX);
        _position = center.copy();

        if(canMove(board,_direction)){
          _moving = true;
        }else{
          _moving = false;
          _direction.set(0,0);
        }
       
        // si on veut changer de direction apres
        if(_nextDirection.mag() !=0 && ! _nextDirection.equals(_direction)){
          if(canMove(board,_nextDirection)){
            _direction = _nextDirection.copy();
            _moving = true;
          }
        }
      }
    }
  }

  // update du hero chaque frame
  void update(Board board) {
    move(board);
    // animation de la bouche
    if(_moving){
      if(_mouthOpen){
        _angleBouche += _vitesseBouche;
        if(_angleBouche >= 0.6){
          _angleBouche = 0.6;
          _mouthOpen = false;
        }
      }else{
        _angleBouche -= _vitesseBouche;
        if(_angleBouche <= 0){
          _mouthOpen = true;
        }
      }
    }else{
      _angleBouche = 0;
    }
  }

  // draw le hero on the screen
  void drawIt() {
    pushMatrix();
    float drawX = _position.x + _posOffset.x;
    float drawY = _position.y + _posOffset.y;
    translate(drawX, drawY);

    float angle = 0;
    if(_direction.x > 0) angle = 0;         // droite
    else if(_direction.x < 0) angle = PI;   // gauche
    else if(_direction.y > 0) angle = HALF_PI; // up
    else if(_direction.y < 0) angle = -HALF_PI; // down
    rotate(angle);

    // draw the hero
    fill(255, 255, 0); // jaune
    noStroke();
    arc(0, 0, _size, _size, _angleBouche, TWO_PI - _angleBouche, PIE);

    popMatrix();
  }

  // getter pour la position sur le board
  int getCellX() {
    return _cellX;
  }
  int getCellY() {
    return _cellY;
  }
}
