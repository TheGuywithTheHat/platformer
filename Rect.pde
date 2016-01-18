class Rect {
  float x, y, sizeX, sizeY;
  color fillColor;
  
  Rect(float x, float y, float sizeX, float sizeY) {
    this.x = x;
    this.y = y;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    fillColor = color(0);
  }
  
  boolean collides(Rect other) {
    float x1 = x;
    float y1 = y;
    float w1 = sizeX;
    float h1 = sizeY;
    float x2 = other.x;
    float y2 = other.y;
    float w2 = other.sizeX;
    float h2 = other.sizeY;
    
    return (((x1 <= x2) && (x2 <= x1 + w1)) ||
            ((x2 <= x1) && (x1 <= x2 + w2))) &&
           (((y1 <= y2) && (y2 <= y1 + h1)) ||
            ((y2 <= y1) && (y1 <= y2 + h2)));
  }
  
  boolean intersects(Rect other) {
    float x1 = x;
    float y1 = y;
    float w1 = sizeX;
    float h1 = sizeY;
    float x2 = other.x;
    float y2 = other.y;
    float w2 = other.sizeX;
    float h2 = other.sizeY;
    
    return (((x1 < x2) && (x2 < x1 + w1)) ||
            ((x2 < x1) && (x1 < x2 + w2))) &&
           (((y1 < y2) && (y2 < y1 + h1)) ||
            ((y2 < y1) && (y1 < y2 + h2)));
  }
  
  boolean collides(float px, float py) {
    return px >= x && px <= x + sizeX && py >= y && py <= y + sizeY;
  }
  
  List<Box> getCollisions() {
    List<Box> collisions = new ArrayList();
    Rect newPos = new Rect(x, y, sizeX, sizeY);
    for(Box box : map) {
      if(box.collides(newPos)) {
        collisions.add(box);
      }
    }
    
    return collisions;
  }
  
  List<Box> getIntersections() {
    List<Box> intersections = new ArrayList();
    Rect newPos = new Rect(x, y, sizeX, sizeY);
    for(Box box : map) {
      if(box.intersects(newPos)) {
        intersections.add(box);
      }
    }
    
    return intersections;
  }
  
  void draw() {
    noStroke();
    fill(fillColor);
    rect(x, y, sizeX, sizeY);
  }
}

class MovingRect extends Rect {
  float vx, vy;
  
  MovingRect(float x, float y, float sizeX, float sizeY) {
    super(x, y, sizeX, sizeY);
  }
  
  void move() {
    x += vx;
    y += vy;
  }
}

void spawnParticles(float x, float y, float vx, float vy, color fillColor, int number) {
  particles.ensureCapacity(particles.size() + number);
  for(int i = 0; i < number; i++) {
    spawnParticle(x, y, vx, vy, fillColor);
  }
}

void spawnParticle(float x, float y, float vx, float vy, color fillColor) {
  particles.add(new Particle(x, y, vx, vy, fillColor));
}

class Particle extends MovingRect {
  Particle(float x, float y, float vx, float vy, color fillColor) {
    this(x, y, random(4, 7));
    this.vx = vx + random(-2, 2);
    this.vy = vy + random(-1, 1);
    this.fillColor = fillColor;
  }
  
  private Particle(float x, float y, float size) {
    super(x, y, size, size);
  }
  
  void update() {
    vx *= 0.98;
    vy += gravity / 2;
    super.move();
    if(x < -sizeX || x > mapSizeX + sizeX || y > mapSizeY + sizeY) {
      particles.remove(this);
    }
  }
  
  void draw() {
    pushMatrix();
      noStroke();
      fill(fillColor);
      
      translate(x, y);
      rotate(x / 10);
      
      rect(-sizeX / 2, -sizeY / 2, sizeX, sizeY);
    popMatrix();
  }
}