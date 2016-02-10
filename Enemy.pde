import java.util.ArrayList;
import java.util.List;

enum Behavior {
  CHASE, RUN, STAY
}

class AIEnemy extends Character {
  Behavior behavior;
  long lastChange = 0;
  
  AIEnemy(float x, float y) {
    super(x, y);
    fillColor = color(64, 64, 192);
    behavior = Behavior.STAY;
    
    vx = 0;
    vy = 0;
    update();
  }
  
  AIEnemy(float x, float y, Behavior behavior) {
    this(x, y);
    this.behavior = behavior;
  }
  
  void die() {
    super.die();
  }
  
  void ai() {
    
  }
  
  void pathfind() {
    if(behavior == Behavior.STAY) {
      goUp = false;
      goDown = false;
      goLeft = false;
      goRight = false;
    } else if(behavior == Behavior.CHASE) {
      pathfindChase();
    } else if(behavior == Behavior.RUN) {
      pathfindRun();
    }
  }
  
  void pathfindChase() {
    if(player.y + player.sizeY <= y) {
      goUp = true;
    } else {
      goUp = false;
    }
    
    if(player.y >= y + sizeY) {
      goDown = true;
    } else {
      goDown = false;
    }
    
    if(player.x >= x + sizeX) {
      goRight = true;
    } else {
      goRight = false;
    }
    
    if(player.x + player.sizeX <= x) {
      goLeft = true;
    } else {
      goLeft = false;
    }
  }
  
  void pathfindRun() {
    if(player.y >= y) {
      goUp = true;
    } else {
      goUp = false;
    }
    
    if(player.y <= y) {
      goDown = true;
    } else {
      goDown = false;
    }
    
    if(player.x <= x && !collideRight) {
      goRight = true;
    } else {
      goRight = false;
    }
    
    if(player.x + sizeX * 3 > x && collideRight && millis() > lastChange + 1000) {
      lastChange = millis();
      goRight = true;
    }
    
    if(player.x >= x && !collideLeft) {
      goLeft = true;
    } else {
      goLeft = false;
    }
    
    if(player.x - sizeX * 3 < x && collideLeft && millis() > lastChange + 1000) {
      lastChange = millis();
      goLeft = true;
    }
  }
  
  void update() {
    ai();
    pathfind();
    super.update();
  }
}