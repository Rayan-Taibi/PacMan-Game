// Enum des différetes options possibles du menu pause
enum MenuOption {
  RESUME, RESTART, SAVE, LOAD, HIGHSCORES, QUIT
}

class Menu {
    // Titre principal affiché à l'écran
    String _title;
    
    // Sous-titre (instructions, messages, etc.)
    String _subtitle;
    
    // Option actuellement sélectionnée dans le menu
    MenuOption _selectedOption;

  // Constructeur par défaut du menu
  Menu() {
    _title = "PAC-MAN";
    _subtitle = "Appuyez sur ESPACE pour commencer";
    
    // Par défaut on se place sur "Continuer"
    _selectedOption = MenuOption.RESUME;
  }

  void setTitle(String title) {
    _title = title;
  }
  
  void setSubtitle(String subtitle) {
    _subtitle = subtitle;
  }

  // Affichage du menu principal (écran de départ)
  void drawIt() {
     background(0); // fond noir 
    
    // --- Titre ---
    textAlign(CENTER, CENTER);
    fill(255, 255, 0); 
    textSize(64);
    text(_title, width/2, height/3);
    
    // --- Sous-titre ---
    textSize(24);
    fill(255);
    text(_subtitle, width/2, height/2);
    
    // ---  des contrôles ---
    textSize(18);
    fill(200);
    text("Contrôles: Flèches directionnelles", width/2, height * 0.65);
    text("Menu: Echap", width/2, height * 0.72);
  }

  // Menu affiche quand le jeu est en pause
  void drawPause(int score) {
    // Fond semi-transparent pour garder le jeu visible derrière
    fill(0, 200);
    rect(0, 0, width, height);
    
    // Dimensions et position de la boîte du menu
    float boxWidth = 400;
    float boxHeight = 420;
    float boxX = (width - boxWidth) / 2;
    float boxY = (height - boxHeight) / 2;
    
    //   cadre de menu
    fill(20, 20, 60);
    stroke(255, 255, 0);
    strokeWeight(3);
    rect(boxX, boxY, boxWidth, boxHeight, 10);
    
    // Titre du menu pause
    textAlign(CENTER, CENTER);
    fill(255, 255, 0);
    textSize(42);
    noStroke();
    text("MENU", width/2, boxY + 40);
    
    // Affichage du score actuelle
    textSize(20);
    fill(255);
    text("Score: " + score, width/2, boxY + 85);
    
    // Parametres d'affichage des options
    float optionY = boxY + 130;
    float optionSpacing = 45;
    textSize(24);
    
    // Texte affiche pour chaque option
    String[] options = {
      "Continuer",
      "Recommencer",  
      "Sauvegarder",
      "Charger",
      "Meilleurs Scores",
      "Quitter"
    };
    
    // Correspondance avec l'enum MenuOption
    MenuOption[] optionValues = {
      MenuOption.RESUME,
      MenuOption.RESTART,
      MenuOption.SAVE,
      MenuOption.LOAD,
      MenuOption.HIGHSCORES,
      MenuOption.QUIT
    };
    
    // affichage des options
    for (int i = 0; i < options.length; i++) {
      if (optionValues[i] == _selectedOption) {
        // Option actuellement sélectionnée
        fill(255, 255, 0);
        text("> " + options[i] + " <", width/2, optionY + i * optionSpacing);
      } else {
        // Options non sélectionnées
        fill(200);
        text(options[i], width/2, optionY + i * optionSpacing);
      }
    }  
  }

  // ecran de fin de partie
  void drawGameOver(int score, boolean won) {
    background(0);
    textAlign(CENTER, CENTER);
    
    // Message différent selon victoire ou défaite
    if (won) {
      fill(0, 255, 0);
      textSize(64);
      text("VICTOIRE!", width/2, height/3);
    } else {
      fill(255, 0, 0);
      textSize(64);
      text("GAME OVER", width/2, height/3);
    }
    
    // Score final
    fill(255, 255, 0);
    textSize(32);
    text("Score Final: " + score, width/2, height/2);
    
    // pour recommencer
    textSize(24);
    fill(255);
    text("Appuyez sur R pour recommencer", width/2, height * 0.65);
  }
  
  // Navigation vers le haut dans le menu
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

  // Navigation vers le bas dans le menu
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

  // Récupère l'option actuellement sélectionnée
  MenuOption getSelectedOption() {
    return _selectedOption;
  }
  
  // Réinitialise la sélection (utile quand on rouvre le menu)
  void resetSelection() {
    _selectedOption = MenuOption.RESUME;
  }
}
