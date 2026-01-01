# PacMan Game

A classic PacMan game implementation built with Processing. Navigate through mazes, collect dots, eat power pellets, and avoid ghosts while trying to achieve the highest score!

## Features

- **Classic Gameplay**: Control PacMan through mazes collecting dots and avoiding ghosts
- **Four Ghost Types**: Each with unique AI behavior patterns
  - **Blinky** (Red): Directly chases PacMan
  - **Pinky** (Pink): Targets ahead of PacMan's direction
  - **Inky** (Blue): Unpredictable behavior, sometimes moves opposite
  - **Clyde** (Orange): Random movement pattern
- **Ghost Modes**: Scatter, Chase, Frightened, and Eaten states
- **Power Pellets**: Eat power pellets to turn ghosts frightened and consume them for extra points
- **Scoring System**: 
  - Dots: Points for each pellet collected
  - Power Pellets: Bonus points and ghost-eating ability
  - Ghosts: Sequential bonus (200, 400, 800, 1600 points)
  - Bonus Life: Extra life awarded at certain score milestones
- **Lives System**: Start with 3 lives
- **High Scores**: Track top scores with player names
- **Save/Load Game**: Save your progress and continue later
- **Pause Menu**: Pause anytime with multiple options
  - Resume
  - Restart
  - Save Game
  - Load Game
  - View High Scores
  - Quit to Menu

## Requirements

- [Processing 3.0+](https://processing.org/download)

## Installation

1. Download or clone this repository
2. Open `pacman.pde` in Processing
3. Click the Run button or press Ctrl+R

## How to Play

### Controls

- **Arrow Keys**: Move PacMan (Up, Down, Left, Right)
- **SPACE**: Start game from menu
- **P**: Pause/Resume game
- **Up/Down Arrow Keys**: Navigate pause menu options
- **ENTER**: Select menu option
- **Type letters**: Enter your name for high scores

### Game Rules

1. **Objective**: Eat all dots to complete the level
2. **Avoid Ghosts**: Contact with a ghost costs one life
3. **Power Pellets**: Large pellets that make ghosts frightened (blue) for a limited time
4. **Eat Frightened Ghosts**: Consume blue ghosts for bonus points
5. **Extra Lives**: Earn bonus lives at certain score thresholds
6. **Game Over**: Lose all lives and the game ends

### Scoring

- Small Dot: 10 points
- Power Pellet: 50 points
- Ghost (sequence): 200 → 400 → 800 → 1600 points

## Project Structure

```
PacMan/
├── pacman.pde          # Main entry point
├── game.pde            # Game logic and state management
├── hero.pde            # PacMan character implementation
├── ghost.pde           # Ghost AI and behavior
├── board.pde           # Level board and maze rendering
├── menu.pde            # Menu system (main, pause, high scores)
├── constants.pde       # Game constants and configuration
├── README.md           # This file
├── data/
│   ├── highscores.txt  # High score storage
│   ├── savegame.txt    # Saved game data
│   └── img/            # Game images and sprites
└── levels/
    └── level1.txt      # Level layout definitions
```

## Game States

- **MENU**: Main menu screen
- **PLAYING**: Active gameplay
- **PAUSED**: Game paused with options menu
- **GAME_OVER**: Player lost all lives
- **WON**: Player completed the level
- **HIGHSCORES**: Display high scores table
- **ENTER_NAME**: Input name for high score entry

## Customization

### Creating New Levels

Edit or create new level files in the `levels/` directory following this format:
- `#` = Wall
- `.` = Small dot
- `*` = Power pellet
- `P` = PacMan starting position
- `G` = Ghost spawn point
- ` ` (space) = Empty path

### Adjusting Difficulty

Modify values in `constants.pde`:
- `CELL_SIZE`: Size of game cells
- Ghost speed values
- Timer durations
- Scoring values

## Credits

Developed as a Processing implementation of the classic PacMan arcade game.

## License

This project is for educational purposes. PacMan is a trademark of Bandai Namco Entertainment.

## Version

1.0 - January 2026