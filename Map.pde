Box[] map;
final float mapSizeX = 2000;
final float mapSizeY = 1000;

void setupMap() {
  map = new Box[] {
      new Box(0, 0, mapSizeX, 0),
      new Box(0, 0, 0, mapSizeY),
      new Box(0, mapSizeY, mapSizeX, 0),
      new Box(mapSizeX, 0, 0, mapSizeY),
      
      new Box(300, 100, 20, 500),
      new Box(100, 200, 200, 20),
      new Box(100, 550, 40, 40),
      new Box(100, 700, 40, 40),
      new Box(100, 850, 40, 40),
      new Box(350, 500, 250, 20),
      new Box(600, 650, 250, 20),
      new Box(850, 800, 250, 20),
      new Box(475, 350, 250, 20),
      new Box(600, 200, 250, 20),
      new Box(1000, 400, 60, 60),
      new Box(1100, 250, 400, 20),
      new Box(1500, 250, 20, 500),
      new Box(1700, 250, 20, 500),
    };
}

void drawMap() {
  for(Box box : map) {
    box.draw();
  }
}