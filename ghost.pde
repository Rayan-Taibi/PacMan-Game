// Les differant types de fantomes dans le jeu
// chaque fantome a un comportemant different
enum GhostType {
  BLINKY,  // Shadow (red) - follows Pac-Man permanently
  PINKY,   // Speedy (pink) - aims where Pac-Man is heading
  INKY,    // Bashful (blue) - sometimes goes opposite direction
  CLYDE    // Pokey (orange) - sometimes changes direction randomly
}

// les mode de comportemant des fantomes
enum GhostMode {
  LEAVING_HOME, // il sort de la maison
  SCATTER,  // retourne dans les coins
  CHASE,    // poursui pacman
  FRIGHTENED, // a peur et s'enfuit
  EATEN     // retourne au spawn quand il est mangé
}

// Global sprite sheet for ghosts (loaded once)
PImage ghostSpriteSheet = null;

class Ghost {
  // Position on screen
  PVector _position;
  PVector _posOffset;
  
  // Position on board
  int _cellX, _cellY;
  
  // Spawn position
  int _spawnX, _spawnY;
  
  // Display size
  float _size;
  
  // Move data
  PVector _direction;
  PVector _targetCell; // target cell for AI
  boolean _moving;
  float _speed;
  
  // les propriétés du fantomes
  GhostType _type;
  GhostMode _mode;
  color _color;
  String _name;
  
 // compportement des fantomes
  int _scatterTimer;
  int _chaseTimer;
  int _behaviorChangeTimer;
  int _respawnTimer; // Timer pour ressortir de la cage après avoir été mangé
  
  // Sprites
  int _spriteX, _spriteY; // position in sprite sheet
  int _animFrame;
  int _animTimer;
  
  Ghost(GhostType type) {
    // initialisation de toute les variable du fantome
    // j'ai mis des valeur par defaut pour eviter les erreur
    _position = new PVector(0, 0);
    _posOffset = new PVector(0, 0);
    _cellX = 0;
    _cellY = 0;
    _spawnX = 0;
    _spawnY = 0;
    _size = CELL_SIZE * 0.8; // taille un peu plus petite que la cellule
    _direction = new PVector(0, 0);
    _targetCell = new PVector(0, 0);
    _moving = false;
    _speed = 1.8; // vitesse un peu moins rapide que pacman (2.0)
    _type = type;
    // Blinky commence en CHASE pour suivre directemant
    _mode = (type == GhostType.BLINKY) ? GhostMode.CHASE : GhostMode.SCATTER;
    
    _scatterTimer = 0;
    _chaseTimer = 0;
    _behaviorChangeTimer = 0;
    _respawnTimer = 0; // timer de reapparition
    
    _animFrame = 0;
    _animTimer = 0;
    
    // configuration des couleurs et nom selon le type
    // chacun a sa propre couleur pour les reconnaitre
    switch(type) {
      case BLINKY: // le fantome rouge, il est aggressif
        _color = color(255, 0, 0);
        _name = "Blinky";
        _spriteX = 0;
        _spriteY = 0;
        break;
      case PINKY: // le fantome rose, il essai de te coincer
        _color = color(255, 184, 255);
        _name = "Pinky";
        _spriteX = 0;
        _spriteY = 1;
        break;
      case INKY: // fantome bleu, comportemant imprevisibl
        _color = color(0, 255, 255);
        _name = "Inky";
        _spriteX = 0;
        _spriteY = 2;
        break;
      case CLYDE: // fantome orange, change de direction aleatoirement
        _color = color(255, 184, 82);
        _name = "Clyde";
        _spriteX = 0;
        _spriteY = 3;
        break;
    }
  }
  
  void init(int cellX, int cellY, Board board) {
    // initialise la position du fantome sur le plateau
    // il faut d'abord sauvegarder la position de depart
    _cellX = cellX;
    _cellY = cellY;
    _spawnX = cellX; // position de spawn pour revenir quand il est mangé
    _spawnY = cellY;
    PVector center = board.getCellCenter(_cellY, _cellX);
    _position = center.copy();
    _posOffset = new PVector(0, 0);
    _direction = new PVector(0, -1); // direction vers le haut au debut
    _moving = true;
    
    // Tous les fantômes commencent en mode LEAVING_HOME pour sortir de la cage
    _mode = GhostMode.LEAVING_HOME;
    // Blinky passe direct en CHASE apres avoir sorti de la cage
    if (_type == GhostType.BLINKY) {
      _chaseTimer = 999999; // timer tres long pour rester en chase
    } else {
      _chaseTimer = 0;
    }
    _scatterTimer = 0;
    
    // Load sprite sheet if not already loaded
    if (ghostSpriteSheet == null) {
      try {
        ghostSpriteSheet = loadImage("data/img/pacman_sprites.png");
      } catch (Exception e) {
        println("Warning: Could not load ghost sprites");
      }
    }
  }
  
  // cette methode calcul la cible du fantome selon son mode
  // chaque type de fantome a sa propre strategie
  void updateTarget(Hero hero, Board board) {
    int heroX = hero.getCellX();
    int heroY = hero.getCellY();
    
    if (_mode == GhostMode.LEAVING_HOME) {
      // le fantome doi sortir de la cage d'abord
      // on vise une cellule au dessus pour sortir
      _targetCell = new PVector(_cellX, _cellY - 5);
      
      // Si on est sorti de la cage (plus de VOID autour), passer en mode CHASE
      if (board.getCellType(_cellY, _cellX) != TypeCell.VOID &&
          board.getCellType(_cellY - 1, _cellX) != TypeCell.VOID &&
          board.getCellType(_cellY + 1, _cellX) != TypeCell.VOID) {
        _mode = GhostMode.CHASE;
        _chaseTimer = 999999;
      }
      return; // pas besoin de continuer si en LEAVING_HOME
    }
    
    if (_mode == GhostMode.FRIGHTENED) {
      // fuit aleatoirment
      if (_behaviorChangeTimer <= 0) {
        _targetCell = new PVector(
          int(random(board._nbCellsX)),
          int(random(board._nbCellsY))
        );
        _behaviorChangeTimer = 60;
      }
      return;
    }
    
    if (_mode == GhostMode.EATEN) {
      // retourne au spawn
      _targetCell = new PVector(_spawnX, _spawnY);
      return;
    }
    
    // Comportements des fantomes (BLINKY ignore SCATTER/CHASE)
    PVector heroDir = hero._direction;
    
    if (_type == GhostType.BLINKY) {
      // Blinky suit TOUJOURS pacman peu importe le mode
      _targetCell = new PVector(heroX, heroY);
    }
    else if (_mode == GhostMode.SCATTER) {
      // en mode scatter chaque fantome va dans son coin (sauf Blinky qui suit toujours)
      switch(_type) {
        case BLINKY:
          // deja geré avant, ne rien faire
          break;
        case PINKY:
          _targetCell = new PVector(2, 0);
          break;
        case INKY:
          _targetCell = new PVector(board._nbCellsX - 2, board._nbCellsY - 2);
          break;
        case CLYDE:
          _targetCell = new PVector(2, board._nbCellsY - 2);
          break;
      }
    } 
    else if (_mode == GhostMode.CHASE) {
      
      switch(_type) {
        case BLINKY:
          // deja geré avant, ne rien faire
          break;
        case PINKY: // Speedy - vise l'endroit où se dirige Pac-Man
          int ahead = 4;
          // Pinky vise 4 cases devant Pac-Man dans sa direction actuelle
          _targetCell = new PVector(
            heroX + int(heroDir.x) * ahead,
            heroY + int(heroDir.y) * ahead
          );
          break;
          
        case INKY: // Bashful - de temps en temps, part dans la direction opposée de Pac-Man
          if (_behaviorChangeTimer <= 0) {
            // 35% de chance de partir dans la direction opposée
            if (random(1) < 0.35) {
              // Calcule un point à l'opposé de Pac-Man
              int oppositeX = _cellX + (_cellX - heroX);
              int oppositeY = _cellY + (_cellY - heroY);
              _targetCell = new PVector(oppositeX, oppositeY);
            } else {
              // Sinon, suit Pac-Man normalement
              _targetCell = new PVector(heroX, heroY);
            }
            _behaviorChangeTimer = 100; // Change de comportement toutes les ~1.7 secondes
          }
          break;
          
        case CLYDE: // Pokey - de temps en temps, change de direction
          if (_behaviorChangeTimer <= 0) {
            // 40% de chance de changer de direction aleatoirement
            if (random(1) < 0.40) {
              // Choisit une cible aleatoire sur le plateau
              _targetCell = new PVector(
                int(random(2, board._nbCellsX - 2)),
                int(random(2, board._nbCellsY - 2))
              );
            } else {
              // Sinon, suit Pac-Man
              _targetCell = new PVector(heroX, heroY);
            }
            _behaviorChangeTimer = 120; // Change de comportemant toute les 2 secondes
          }
          break;
      }
    }
    else if (_mode == GhostMode.FRIGHTENED) {
      // Les fantômes fuient en changeant de direction aléatoirement
      if (_behaviorChangeTimer <= 0) {
        // Choisit une direction aléatoire
        _targetCell = new PVector(
          int(random(board._nbCellsX)),
          int(random(board._nbCellsY))
        );
        _behaviorChangeTimer = 60; // Change de direction toutes les secondes
      }
    }
    else if (_mode == GhostMode.EATEN) {
      // Return to spawn
      _targetCell = new PVector(_spawnX, _spawnY);
    }
    
    // Update timers
    if (_behaviorChangeTimer > 0) {
      _behaviorChangeTimer--;
    }
  }
  
  // Choose next direction based on target
  PVector chooseDirection(Board board) {
    PVector[] possibleDirections = {
      new PVector(0, -1), // UP
      new PVector(0, 1),  // DOWN
      new PVector(-1, 0), // LEFT
      new PVector(1, 0)   // RIGHT
    };
    
    float minDist = Float.MAX_VALUE;
    PVector bestDir = new PVector(0, 0); // direction par defaut
    boolean foundValidDir = false;
    
    for (PVector dir : possibleDirections) {
      // Seul Blinky peut revenir en arriere en permanance
      // Les autres seulement en mode EATEN ou LEAVING_HOME
      boolean canGoBackwards = (_type == GhostType.BLINKY) || (_mode == GhostMode.EATEN) || (_mode == GhostMode.LEAVING_HOME);
      
      if (!canGoBackwards && _moving) {
        // Don't go backwards
        if (dir.x == -_direction.x && dir.y == -_direction.y) {
          continue;
        }
      }
      
      int nextX = _cellX + int(dir.x);
      int nextY = _cellY + int(dir.y);
      
      // En mode EATEN ou LEAVING_HOME, les fantômes peuvent traverser les murs
      boolean canMove = (_mode == GhostMode.EATEN || _mode == GhostMode.LEAVING_HOME) || !board.isWallForGhost(nextY, nextX);
      
      // Empecher les fantomes de retourner dans la cage (VOID) sauf en mode EATEN
      if (_mode != GhostMode.EATEN && _mode != GhostMode.LEAVING_HOME) {
        if (board.getCellType(nextY, nextX) == TypeCell.VOID) {
          canMove = false; // pas de retour dans la cage
        }
      }
      
      if (canMove) {
        float dist = dist(nextX, nextY, _targetCell.x, _targetCell.y);
        if (dist < minDist) {
          minDist = dist;
          bestDir = dir.copy();
          foundValidDir = true;
        }
      }
    }
    
    // Si aucune direction trouvée, garder la direction actuelle
    if (!foundValidDir && _direction.mag() > 0) {
      bestDir = _direction.copy();
    }
    
    return bestDir;
  }
  
  void move(Board board) {
    // En mode EATEN, LEAVING_HOME ou Blinky en CHASE, toujours recalculer la direction
    if (_mode == GhostMode.EATEN || _mode == GhostMode.LEAVING_HOME || 
        (_type == GhostType.BLINKY && _mode == GhostMode.CHASE)) {
      _direction = chooseDirection(board);
      if (_direction.mag() > 0) {
        _moving = true;
      }
    }
    
    if (!_moving) {
      // Choose new direction
      _direction = chooseDirection(board);
      if (_direction.mag() > 0) {
        _moving = true;
      }
    }
    
    if (_moving) {
      // Ajuste la vitesse selon le mod
      float currentSpeed = _speed;
      if (_mode == GhostMode.FRIGHTENED) {
        currentSpeed = _speed * 0.5; // 50% plus lent en mode frightened
      } else if (_mode == GhostMode.EATEN) {
        currentSpeed = _speed * 1.5; // Plus rapide pour retourner au spawn
      } else if (_mode == GhostMode.LEAVING_HOME) {
        currentSpeed = _speed * 0.8; // Un peu plus lent en sortant
      }
      
      _posOffset.add(PVector.mult(_direction, currentSpeed));
      
      // Check if we've moved to the next cell
      if (_posOffset.mag() >= CELL_SIZE) {
        // Update cell position
        _cellX += int(_direction.x);
        _cellY += int(_direction.y);
        
        // Téléportation aux bords du labyrinthe
        if (_cellX < 0) {
          _cellX = board._nbCellsX - 1;
          _position = board.getCellCenter(_cellY, _cellX).copy();
          _posOffset.set(0, 0);
        } else if (_cellX >= board._nbCellsX) {
          _cellX = 0;
          _position = board.getCellCenter(_cellY, _cellX).copy();
          _posOffset.set(0, 0);
        }
        
        if (_cellY < 0) {
          _cellY = board._nbCellsY - 1;
          _position = board.getCellCenter(_cellY, _cellX).copy();
          _posOffset.set(0, 0);
        } else if (_cellY >= board._nbCellsY) {
          _cellY = 0;
          _position = board.getCellCenter(_cellY, _cellX).copy();
          _posOffset.set(0, 0);
        }
        
        // Reset offset
        _posOffset.set(0, 0);
        
        // Update actual position
        PVector center = board.getCellCenter(_cellY, _cellX);
        _position = center.copy();
        
        // En mode EATEN ou LEAVING_HOME, toujours continuer à bouger
        if (_mode == GhostMode.EATEN || _mode == GhostMode.LEAVING_HOME) {
          _moving = false; // Recalculer la direction
        } else if (_type == GhostType.BLINKY && _mode != GhostMode.LEAVING_HOME) {
          // Blinky recalcule sa direction a chaque cellule pour bien suivre (sauf en sortant)
          _moving = false;
        } else {
          // Check if we can continue moving
          if (!board.isWallForGhost(_cellY + int(_direction.y), _cellX + int(_direction.x))) {
            _moving = true;
          } else {
            _moving = false;
            _direction.set(0, 0);
          }
        }
      }
    }
  }
  
  void update(Hero hero, Board board) {
    // Vérifier si le fantôme mangé est arrivé à la cage
    if (_mode == GhostMode.EATEN) {
      // Vérifier si on est proche du spawn (dans un rayon de 1 case)
      float distToSpawn = dist(_cellX, _cellY, _spawnX, _spawnY);
      if (distToSpawn < 1.5) {
        // Arrivé au spawn, repositionner exactement et commencer le timer
        if (_respawnTimer == 0) {
          _cellX = _spawnX;
          _cellY = _spawnY;
          PVector center = board.getCellCenter(_cellY, _cellX);
          _position = center.copy();
          _posOffset.set(0, 0);
          _respawnTimer = 180; // 3 secondes
          _moving = false;
          println(_name + " est arrivé à la cage ("+_spawnX+","+_spawnY+"), attente de 3 secondes...");
        }
      }
    }
    
    // Gestion du timer de respawn
    if (_respawnTimer > 0) {
      _respawnTimer--;
      if (_respawnTimer == 0) {
        // Ressortir de la cage
        _mode = GhostMode.LEAVING_HOME;
        _behaviorChangeTimer = 0;
        println(_name + " ressort de la cage !");
      }
      return; // Ne pas bouger pendant le respawn
    }
    
    // Update mode timers
    if (_mode == GhostMode.SCATTER) {
      _scatterTimer--;
      if (_scatterTimer <= 0) {
        _mode = GhostMode.CHASE;
        _chaseTimer = 1200; // Chase for 20 seconds pour voir les comportements
        _behaviorChangeTimer = 0; // Reset behavior timer
      }
    } else if (_mode == GhostMode.CHASE) {
      _chaseTimer--;
      if (_chaseTimer <= 0) {
        _mode = GhostMode.SCATTER;
        _scatterTimer = 200; // Scatter for 3 seconds
      }
    }
    
    // Update target and move
    updateTarget(hero, board);
    move(board);
    
    // Update animation
    _animTimer++;
    if (_animTimer > 10) {
      _animFrame = (_animFrame + 1) % 2;
      _animTimer = 0;
    }
  }
  
  void drawIt() {
    pushMatrix();
    
    // Calculate draw position
    float drawX = _position.x + _posOffset.x;
    float drawY = _position.y + _posOffset.y;
    
    translate(drawX, drawY);
    
    // Si le fantôme est mangé, afficher seulement les yeux
    if (_mode == GhostMode.EATEN) {
      // Yeux uniquement
      fill(255); // White
      ellipse(-_size * 0.15, -_size * 0.1, _size * 0.25, _size * 0.3);
      ellipse(_size * 0.15, -_size * 0.1, _size * 0.25, _size * 0.3);
      
      // Pupilles regardant vers le spawn
      fill(0, 0, 255); // Blue
      float pupilOffsetX = 0;
      float pupilOffsetY = 0;
      
      if (_direction.mag() > 0) {
        pupilOffsetX = _direction.x * _size * 0.05;
        pupilOffsetY = _direction.y * _size * 0.05;
      }
      
      ellipse(-_size * 0.15 + pupilOffsetX, -_size * 0.1 + pupilOffsetY, _size * 0.12, _size * 0.15);
      ellipse(_size * 0.15 + pupilOffsetX, -_size * 0.1 + pupilOffsetY, _size * 0.12, _size * 0.15);
      
      popMatrix();
      return;
    }
    
    // Draw ghost body - couleur change en mode frightened
    if (_mode == GhostMode.FRIGHTENED) {
      fill(33, 33, 222); // Bleu foncé quand effrayé
    } else {
      fill(_color); // Couleur normale
    }
    noStroke();
    
    // Simple ghost shape (can be replaced with sprites later)
    // Top half circle
    arc(0, 0, _size, _size, PI, TWO_PI, CHORD);
    // Bottom rectangle with wave
    rect(-_size/2, 0, _size, _size/2);
    
    // Wave pattern at bottom
    if (_mode == GhostMode.FRIGHTENED) {
      fill(33, 33, 222);
    } else {
      fill(_color);
    }
    float waveSize = _size / 6;
    for (int i = 0; i < 3; i++) {
      float x = -_size/2 + i * waveSize * 2 + waveSize;
      arc(x, _size/2, waveSize * 2, waveSize * 2, 0, PI, CHORD);
    }
    
    // Draw eyes - différents en mode frightened
    if (_mode == GhostMode.FRIGHTENED) {
      // Yeux effrayés (blancs avec pupilles roses)
      fill(255, 255, 255); // Blanc
      ellipse(-_size * 0.15, -_size * 0.1, _size * 0.2, _size * 0.25);
      ellipse(_size * 0.15, -_size * 0.1, _size * 0.2, _size * 0.25);
      
      // Pupilles roses qui bougent
      fill(255, 192, 203); // Rose
      ellipse(-_size * 0.15, -_size * 0.12, _size * 0.08, _size * 0.1);
      ellipse(_size * 0.15, -_size * 0.12, _size * 0.08, _size * 0.1);
      
      // Bouche effrayée
      fill(255, 255, 255);
      for (int i = 0; i < 3; i++) {
        rect(-_size * 0.2 + i * _size * 0.15, _size * 0.1, _size * 0.08, _size * 0.15);
      }
    } else {
      // Yeux normaux
      fill(255); // White
      ellipse(-_size * 0.15, -_size * 0.1, _size * 0.25, _size * 0.3);
      ellipse(_size * 0.15, -_size * 0.1, _size * 0.25, _size * 0.3);
      
      // Draw pupils
      fill(0, 0, 255); // Blue
      float pupilOffsetX = 0;
      float pupilOffsetY = 0;
      
      // Pupils look in direction of movement
      if (_direction.mag() > 0) {
        pupilOffsetX = _direction.x * _size * 0.05;
        pupilOffsetY = _direction.y * _size * 0.05;
      }
      
      ellipse(-_size * 0.15 + pupilOffsetX, -_size * 0.1 + pupilOffsetY, _size * 0.12, _size * 0.15);
      ellipse(_size * 0.15 + pupilOffsetX, -_size * 0.1 + pupilOffsetY, _size * 0.12, _size * 0.15);
    }
    
    popMatrix();
  }
  
  int getCellX() {
    return _cellX;
  }
  
  int getCellY() {
    return _cellY;
  }
  
  void setMode(GhostMode mode) {
    _mode = mode;
  }
  
  boolean collidesWith(Hero hero) {
    return _cellX == hero.getCellX() && _cellY == hero.getCellY();
  }
}
