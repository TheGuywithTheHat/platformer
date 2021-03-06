import java.util.ArrayList;
import java.util.List;

class Player extends Character {
  Player(float x, float y) {
    super(x, y);
    fillColor = color(192, 32, 32);
    
    vx = 0;
    vy = 0;
    update();
  }
  
  void getInput() {
    if(getKey(controls.jump)) {
      goUp = true;
    } else {
      goUp = false;
    }
    
    if(getKey(controls.down)) {
      goDown = true;
    } else {
      goDown = false;
    }
    
    if(getKey(controls.right)) {
      goRight = true;
    } else {
      goRight = false;
    }
    
    if(getKey(controls.left)) {
      goLeft = true;
    } else {
      goLeft = false;
    }
  }
  
  void update() {
    getInput();
    angle = atan2(screenYOffset + mouseY - y, screenXOffset + mouseX - x);
    super.update();
  }
}