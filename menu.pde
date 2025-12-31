enum MenuOption {
  RESUME, RESTART, SAVE, LOAD, HIGHSCORES, QUIT
}

class Menu {
    String _title;
    String _subtitle;
    MenuOption _selectedOption;

  Menu() {
    _title = "PAC-MAN";
    _subtitle = "Appuyez sur ESPACE pour commencer";
    _selectedOption = MenuOption.RESUME;
    
  }
  void setTitle(String title) {
    _title = title;
  }
  
  void setSubtitle(String subtitle) {
    _subtitle = subtitle;
  }

  void drawIt() {
     background(0);
    
    // Draw title
    textAlign(CENTER, CENTER);
    fill(255, 255, 0);
    textSize(64);
    text(_title, width/2, height/3);
    
    // Draw subtitle
    textSize(24);
    fill(255);
    text(_subtitle, width/2, height/2);
    
    // Draw controls
    textSize(18);
    fill(200);
    text("Contrôles: Flèches directionnelles", width/2, height * 0.65);
    text("Menu: Echap", width/2, height * 0.72);

  }

  void drawPause(int score) {
    // demi-transparent
    fill(0, 200);
    rect(0, 0, width, height);
    
    // Menu 
    float boxWidth = 400;
    float boxHeight = 420;
    float boxX = (width - boxWidth) / 2;
    float boxY = (height - boxHeight) / 2;
    
    // dessin du cadre 
    fill(20, 20, 60);
    stroke(255, 255, 0);
    strokeWeight(3);
    rect(boxX, boxY, boxWidth, boxHeight, 10);
    
    // texte Pause
    textAlign(CENTER, CENTER);
    fill(255, 255, 0);
    textSize(42);
    noStroke();
    text("MENU", width/2, boxY + 40);
    
    // Score
    textSize(20);
    fill(255);
    text("Score: " + score, width/2, boxY + 85);
    
    // des options du menu
    float optionY = boxY + 130;
    float optionSpacing = 45;
    textSize(24);
    
    String[] options = {
      "Continuer",
      "Recommencer",  
      "Sauvegarder",
      "Charger",
      "Meilleurs Scores",
      "Quitter"
    };
    
    MenuOption[] optionValues = {
      MenuOption.RESUME,
      MenuOption.RESTART,
      MenuOption.SAVE,
      MenuOption.LOAD,
      MenuOption.HIGHSCORES,
      MenuOption.QUIT
    };
    
    for (int i = 0; i < options.length; i++) {
      if (optionValues[i] == _selectedOption) {
        fill(255, 255, 0); // jaune pour l'option selectionnee
        text("> " + options[i] + " <", width/2, optionY + i * optionSpacing);
      } else {
        fill(200);
        text(options[i], width/2, optionY + i * optionSpacing);
      }
    }  
  }

  void drawGameOver(int score, boolean won) {
    background(0);
    
    textAlign(CENTER, CENTER);
    
    if (won) {
      fill(0, 255, 0);
      textSize(64);
      text("VICTOIRE!", width/2, height/3);
    } else {
      fill(255, 0, 0);
      textSize(64);
      text("GAME OVER", width/2, height/3);
    }
    
    // Score
    fill(255, 255, 0);
    textSize(32);
    text("Score Final: " + score, width/2, height/2);
    
    // Restart instruction
    textSize(24);
    fill(255);
    text("Appuyez sur R pour recommencer", width/2, height * 0.65);
  }
  
  void navigateUp() {
    switch(_selectedOption) {
      case RESUME:
        _selectedOption = MenuOption.QUIT;
        break;
      case RESTART:
        _selectedOption = MenuOption.RESUME;
        break;
      case SAVE:
        _selectedOption = MenuOption.RESTART;
        break;
      case LOAD:
        _selectedOption = MenuOption.SAVE;
        break;
      case HIGHSCORES:
        _selectedOption = MenuOption.LOAD;
        break;
      case QUIT:
        _selectedOption = MenuOption.HIGHSCORES;
        break;
    }
  }
  void navigateDown() {
    switch(_selectedOption) {
      case RESUME:
        _selectedOption = MenuOption.RESTART;
        break;
      case RESTART:
        _selectedOption = MenuOption.SAVE;
        break;
      case SAVE:
        _selectedOption = MenuOption.LOAD;
        break;
      case LOAD:
        _selectedOption = MenuOption.HIGHSCORES;
        break;
      case HIGHSCORES:
        _selectedOption = MenuOption.QUIT;
        break;
      case QUIT:
        _selectedOption = MenuOption.RESUME;
        break;
    }
  }
  MenuOption getSelectedOption() {
    return _selectedOption;
  }
  
  void resetSelection() {
    _selectedOption = MenuOption.RESUME;
  }
}
