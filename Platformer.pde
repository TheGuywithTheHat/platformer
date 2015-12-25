Player player;


void setup() {
  size(1900, 1000);
  setupInput();
  setupMap();
  player = new Player(100, 100);
}

void draw() {
  update();
  render();
}

void update() {
  player.update();
}

void render() {
  translate(-player.x + (width - player.sizeX) / 2, -player.y + (height - player.sizeY) / 2);
  background(0);
  fill(255);
  noStroke();
  rect(0, 0, mapSizeX, mapSizeY);
  drawMap();
  player.draw();
}