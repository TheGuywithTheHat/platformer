Player player;
Enemy[] enemies;

Game game;

void setup() {
  size(1900, 1000);
  textAlign(LEFT, TOP);
  
  setupInput();
  game = new ChaseRunGame();
}

void draw() {
  update();
  render();
}

void update() {
  game.update();
  for(int i = 0; i < particles.size(); i++) {
    particles.get(i).update();
  }
}

void render() {
  translate(-player.x + (width - player.sizeX) / 2, -player.y + (height - player.sizeY) / 2);
  background(0);
  fill(255);
  noStroke();
  rect(0, 0, mapSizeX, mapSizeY);
  drawMap();
  for(Enemy enemy : enemies) {
    enemy.draw();
  }
  player.draw();
  for(Particle particle : particles) {
    particle.draw();
  }
  
  if(isInDebug) renderDebug();
}

void renderDebug() {
  resetMatrix();
  fill(128, 128);
  noStroke();
  rect(0, 16 * 0, 100, 16);
  rect(0, 16 * 1, 100, 16);
  rect(0, 16 * 2, 100, 16);
  rect(0, 16 * 3, 100, 16);
  rect(0, 16 * 4, 100, 16);
  rect(0, 16 * 5, 100, 16);
  rect(0, 16 * 6, 100, 16);
  
  fill(255);
  text(player.x + " + " + player.vx, 0, 16 * 0);
  text(player.y + " + " + player.vy, 0, 16 * 1);
  text("b:" + player.collideBot, 0, 16 * 2);
  text("t:" + player.collideTop, 0, 16 * 3);
  text("l:" + player.collideLeft, 0, 16 * 4);
  text("r:" + player.collideRight, 0, 16 * 5);
  text("p:" + player.collidePlatform, 0, 16 * 6);
}