import java.util.ArrayList;
import java.util.List;
import java.lang.Math;

class Character extends MovingRect {
  boolean collideTop = false;
  boolean collideBot = false;
  boolean collideRight = false;
  boolean collideLeft = false;
  boolean collidePlatform = false;
  
  boolean justJumped = false;
  
  boolean goLeft;
  boolean goRight;
  boolean goUp;
  boolean goDown;
  
  float health;
  
  int stunned;
  
  Character(float x, float y) {
    super(x, y, 32, 64);
    fillColor = color(255, 0, 0);
    health = 100;
    vx = 0;
    vy = 0;
    update();
  }
  
  void damage(float damage) {
    health -= damage;
    spawnParticles(x + sizeX / 2, y + sizeY / 2, 0, 0, fillColor, 4);
    if(health <= 0) {
      die();
    }
  }
  
  void die() {
    spawnParticles(x + sizeX / 2, y + sizeY / 2, 0, 0, fillColor, 32);
  }
  
  void jump() {
    vy = -jumpV;
    justJumped = true;
    //spawnParticles(x + sizeX / 2, y + sizeY, 0, -3, color(64), 8);
  }
  
  void wallJump(float scale) {
    vy = min(-jumpV * 0.9, vy);
    vx = jumpV * 2.2 * scale;
    float sign = Math.signum(scale);
    spawnParticles((x + sizeX / 2) - (sizeX / 2 * sign), y + sizeY, 2 * sign, 0, color(64), 6);
  }
  
  void update() {
    if(stunned > 0) {
      stun(stunned - 1);
    }
    move();
  }
  
  void stun(int duration) {
    stunned = duration;
    goUp = false;
    goDown = false;
    goLeft = false;
    goRight = false;
  }
  
  void move() {
    terminalV = d_terminalV;
    
    vy += gravity;
    
    float accel = accelBase + accelCoeff * abs(vx);
    if(!collideBot) {
      accel /= 4;
    }
    
    if(goRight && !goLeft) {
      vx += accel;
      
      if(collideRight) {
        if(!goDown) {
          terminalV = slideV; //slide
          if(vy > 0 && random(1) < 0.2) {
            spawnParticle(x + sizeX, y + sizeY, -2, vy, color(64));
          }
        }
        
        if(goUp && !collideBot) {
          wallJump(-1); //walljump
        } else if(!collideBot) {
          Box theBox = new Box(x + sizeX, Float.MAX_VALUE, 0, 0);
          
          for(Box box : getCollisions(false)) {
            if(box.x == x + sizeX && box.y < theBox.y) {
              theBox = box;
            }
          }
          
          if(!pointCollides(x + sizeX * 1.1, theBox.y - sizeY * 0.1) && y <= theBox.y) {
            if(new Rect(x + sizeX * 0.1, theBox.y - sizeY, sizeX, sizeY).getIntersections().size() == 0) {
              vy = -climbV; //climb
            } else if(!goDown && y + vy > theBox.y) {
              y = theBox.y; //cat
              vy = 0;
            }
          }
        }
      }
    } else if(vx > 0) {
      if(collideBot) {
        vx -= 3;
      }
      vx -= 0.3;
      vx = max(vx, 0);
    }
    
    if(goLeft && !goRight) {
      vx -= accel;
      
      if(collideLeft) {
        if(!goDown) {
          terminalV = slideV; //slide
          if(vy > 0 && random(1) < 0.2) {
            spawnParticle(x, y + sizeY, 2, vy, color(64));
          }
        }
      
        if(goUp && !collideBot) {
          wallJump(1);
        } else if(!collideBot) {
          Box theBox = new Box(x, Float.MAX_VALUE, 0, 0);
          
          for(Box box : getCollisions(false)) {
            if(box.x + box.sizeX == x && box.y < theBox.y) {
              theBox = box;
            }
          }
          
          if(!pointCollides(x - sizeX * 0.1, theBox.y - sizeY * 0.1) && y <= theBox.y) {
            if(new Rect(x - sizeX * 0.1, theBox.y - sizeY, sizeX, sizeY).getIntersections().size() == 0) {
              vy = -climbV;
            } else if(!goDown && y + vy > theBox.y) {
              y = theBox.y;
              vy = 0;
            }
          }
        }
      }
    } else if(vx < 0) {
      if(collideBot) {
        vx += 3;
      }
      vx += 0.3;
      vx = min(vx, 0);
    }
    
    if(goUp) {
      if(collideBot) {
        jump();
      }
      if(justJumped) {
        float a = (-1 + sqrt(3)) / 2;
        float correction = gravity * ((0.5 / (1 + a + vy / jumpV)) - a) * 0.9;
        vy -= correction;
      }
    }
    
    if(collidePlatform) {
      if(!goDown && stunned <= 0) {
        terminalV = slideV;
        
        Platform thePlatform = new Platform(x, Float.MAX_VALUE, 0);
        for(Box box : getCollisions(false)) { //<>//
          if(!(box instanceof Platform)) {
            continue;
          }
          if(box.y < thePlatform.y) {
            thePlatform = (Platform)box;
          }
        }
         
        if(y + min(vy, terminalV) > thePlatform.y) {
          y = thePlatform.y;
          vy = 0;
        }
        
        if(vy > -climbV && goUp) {
          vy = -climbV;
        }
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
      if(box.collides(newPos)) {
        collisions.add(box);
      }
    }
    
    return collisions;
  }
  
  List<Box> getCollisions(boolean adjustForV) {
    if(adjustForV) {
      return getCollisions();
    } else {
      return super.getCollisions();
    }
  }
  
  List<Box> getIntersections() {
    List<Box> intersections = new ArrayList();
    Rect newPos = new Rect(x + vx, y + vy, sizeX, sizeY);
    for(Box box : map) {
      if(box.intersects(newPos)) {
        intersections.add(box);
      }
    }
    
    return intersections;
  }
  
  void processCollisions(List<Box> boxes) {
    collideTop = false;
    collideBot = false;
    collideRight = false;
    collideLeft = false;
    collidePlatform = false;
  
    for(Box box : boxes) {
      if(box instanceof Platform) {
        float rightX = box.x - (x + sizeX); // displacement
        float leftX = (box.x + box.sizeX) - x; // displacement
        float botY = box.y - (y + sizeY);
        
        if(!goDown && vy >= 0 && botY == 0 && rightX != 0 && leftX != 0) { // currently contacting but not intersecting on the Y axis
          vy = 0;
        } else if(!goDown && botY > 0 && botY < vy && rightX < 0 && leftX > 0) {
          //if(!goDown && botY > 0 && botY < vy && ((rightX < 0 && leftX > 0) || (rightX > 0 && rightX < vx && box.y > vy / vx * (box.x - x + sizeX) + y || (leftX < 0 && leftX > vx && box.y > vy / vx * (box.x + box.sizeX - x) + y)))) {
          y = box.y - sizeY;
          vy = 0;
        }
        
        if(box.y == y + sizeY && rightX != 0 && leftX != 0) {
          collideBot = true;
        } else if(rightX != 0 && leftX != 0) {
          collidePlatform = true;
        }
      } else {
        float rightX = box.x - (x + sizeX);
        float leftX = (box.x + box.sizeX) - x;
        float botY = box.y - (y + sizeY);
        float topY = (box.y + box.sizeY) - y;
        
        float xRatio = abs(vx / (vx > 0 ? rightX - vx : leftX - vx));
        float yRatio = abs(vy / (vy > 0 ? botY - vy : topY - vy));
        
        if(((vx >= 0 && rightX == 0) || (vx <= 0 && leftX == 0)) && botY != 0 && topY != 0) { // currently contacting but not intersecting on the X axis
          vx = 0;
        } else if(((vy >= 0 && botY == 0) || (vy <= 0 && topY == 0)) && rightX != 0 && leftX != 0) { // currently contacting but not intersecting on the Y axis
          vy = 0;
        } else {
          if(yRatio > xRatio) {
            y = (vy > 0 ? box.y - sizeY : box.y + box.sizeY);
            vy = 0;
          } else {
            x = (vx > 0 ? box.x - sizeX : box.x + box.sizeX);
            vx = 0;
          }
        }
        
        if(box.x == x + sizeX && botY != 0 && topY != 0) {
          collideRight = true;
        }
        if(box.x + box.sizeX == x && botY != 0 && topY != 0) {
          collideLeft = true;
        }
        if(box.y + box.sizeY == y && rightX != 0 && leftX != 0) {
          collideTop = true;
        }
        if(box.y == y + sizeY && rightX != 0 && leftX != 0) {
          collideBot = true;
        }
      }
    }
  }
}