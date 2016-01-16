import java.util.Arrays;

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
  
  List<Rect> getCollisions(List<Rect> rects) {
    List<Rect> collisions = new ArrayList();
    for(Rect rect : rects) {
      if(rect.collides(this)) {
        collisions.add(rect);
      }
    }
    
    return collisions;
  }
  
  List<Rect> getIntersections(List<Rect> rects) {
    List<Rect> intersections = new ArrayList();
    for(Rect rect : rects) {
      if(rect.intersects(this)) {
        intersections.add(rect);
      }
    }
    
    return intersections;
  }
  
  /*List<Box> getCollisions() {
    List<Rect> boxes = new ArrayList(map.length);
    
    for(Box box : map) {
      boxes.add((Rect)(box));
    }
    
    return getCollisions(boxes);
  }
  
  List<Box> getIntersections() {
    List<Rect> boxes = new ArrayList(map.length);
    
    for(Box box : map) {
      boxes.add((Rect)(box));
    }
    
    return getIntersections(boxes);
  }*/
  
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