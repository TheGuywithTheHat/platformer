Box[] map;
ArrayList<Particle> particles;

final float mapSizeX = 2000;
final float mapSizeY = 1000;

void setupMap() {
 map = new Box[] {
      new Box(0, 0, mapSizeX, 0),
      new Box(0, 0, 0, mapSizeY),
      new Box(0, mapSizeY, mapSizeX, 0),
      new Box(mapSizeX, 0, 0, mapSizeY),
      
      new Box(300, 100, 20, 600),
      new Box(100, 200, 200, 20),
      new Box(100, 550, 40, 40),
      new Box(100, 700, 40, 40),
      new Box(100, 850, 40, 40),
      new Platform(350, 500, 250),
      new Platform(600, 650, 250),
      new Platform(850, 800, 250),
      new Platform(475, 350, 250),
      new Platform(600, 200, 250),
      new Box(1000, 400, 60, 60),
      new Box(1100, 250, 400, 20),
      new Box(1500, 250, 20, 500),
      new Box(1700, 250, 20, 500)
    };
    
    /*map = new Box[] {
      new Box(0, 0, mapSizeX, 0),
      new Box(0, 0, 0, mapSizeY),
      new Box(0, mapSizeY, mapSizeX, 0),
      new Box(mapSizeX, 0, 0, mapSizeY),
      
      new Box(200, 200, 200, 20),
      new Box(200, 1100, 40, 40),
      new Platform(700, 1000, 250),
      new Platform(1700, 1600, 250),
      new Box(2000, 800, 60, 60),
      new Box(2200, 500, 400, 20),
      new Box(3400, 500, 20, 500)
    };*/
  
  particles = new ArrayList(0);
}

void drawMap() {
  for(Box box : map) {
    box.draw();
  }
}

boolean pointCollides(float x, float y) {
  for(Box box : map) {
    if(box.collides(x, y)) {
      return true;
    }
  }
  
  return false;
}

class Box extends Rect {
  Box(float x, float y, float sizeX, float sizeY) {
    super(x, y, sizeX, sizeY);
    fillColor = 64;
  }
  
  void draw() {
    stroke(fillColor);
    strokeWeight(1);
    fill(fillColor);
    rect(x, y, sizeX, sizeY);
  }
}

class Platform extends Box {
  Platform(float x, float y, float sizeX) {
    super(x, y, sizeX, 1);
  }
}
