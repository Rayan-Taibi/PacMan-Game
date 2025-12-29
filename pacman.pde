Game game;

void setup() {
  println("Starthoing setup...");
  size(460, 440, P2D);
  println("Size set");
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
