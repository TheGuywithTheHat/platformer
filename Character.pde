import java.util.ArrayList;
import java.util.List;
import java.lang.Math;

class Character extends MovingRect {
  int queuedWeapon;
  Weapon currentWeapon;
  Weapon[] weapons = new Weapon[] {new Katana(this), new Tanto(this), new Kunai(this)};
  
  float px;
  float py;
  
  float animationLeft;
  
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
  
  Kunai grapple;
  
  float angle;
  
  float health;
  
  float stunned;
  
  Character(float x, float y) {
    super(x, y, 32, 64);
    fillColor = color(255, 0, 0);
    health = 100;
    vx = 0;
    vy = 0;
    
    currentWeapon = weapons[0];
    
    animationLeft = 0;
    
    update();
  }
  
  void damage(float damage) {
    health -= damage;
    if(health <= 0) {
      die();
    }
  }
  
  void die() {
    spawnParticles(x + sizeX / 2, y + sizeY / 2, 0, 0, fillColor, 32);
  }
  
  boolean alive() {
    return health > 0;
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
      stun(stunned - deltaTime);
    }
    
    if(animationLeft > 0) {
      animationLeft -= deltaTime;
    } else if(queuedWeapon > -1) {
      currentWeapon = weapons[queuedWeapon];
      queuedWeapon = -1;
    }
    
    move();
    
    for(Weapon weapon : weapons) {
      weapon.update();
    }
  }
  
  void draw() {
    super.draw();
    currentWeapon.draw();
  }
  
  void stun(float duration) {
    stunned = duration;
    goUp = false;
    goDown = false;
    goLeft = false;
    goRight = false;
  }
  
  void changeWeapon(int weapon) {
    queuedWeapon = weapon;
  }
  
  /**
   * Does all the updating of movement and stuff.
   * 200 lines of spaghetti.
   * TODO: add tomato sauce.
   */
  void move() {
    px = x;
    py = y;
    terminalV = d_terminalV;
    
    vy += gravity * deltaTick;
    
    float accel = accelBase + accelCoeff * abs(vx);
    if(vx > moveSpeed || vx < -moveSpeed) {
      accel = 0;
    }
    if(!collideBot) {
      accel /= 4;
    }
    
    if(goRight && !goLeft) {
      if(grapple != null && !collideBot && y > grapple.pos.y) {
        PVector relativePos = new PVector(grapple.pos.x - (x + vx + sizeX / 2), grapple.pos.y - (y + vy + sizeY / 2));
        relativePos.rotate(HALF_PI);
        relativePos.setMag(gravity / 4);
        vx += relativePos.x;
        vy += relativePos.y;
      } else {
        vx += accel * deltaTick;
      }
      
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
      if(vx > moveSpeed) {
        if(collideBot) {
          vx -= 1 * deltaTick;
        }
        vx -= 0.02 * deltaTick;
      }
    } else if(vx > 0 && (grapple == null || collideBot)) {
      if(collideBot) {
        vx -= 3 * deltaTick;
      }
      vx -= 0.3 * deltaTick;
      vx = max(vx, 0);
    }
    
    if(goLeft && !goRight) {
      if(grapple != null && !collideBot && y > grapple.pos.y) {
        PVector relativePos = new PVector(grapple.pos.x - (x + vx + sizeX / 2), grapple.pos.y - (y + vy + sizeY / 2));
        relativePos = relativePos.rotate(-HALF_PI);
        relativePos = relativePos.setMag(gravity / 4);
        vx += relativePos.x;
        vy += relativePos.y;
      } else {
        vx -= accel * deltaTick;
      }
      
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
      
      if(vx < -moveSpeed) {
        if(collideBot) {
          vx += 1 * deltaTick;
        }
        vx += 0.02 * deltaTick;
      }
    } else if(vx < 0 && (grapple == null || collideBot)) {
      if(collideBot) {
        vx += 3 * deltaTick;
      }
      vx += 0.3 * deltaTick;
      vx = min(vx, 0);
    }
    
    if(goUp) {
      if(collideBot) {
        jump();
      }
      if(justJumped) {
        float a = (-1 + sqrt(3)) / 2;
        float correction = gravity * ((0.5 / (1 + a + vy / jumpV)) - a) * 0.9;
        vy -= correction * deltaTick; //<>//
      }
      if(grapple != null) {
        grapple.grappleDist -= 4;
      }
    }
    
    if(goDown) {
      if(grapple != null) {
        grapple.grappleDist += 8;
      }
    }
    
    if(collidePlatform) {
      if(!goDown && stunned <= 0) {
        terminalV = slideV;
        
        Platform thePlatform = new Platform(x, Float.MAX_VALUE, 0);
        for(Box box : getCollisions(false)) { //<>//
          if(!(box instanceof Platform)) {
            continue; //<>//
          }
          if(box.y < thePlatform.y) {
            thePlatform = (Platform)box;
          }
        }
         
        if(y + min(vy, terminalV) * deltaTick > thePlatform.y) {
          y = thePlatform.y;
          vy = 0; //<>//
        }
        
        if(vy > -climbV && goUp) {
          vy = -climbV;
        }
      }
    }
    
    /*if(grapple == null) {
      vx = constrain(vx, -moveSpeed, moveSpeed);
    }*/
    vy = min(vy, terminalV);
    
    if(grapple != null) {
      PVector relativePos = new PVector((x + vx + sizeX / 2) - grapple.pos.x, (y + vy + sizeY / 2) - grapple.pos.y);
      PVector newRelativePos = relativePos;
      if(relativePos.mag() > grapple.grappleDist) {
        newRelativePos = relativePos.copy().setMag(grapple.grappleDist);
      }
      vx -= PVector.sub(relativePos, newRelativePos).x;
      vy -= PVector.sub(relativePos, newRelativePos).y;
    }
    
    processCollisions(getCollisions());
    
    x += vx * deltaTick;
    y += vy * deltaTick;
  }
  
  List<Box> getCollisions() {
    List<Box> collisions = new ArrayList();
    Rect newPos = new Rect(x + vx * deltaTick, y + vy * deltaTick, sizeX, sizeY);
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
    Rect newPos = new Rect(x + vx * deltaTick, y + vy * deltaTick, sizeX, sizeY);
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
        } else if(!goDown && botY > 0 && botY < vy * deltaTick && rightX < 0 && leftX > 0) {
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
  
  void breakGrapple() {
    grapple = null;
    for(Weapon weapon : weapons) {
      if(weapon instanceof Kunai) {
        ((Kunai)(weapon)).breakGrapple();
      }
    }
  }
}