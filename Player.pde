import java.util.ArrayList;
import java.util.List;

class Player extends Rect {
  float vx, vy;
  boolean collideTop = false;
  boolean collideBot = false;
  boolean collideRight = false;
  boolean collideLeft = false;
  boolean justJumped = false;
  
  Player(float x, float y) {
    super(x, y, 32, 64);
    fillColor = color(255, 0, 0);
    
    vx = 0;
    vy = 0;
    update();
  }
  
  void jump() {
    vy = -jumpV;
    justJumped = true;
  }
  
  void wallJump(float scale) {
    vy = -jumpV;
    vx = jumpV * 2 * scale;
  }
  
  void update() {
    terminalV = d_terminalV;
    
    float accel = accelBase + accelCoeff * abs(vx);
    if(!collideBot) {
      accel /= 4;
    }
    
    if(getKey(KeyEvent.VK_D)) {
      vx += accel;
      
      if(collideRight) {
        terminalV = slideV;
        
        if(getKey(KeyEvent.VK_A) && !collideBot) {
          wallJump(-1);
        }
      }
    } else if(vx > 0) {
      if(collideBot) {
        vx -= 3;
      }
      vx -= 0.3;
      vx = max(vx, 0);
    }
    
    if(getKey(KeyEvent.VK_A)) {
      vx -= accel;
      
      if(collideLeft) {
        terminalV = slideV;
      
        if(getKey(KeyEvent.VK_D) && !collideBot) {
          wallJump(1);
        }
      }
    } else if(vx < 0) {
      if(collideBot) {
        vx += 3;
      }
      vx += 0.3;
      vx = min(vx, 0);
    }
    
    vy += gravity;
    
    if(vy > 0) {
      justJumped = false;
    }
    
    if(getKey(KeyEvent.VK_SPACE)) {
      if(collideBot) {
        jump();
      }
      if(justJumped) {
        float a = (-1 + sqrt(3)) / 2;
        float correction = gravity * ((0.5 / (1 + a + vy / jumpV)) - a) * 0.9;
        vy -= correction;
      }
    }
    
    vx = constrain(vx, -moveSpeed, moveSpeed);
    vy = min(vy, terminalV);
    
    processCollisions(getCollisions());
    
    x += vx;
    y += vy;
  }
  
  List<Box> getCollisions() {
    List<Box> collisions = new ArrayList();
    Rect newPos = new Rect(x + vx, y + vy, sizeX, sizeY);
    for(Box box : map) {
      if(newPos.intersects(box)) {
        collisions.add(box);
      }
    }
    
    return collisions;
  }
  
  void processCollisions(List<Box> boxes) {
    collideTop = false;
    collideBot = false;
    collideRight = false;
    collideLeft = false;
  
    for(Box box : boxes) {
      float rightX = box.x - (x + sizeX);
      float leftX = (box.x + box.sizeX) - x;
      float botY = box.y - (y + sizeY);
      float topY = (box.y + box.sizeY) - y;
      
      float xRatio = vx / -(vx > 0 ? rightX - vx : leftX - vx);
      float yRatio = vy / -(vy > 0 ? botY - vy : topY - vy);
      
      //float 
      
      //if
      
      if(((vx > 0 ? rightX : leftX) == 0 || (vx == 0 && rightX == 0)) && botY != 0) { // currently contacting but not intersecting on the X axis
        if(vx > 0 && rightX == 0) { // heading right towards contacted object
          vx = 0;
        } else if(vx < 0 && leftX == 0) { // heading left towards contacted object
          vx = 0;
        }
      } else if((vy > 0 ? botY : topY) == 0) { // currently contacting but not intersecting on the Y axis
        if(vy > 0 && botY == 0) { // heading down towards contacted object
          vy = 0;
        } else if(vy < 0 && topY == 0) { // heading up towards contacted object
          vy = 0;
        }
      } else {
        if(yRatio > xRatio) {
          y += vy + (vy > 0 ? botY - vy : topY - vy);
          vy = 0;
        } else {
          x += vx + (vx > 0 ? rightX - vx : leftX - vx);
          vx = 0;
        }
      }
      
      if(rightX == 0 && botY != 0) {
        collideRight = true;
      }
      if(leftX == 0 && botY != 0) {
        collideLeft = true;
      }
      if(topY == 0) {
        collideTop = true;
      }
      if(botY == 0) {
        collideBot = true;
      }
    }
  }
}