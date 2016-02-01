abstract class Weapon {
  Character parent;
  float attackX;
  float attackY;
  
  Weapon(Character parent) {
    this.parent = parent;
  }
  
  abstract void update();
  
  abstract void draw();
  
  void action(int action) {
    if(!canAct(action)) {
      return;
    }
    
    attackX = screenXOffset + mouseX;
    attackY = screenYOffset + mouseY;
  }
  
  boolean canAct(int action) {
    if(parent.animationLeft > 0) {
      return false;
    }
    
    return true;
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
        spawnParticles(intersection.x, intersection.y, 0, 0, enemy.fillColor, 3);
      }
    }
  }
}

class Katana extends LineWeapon {
  int maxSlashCooldown;
  int slashAnimationTime;
  int slashCooldown;
  int slashCastPoint;
  
  int maxStabCooldown;
  int stabCooldown;
  int stabCastPoint;
  
  Katana(Character parent) {
    super(parent);
    length = 50;
    
    maxSlashCooldown = 30;
    slashAnimationTime = 25;
    slashCooldown = 0;
    slashCastPoint = 5;
  }
  
  void draw() {
    if(slashCooldown > 0) {
      pushMatrix();
        noStroke();
        fill(0);
        
        translate(parent.x + parent.sizeX / 2, parent.y + parent.sizeY / 2);
        rotate((slashAnimationTime - parent.animationLeft - slashCastPoint) * 0.03 + atan2(attackY - (parent.y + parent.sizeY / 2), attackX - (parent.x + parent.sizeX / 2)) - HALF_PI);
        
        rect(0, 2, 4, length);
      popMatrix();
    }
  }
  
  @Override
  void update() {
    if(slashCooldown > 0) {
      slashCooldown--;
      
      if(parent.animationLeft == slashAnimationTime - slashCastPoint) {
        attack(10, atan2(attackY - (parent.y + parent.sizeY / 2), attackX - (parent.x + parent.sizeX / 2)));
      }
    }
    
  }
  
  @Override
  public void action(int action) {
    if(!canAct(action)) {
      return;
    }
    
    super.action(action);
    
    if(action == 0) {
      slashCooldown = maxSlashCooldown;
      parent.animationLeft = maxSlashCooldown - slashCastPoint;
    }
  }
  
  @Override
  public boolean canAct(int action) { //<>//
    if(!super.canAct(action)) {
      return false;
    }
    if(action == 0 && slashCooldown > 0) {
      return false;
    }
    
    return true;
  }
}