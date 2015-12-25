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
  
  boolean intersects(Rect other) {
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
  
  void draw() {
    noStroke();
    fill(fillColor);
    rect(x, y, sizeX, sizeY);
  }
}