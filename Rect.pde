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
  
  /**
   * Gets the intersection point between a given line and this rect.
   * 
   * @param p0_x the x position of the first point on the line
   * @param p0_y the y position of the first point on the line
   * @param p1_x the x position of the second point on the line
   * @param p1_y the y position of the second point on the line
   * 
   * @return a {@code PVector} with the position of the collision nearest to the first point, or {@code null} if there is no collision
   */
  PVector getLineIntersection(float p0_x, float p0_y, float p1_x, float p1_y) {
    PVector top =   getLineIntersection(p0_x, p0_y, p1_x, p1_y, x        , y        , x + sizeX, y        );
    PVector bot =   getLineIntersection(p0_x, p0_y, p1_x, p1_y, x        , y + sizeY, x + sizeX, y + sizeY);
    PVector left =  getLineIntersection(p0_x, p0_y, p1_x, p1_y, x        , y        , x        , y + sizeY);
    PVector right = getLineIntersection(p0_x, p0_y, p1_x, p1_y, x + sizeX, y        , x + sizeX, y + sizeY);
    
    PVector intersection = null;
    float dist = Float.MAX_VALUE;
    
    if(top != null) {
      intersection = top;
      dist = intersection.dist(new PVector(p0_x, p0_y));
    }
    if(bot != null && bot.dist(new PVector(p0_x, p0_y)) < dist) {
      intersection = bot;
      dist = intersection.dist(new PVector(p0_x, p0_y));
    }
    if(left != null && left.dist(new PVector(p0_x, p0_y)) < dist) {
      intersection = left;
      dist = intersection.dist(new PVector(p0_x, p0_y));
    }
    if(right != null && right.dist(new PVector(p0_x, p0_y)) < dist) {
      intersection = right;
      dist = intersection.dist(new PVector(p0_x, p0_y));
    }
    
    return intersection;
  }
  
  /**
   * Gets the intersection point between two given lines.
   * 
   * @param p0_x the x position of the first point on the first line
   * @param p0_y the y position of the first point on the first line
   * @param p1_x the x position of the second point on the first line
   * @param p1_y the y position of the second point on the first line
   * @param p2_x the x position of the first point on the second line
   * @param p2_y the y position of the first point on the second line
   * @param p3_x the x position of the second point on the second line
   * @param p3_y the y position of the second point on the second line
   * 
   * @return a {@code PVector} with the position of the collision, or {@code null} if there is no collision
   */
  PVector getLineIntersection(float p0_x, float p0_y, float p1_x, float p1_y, float p2_x, float p2_y, float p3_x, float p3_y)
  {
    float s1_x = p1_x - p0_x;
    float s1_y = p1_y - p0_y;
    float s2_x = p3_x - p2_x;
    float s2_y = p3_y - p2_y;

    float s = (-s1_y * (p0_x - p2_x) + s1_x * (p0_y - p2_y)) / (-s2_x * s1_y + s1_x * s2_y);
    float t = ( s2_x * (p0_y - p2_y) - s2_y * (p0_x - p2_x)) / (-s2_x * s1_y + s1_x * s2_y);

    if (s >= 0 && s <= 1 && t >= 0 && t <= 1)
    {
      return new PVector(p0_x + (t * s1_x), p0_y + (t * s1_y));
    }

    return null; // No collision
  }
}

class MovingRect extends Rect {
  float vx, vy;
  
  MovingRect(float x, float y, float sizeX, float sizeY) {
    super(x, y, sizeX, sizeY);
  }
  
  void move() {
    x += vx * deltaTick;
    y += vy * deltaTick;
  }
}