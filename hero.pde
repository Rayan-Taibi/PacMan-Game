class Hero {
  // position on screen
  PVector _position;
  PVector _posOffset;
  // position on board
  int _cellX, _cellY;
  // display size
  float _size;
  
  // move data
  PVector _direction;
  boolean _moving; // is moving ? 
  PVector _nextDirection; // la prochaine direction choisie
  float _vitesse;
  
  float _angleBouche;
  float _vitesseBouche;
  boolean _mouthOpen;

  Hero() {
    _position = new PVector(0,0);
    _posOffset = new PVector(0,0); // _posOffset sert a gerer le decalage lors des deplacements
    _cellX = 0;
    _cellY = 0;
    _size = CELL_SIZE * 0.8; // taille du hero par rapport a la taille de la cellule(80%)
    _direction = new PVector(0,0);
    _nextDirection = new PVector(0,0);
    _moving = false;
    _vitesse = 2.0;

    _angleBouche = 0;
    _vitesseBouche = 0.2;
    _mouthOpen = true;
  }
  // initialisation du hero  a la position cellX, cellY sur le board et au centre de la cellule
  void initialisation(int cellX, int cellY , Board board) {
    _cellX = cellX;
    _cellY = cellY;
    PVector center = board.getCellCenter(_cellY, _cellX); 
    _position = center.copy(); // cette mthode permet de copier la valeur de center dans _position
    _posOffset = new PVector(0,0);
    _direction = new PVector(0,0);
    _nextDirection = new PVector(0,0);
    _moving = false;
  }
  
  // lancer un deplacement dans la direction dir
  void launchMove(PVector dir) {
    _nextDirection = dir.copy();   // on copue la direction dans nextDirection

  }
  // on verifie si le hero peut se deplacer dans la direction dir
  boolean canMove(Board board, PVector dir) {
    int nextX = _cellX + int(dir.x); 
    int nextY = _cellY + int(dir.y);
    return !board.estMur(nextY, nextX);
  }
  
  void move(Board board) {
    if(!_moving){
      if(_nextDirection.mag() != 0 && canMove(board, _nextDirection)){
        _direction = _nextDirection.copy();
        _moving = true;
      }
    }
    if(_moving){
      _posOffset.add(PVector.mult(_direction, _vitesse));
      // verifier si on deplacer vers la prochaine cellule
      if(_posOffset.mag() >= CELL_SIZE){
        // on est arrive a la prochaine cellule
        _cellX += int(_direction.x);
        _cellY += int(_direction.y);
        
        if(_cellX < 0){
          _cellX = board._nbCellsX -1;
          _position = board.getCellCenter(_cellY, _cellX).copy();
          _posOffset.set(0,0);
        }else if(_cellX >= board._nbCellsX){
          _cellX = 0;
          _position = board.getCellCenter(_cellY, _cellX).copy();
          _posOffset.set(0,0);
        }
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

        PVector center = board.getCellCenter(_cellY, _cellX);
        _position = center.copy();

        if(canMove(board,_direction)){
          _moving = true;
        }else{
          _moving = false;
          _direction.set(0,0);
        }
       
        if(_nextDirection.mag() !=0 && ! _nextDirection.equals(_direction)){
          if(canMove(board,_nextDirection)){
            _direction = _nextDirection.copy();
            _moving = true;
          }
        }
      }
    }
  }
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


  void drawIt() {
    pushMatrix();
    float drawX = _position.x + _posOffset.x;
    float drawY = _position.y + _posOffset.y;
    translate(drawX, drawY);

    float angle = 0;
    if(_direction.x > 0) angle = 0;         // droite
    else if(_direction.x < 0) angle = PI;   // gauche
    else if(_direction.y > 0) angle = HALF_PI; // bas
    else if(_direction.y < 0) angle = -HALF_PI; // haut
    rotate(angle);

    // dessiner le hero 

    fill(255, 255, 0); // jaune
    noStroke();

    arc(0, 0, _size, _size, _angleBouche, TWO_PI - _angleBouche, PIE);

    popMatrix();

  }

  // getters pour la position sur le board
  int getCellX() {
    return _cellX;
  }
  int getCellY() {
    return _cellY;
  }
}