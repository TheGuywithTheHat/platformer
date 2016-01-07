import java.awt.event.KeyEvent;

boolean isInDebug;
private boolean[] keys;

Controls controls = new Controls();

class Controls {
  int up = KeyEvent.VK_W;
  int down = KeyEvent.VK_S;
  int left = KeyEvent.VK_A;
  int right = KeyEvent.VK_D;
  int jump = KeyEvent.VK_SPACE;
}

void setupInput() {
  isInDebug = false;
  keys = new boolean[526];
  
  
}

void checkInput() {
  if(getKey(KeyEvent.VK_W)) {
    
  }
}

boolean getKey(int k) {
  if(k < keys.length) {
    return keys[k];
  }
  return false;
}

void setKey(int k, boolean value) {
  keys[k] = value;
}

void keyPressed() {
  setKey(keyCode, true);
  
  switch(keyCode) {
    case KeyEvent.VK_F3:
      isInDebug = !isInDebug;
      if(isInDebug) {
        noLoop();
      } else {
        loop();
      }
      break;
    default:
      break;
  }
}

void keyReleased() {
  setKey(keyCode, false);
}

void mouseClicked() {
  if(isInDebug) {
    redraw();
  }
}