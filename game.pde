enum GameState {
  MENU, PLAYING, PAUSED, GAME_OVER, WON, HIGHSCORES
}

class Game 
{
  Board _board;
  Hero _hero;
  ArrayList<Ghost> _ghosts;
  Menu _menu;
  
  String _levelName;
  GameState _state;
  
  int _score;
  int _lives;
  int _frightenedTimer;
  int _ghostsEatenInSequence; // Nombre de fantômes mangés pendant le mode frightened
  int _lastLifeBonusScore; // Dernier score où une vie bonus a été donnée
  int _bonusTimer; // Timer pour l'apparition des bonus
  
  ArrayList<Integer> _highScores;
  
  Game() {
    _board = null;
    _hero = null;
    _ghosts = new ArrayList<Ghost>();
    _menu = new Menu();
    _levelName = "levels/level1.txt";
    _state = GameState.MENU;
    _score = 0;
    _lives = 3;
    _frightenedTimer = 0;
    _ghostsEatenInSequence = 0;
    _lastLifeBonusScore = 0;
    _bonusTimer = 0;
    _highScores = new ArrayList<Integer>();
    
    loadHighScores();
    
    println("Game initialized successfully");
  }
  
  void startGame() {
    // Create board
    _board = new Board(new PVector(0, 0), 23, 22, CELL_SIZE);
    _board.chargeLevel(_levelName);
    
    // Create hero
    _hero = new Hero();
    _hero.initialisation(int(_board._departPacman.x), int(_board._departPacman.y), _board);
    
    // Create ghosts
    _ghosts.clear();
    
    // Place ghosts in the cage (center area with VOID cells)
    // Default ghost positions inside the cage
    int cageX = _board._nbCellsX / 2;
    int cageY = 10; // ligne de la cage
    _board._departFantomes.clear();
    _board._departFantomes.add(new PVector(cageX - 1, cageY));
    _board._departFantomes.add(new PVector(cageX, cageY));
    _board._departFantomes.add(new PVector(cageX + 1, cageY));
    _board._departFantomes.add(new PVector(cageX, cageY + 1));
    
    // Create 4 ghosts with different types
    GhostType[] types = {GhostType.BLINKY, GhostType.PINKY, GhostType.INKY, GhostType.CLYDE};
    for (int i = 0; i < min(4, _board._departFantomes.size()); i++) {
      Ghost ghost = new Ghost(types[i]);
      PVector spawnPos = _board._departFantomes.get(i);
      ghost.init(int(spawnPos.x), int(spawnPos.y), _board);
      _ghosts.add(ghost);
    }
    
    _score = 0;
    _lives = 3;
    _frightenedTimer = 0;
    _ghostsEatenInSequence = 0;
    _lastLifeBonusScore = 0;
    _bonusTimer = 600; // Premier bonus après 10 secondes
    _state = GameState.PLAYING;
  }
  
  void restartGame() {
    startGame();
  }
  
  void update() {
    if (_state == GameState.PLAYING) {
      // Update hero
      if (_hero != null && _board != null) {
        _hero.update(_board);
      }
      
      // Update ghosts
      if (_ghosts != null) {
        for (Ghost ghost : _ghosts) {
          if (ghost != null) {
            ghost.update(_hero, _board);
            
            // Check collision with hero
            if (ghost.collidesWith(_hero)) {
              if (_frightenedTimer > 0 && ghost._mode == GhostMode.FRIGHTENED) {
                // Ghost is frightened, Pacman eats it
                // Points doublés: 200, 400, 800, 1600
                int ghostScore = 200 * int(pow(2, _ghostsEatenInSequence));
                _score += ghostScore;
                _ghostsEatenInSequence++;
                ghost.setMode(GhostMode.EATEN);
                ghost._respawnTimer = 0; // Reset le timer pour déclencher le retour
                println(ghost._name + " a été mangé ! +" + ghostScore + " points (séquence: " + _ghostsEatenInSequence + ")");
              } else if (ghost._mode != GhostMode.EATEN) {
                // Pacman loses a life
                _lives--;
                if (_lives <= 0) {
                  _state = GameState.GAME_OVER;
                  saveHighScores(); // Save score when game over
                } else {
                  // Reset positions
                  _hero.initialisation(int(_board._departPacman.x), int(_board._departPacman.y), _board);
                  for (int i = 0; i < _ghosts.size(); i++) {
                    Ghost g = _ghosts.get(i);
                    PVector spawnPos = _board._departFantomes.get(i);
                    g.init(int(spawnPos.x), int(spawnPos.y), _board);
                  }
                }
                return; // Skip rest of update
              }
            }
          }
        }
      }
      
      // Update frightened timer
      if (_frightenedTimer > 0) {
        _frightenedTimer--;
        if (_frightenedTimer == 0 && _ghosts != null) {
          // Ghosts return to normal
          for (Ghost ghost : _ghosts) {
            if (ghost != null && ghost._mode == GhostMode.FRIGHTENED) {
              ghost.setMode(GhostMode.CHASE);
            }
          }
          // Réinitialiser le compteur de fantômes mangés
          _ghostsEatenInSequence = 0;
        }
      }
      
      // Gestion du timer de bonus
      if (_bonusTimer > 0) {
        _bonusTimer--;
        if (_bonusTimer == 0 && !_board._bonusVisible) {
          // Faire apparaître un bonus
          _board.afficherBonus();
          println("Un fruit bonus est apparu !");
          _bonusTimer = 1200; // Prochain bonus dans 20 secondes
        }
      }
      
      // Check if hero ate a dot
      if (_hero != null && _board != null) {
        int heroX = _hero.getCellX();
        int heroY = _hero.getCellY();
        TypeCell cellType = _board.getCellType(heroY, heroX);
        
        if (cellType == TypeCell.DOT) {
          _score += SCORE_DOT;
          _board.mangerPoint(heroY, heroX);
        } else if (cellType == TypeCell.SUPER_DOT) {
          _score += SCORE_SUPER_DOT;
          _board.mangerPoint(heroY, heroX);
          
          // Activate frightened mode for ghosts
          _frightenedTimer = FRIGHTENED_TIME;
          _ghostsEatenInSequence = 0; // Réinitialiser le compteur
          if (_ghosts != null) {
            for (Ghost ghost : _ghosts) {
              if (ghost != null) {
                ghost.setMode(GhostMode.FRIGHTENED);
              }
            }
          }
        } else if (cellType == TypeCell.BONUS) {
          _score += SCORE_BONUS_FRUIT;
          _board.mangerBonus(heroY, heroX);
          println("Fruit bonus mangé ! +500 points");
        }
        
        // Vérifier si le joueur gagne une vie bonus
        if (_score >= _lastLifeBonusScore + LIFE_BONUS_SCORE) {
          _lives++;
          _lastLifeBonusScore += LIFE_BONUS_SCORE;
          println("Vie bonus gagnée ! Vies: " + _lives);
        }
        
        // Check if all dots are eaten
        if (_board.tousPointsManges()) {
          _state = GameState.WON;
          saveHighScores(); // Save score when won
        }
      }
    }
  }
  
  void drawIt() {
    background(0);
    
    try {
      // Only draw based on current state - don't draw board in MENU
      if (_state == GameState.MENU) {
        if (_menu != null) {
          _menu.drawIt();
        }
        return; // Exit early, don't draw anything else
      }
      
      switch(_state) {
        case MENU:
          if (_menu != null) {
            _menu.drawIt();
          }
          break;
          
        case PLAYING:
          // Draw board
          if (_board != null) {
            _board.drawIt();
          }
          
          // Draw ghosts
          if (_ghosts != null) {
            for (Ghost ghost : _ghosts) {
              if (ghost != null) {
                ghost.drawIt();
              }
            }
          }
          
          // Draw hero
          if (_hero != null) {
            _hero.drawIt();
          }
          
          // Draw HUD
          drawHUD();
          break;
          
        case PAUSED:
          // Draw board and hero
          if (_board != null) {
            _board.drawIt();
          }
          if (_ghosts != null) {
            for (Ghost ghost : _ghosts) {
              if (ghost != null) {
                ghost.drawIt();
              }
            }
          }
          if (_hero != null) {
            _hero.drawIt();
          }
          
          // Draw pause overlay
          if (_menu != null) {
            _menu.drawPause(_score);
          }
          break;
          
        case HIGHSCORES:
          drawHighScoresScreen();
          break;
          
        case GAME_OVER:
          if (_menu != null) {
            _menu.drawGameOver(_score, false);
          }
          break;
          
        case WON:
          if (_menu != null) {
            _menu.drawGameOver(_score, true);
          }
          break;
      }
    } catch (Exception e) {
      println("Error in drawIt: " + e.getMessage());
      e.printStackTrace();
    }
  }
  
  void drawHUD() {
    // Draw score and lives
    fill(255, 255, 0);
    textAlign(LEFT, TOP);
    textSize(20);
    text("Score: " + _score, 10, 10);
    text("Vies: " + _lives, 10, 35);
  }
  
  void handleKey(int k) {
    if (_state == GameState.MENU) {
      if (k == ' ') {
        startGame();
      }
    } 
    else if (_state == GameState.PLAYING) {
      if (keyCode == ESC) {
        key = 0; // Prevent Processing from closing the sketch
        _state = GameState.PAUSED;
        _menu.resetSelection();
      } else {
        // Handle directional keys
        if (keyCode == UP) {
          _hero.launchMove(new PVector(0, -1));
        } else if (keyCode == DOWN) {
          _hero.launchMove(new PVector(0, 1));
        } else if (keyCode == LEFT) {
          _hero.launchMove(new PVector(-1, 0));
        } else if (keyCode == RIGHT) {
          _hero.launchMove(new PVector(1, 0));
        }
      }
    } 
    else if (_state == GameState.PAUSED) {
      if (keyCode == ESC) {
        key = 0; // Prevent Processing from closing the sketch
        _state = GameState.PLAYING;
      } else if (keyCode == UP) {
        _menu.navigateUp();
      } else if (keyCode == DOWN) {
        _menu.navigateDown();
      } else if (keyCode == ENTER || keyCode == RETURN) {
        handleMenuSelection();
      }
    }
    else if (_state == GameState.HIGHSCORES) {
      if (keyCode == ESC || k == 'b' || k == 'B') {
        key = 0;
        _state = GameState.PAUSED;
      }
    }
    else if (_state == GameState.GAME_OVER || _state == GameState.WON) {
      if (k == 'r' || k == 'R') {
        restartGame();
      }
    }
  }
  
  void handleMenuSelection() {
    MenuOption selected = _menu.getSelectedOption();
    
    switch(selected) {
      case RESUME:
        _state = GameState.PLAYING;
        break;
        
      case RESTART:
        restartGame();
        break;
        
      case SAVE:
        saveGame();
        break;
        
      case LOAD:
        loadGame();
        break;
        
      case HIGHSCORES:
        _state = GameState.HIGHSCORES;
        break;
        
      case QUIT:
        exit();
        break;
    }
  }
  
  void saveGame() {
    try {
      String[] lines = new String[10];
      lines[0] = str(_score);
      lines[1] = str(_lives);
      lines[2] = str(_hero.getCellX());
      lines[3] = str(_hero.getCellY());
      lines[4] = str(_hero._direction.x);
      lines[5] = str(_hero._direction.y);
      lines[6] = str(_frightenedTimer);
      lines[7] = _levelName;
      
      // Save board state (simplified - just save which dots are eaten)
      String dotsState = "";
      for (int y = 0; y < _board._nbCellsY; y++) {
        for (int x = 0; x < _board._nbCellsX; x++) {
          TypeCell cell = _board.getCellType(y, x);
          if (cell == TypeCell.EMPTY) {
            dotsState += "0";
          } else if (cell == TypeCell.DOT) {
            dotsState += "1";
          } else if (cell == TypeCell.SUPER_DOT) {
            dotsState += "2";
          } else {
            dotsState += "3";
          }
        }
      }
      lines[8] = dotsState;
      
      // Save ghosts positions
      String ghostsData = "";
      for (Ghost ghost : _ghosts) {
        ghostsData += ghost.getCellX() + "," + ghost.getCellY() + "," + ghost._direction.x + "," + ghost._direction.y + ";";
      }
      lines[9] = ghostsData;
      
      saveStrings("data/savegame.txt", lines);
      println("Partie sauvegardée !");
      
      // Show confirmation
      fill(0, 255, 0);
      textAlign(CENTER);
      textSize(20);
      text("Partie sauvegardée !", width/2, 50);
      
    } catch (Exception e) {
      println("Erreur lors de la sauvegarde : " + e.getMessage());
    }
  }
  
  void loadGame() {
    try {
      String[] lines = loadStrings("data/savegame.txt");
      
      if (lines == null || lines.length < 10) {
        println("Pas de sauvegarde trouvée !");
        return;
      }
      
      _score = int(lines[0]);
      _lives = int(lines[1]);
      int heroX = int(lines[2]);
      int heroY = int(lines[3]);
      float heroDirX = float(lines[4]);
      float heroDirY = float(lines[5]);
      _frightenedTimer = int(lines[6]);
      _levelName = lines[7];
      
      // Reload the board
      _board = new Board(new PVector(0, 0), 23, 22, CELL_SIZE);
      _board.chargeLevel(_levelName);
      
      // Restore dots state
      String dotsState = lines[8];
      int idx = 0;
      for (int y = 0; y < _board._nbCellsY; y++) {
        for (int x = 0; x < _board._nbCellsX; x++) {
          if (idx < dotsState.length()) {
            char c = dotsState.charAt(idx);
            if (c == '0') {
              _board._cells[y][x] = TypeCell.EMPTY;
            } else if (c == '1') {
              _board._cells[y][x] = TypeCell.DOT;
            } else if (c == '2') {
              _board._cells[y][x] = TypeCell.SUPER_DOT;
            }
            idx++;
          }
        }
      }
      
      // Restore hero
      _hero = new Hero();
      _hero.initialisation(heroX, heroY, _board);
      _hero._direction = new PVector(heroDirX, heroDirY);
      
      // Restore ghosts
      String[] ghostsData = split(lines[9], ";");
      _ghosts.clear();
      GhostType[] types = {GhostType.BLINKY, GhostType.PINKY, GhostType.INKY, GhostType.CLYDE};
      for (int i = 0; i < min(ghostsData.length - 1, 4); i++) {
        String[] ghostInfo = split(ghostsData[i], ",");
        if (ghostInfo.length >= 4) {
          Ghost ghost = new Ghost(types[i]);
          ghost.init(int(ghostInfo[0]), int(ghostInfo[1]), _board);
          ghost._direction = new PVector(float(ghostInfo[2]), float(ghostInfo[3]));
          _ghosts.add(ghost);
        }
      }
      
      _state = GameState.PLAYING;
      println("Partie chargée !");
      
    } catch (Exception e) {
      println("Erreur lors du chargement : " + e.getMessage());
      e.printStackTrace();
    }
  }
  
  void loadHighScores() {
    try {
      String[] lines = loadStrings("data/highscores.txt");
      if (lines != null) {
        for (String line : lines) {
          _highScores.add(int(line));
        }
      }
    } catch (Exception e) {
      println("Pas de fichier de scores trouvé, création d'une nouvelle liste.");
      _highScores = new ArrayList<Integer>();
    }
  }
  
  void saveHighScores() {
    try {
      // Add current score
      _highScores.add(_score);
      
      // Sort in descending order
      _highScores.sort((a, b) -> b - a);
      
      // Keep only top 10
      while (_highScores.size() > 10) {
        _highScores.remove(_highScores.size() - 1);
      }
      
      // Save to file
      String[] lines = new String[_highScores.size()];
      for (int i = 0; i < _highScores.size(); i++) {
        lines[i] = str(_highScores.get(i));
      }
      saveStrings("data/highscores.txt", lines);
      
    } catch (Exception e) {
      println("Erreur lors de la sauvegarde des scores : " + e.getMessage());
    }
  }
  
  void drawHighScoresScreen() {
    background(0);
    
    // Semi-transparent overlay
    fill(0, 200);
    rect(0, 0, width, height);
    
    // Box
    float boxWidth = 400;
    float boxHeight = 450;
    float boxX = (width - boxWidth) / 2;
    float boxY = (height - boxHeight) / 2;
    
    fill(20, 20, 60);
    stroke(255, 255, 0);
    strokeWeight(3);
    rect(boxX, boxY, boxWidth, boxHeight, 10);
    
    // Title
    noStroke();
    textAlign(CENTER, CENTER);
    fill(255, 255, 0);
    textSize(36);
    text("MEILLEURS SCORES", width/2, boxY + 40);
    
    // Scores
    textSize(24);
    float startY = boxY + 100;
    
    if (_highScores.size() == 0) {
      fill(200);
      text("Aucun score enregistré", width/2, startY + 100);
    } else {
      for (int i = 0; i < _highScores.size(); i++) {
        fill(255);
        String rank = (i + 1) + ".";
        text(rank, width/2 - 100, startY + i * 35);
        fill(255, 255, 0);
        text(_highScores.get(i), width/2 + 50, startY + i * 35);
      }
    }
    
    // Instructions
    textSize(16);
    fill(150);
    text("Appuyez sur ECHAP pour retourner", width/2, boxY + boxHeight - 30);
  }
  
  
  
}