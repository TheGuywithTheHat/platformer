Player player;
Character[] enemies;

long lastTime;
long currentTime;
long deltaTime;
int tickRate = 60;
float deltaTick;

Game game;

float screenXOffset;
float screenYOffset;

void setup() {
  fullScreen();
  textAlign(LEFT, TOP);
  
  setupInput();
  game = new Game();
  currentTime = millis();
}

void draw() {
  lastTime = currentTime;
  currentTime = millis();
  deltaTime = currentTime - lastTime;
  deltaTick = (float)(deltaTime) / 1000 * tickRate;
  
  update();
  render();
  println(frameRate);
}

void update() {
  game.update();
  
  for(int i = 0; i < particles.size(); i++) {
    particles.get(i).update();
  }
  
  screenXOffset = player.x - (width - player.sizeX) / 2;
  screenYOffset = player.y - (height - player.sizeY) / 2;
}

void render() {
  scale(0.5);
  translate(-player.x + (width * 2 - player.sizeX) / 2, -player.y + (height * 2 - player.sizeY) / 2);
  background(0);
  fill(255);
  noStroke();
  rect(0, 0, mapSizeX, mapSizeY);
  
  drawMap();
  for(Character enemy : game.getEnemies()) {
    enemy.draw();
  }
  
  if(player.alive()) {
    player.draw();
  }
  
  for(Particle particle : particles) {
    particle.draw();
  }
  drawHUD();
}

void drawHUD() {
  if(isInDebug) renderDebug();
}

void renderDebug() {
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