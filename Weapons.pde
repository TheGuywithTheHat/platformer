abstract class Weapon {
  Character parent;
  
  Action[] acts;
  
  Weapon(Character parent) {
    this.parent = parent;
  }
  
  void action(int number) {
    acts[number].action.run();
  }
}

class Action {
  final int cooldown; //how long the action takes to cooldown (the action cannot be activated within this period)
  final int time; //how long the action takes to complete (ANY action cannot be activated within this period)
  int activatedAgo = Integer.MAX_VALUE;
  Runnable action;
  
  Action(Runnable action, int time, int cooldown) {
    this.cooldown = cooldown;
    this.time = time;
    this.action = action;
  }
}

abstract class LineWeapon extends Weapon {
  float length;
  
  LineWeapon(Character parent) {
    super(parent);
  }
  
  void attack(float damage, float angle) {
    float startX = parent.x + parent.sizeX / 2;
    float startY = parent.y + parent.sizeY / 2;
    float endX = startX + cos(angle) * length;
    float endY = startY + sin(angle) * length;
    
    for(Character enemy : game.getEnemies()) {
      PVector intersection = enemy.getLineIntersection(startX, startY, endX, endY);
      if(intersection != null) {
        enemy.damage(damage);
        spawnParticles(intersection.x, intersection.y, 0, 0, enemy.fillColor, 1);
      }
    }
  }
}

class Katana extends LineWeapon {
  Katana(Character parent) {
    super(parent);
    length = 50;
    
    acts = new Action[] {
        new Action(new Runnable() {
            void run() {
              attack(10, atan2(screenYOffset + mouseY - player.y, screenXOffset + mouseX - player.x));
            }
          }, 50, 60),
        new Action(new Runnable() {
            void run() {
              attack(2, atan2(screenYOffset + mouseY - player.y, screenXOffset + mouseX - player.x));
            }
          }, 15, 15)
      };
    
    /*acts = new Action[] {
        new Action(() -> {
            attack(10, parent.angle);
          }, 50, 60),
        new Action(() -> {
            attack(2, parent.angle);
          }, 15, 15)
      };*/
  }
}