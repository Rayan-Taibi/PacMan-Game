Game game;

void setup() {
  
  size(460, 440, P2D);
  
  game = new Game();
  
}

void draw() {
  game.update();
  game.drawIt();
}

void keyPressed() {
  game.handleKey(key);
}

void mousePressed() {
}
