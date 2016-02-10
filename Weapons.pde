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
    
    attackX = screenXOffset + mouseX - (parent.x + parent.sizeX / 2);
    attackY = screenYOffset + mouseY - (parent.y + parent.sizeY / 2);
  }
  
  @SuppressWarnings("unused")
  boolean canAct(int action) {
    if(parent.animationLeft > 0) {
      return false;
    } else {
      return true;
    }
  }
}

abstract class LineWeapon extends Weapon {
  PVector location;
  boolean enemyDamaged;
  float length;
  
  LineWeapon(Character parent) {
    super(parent);
    enemyDamaged = false;
  }
  
  void update() {
    if(location != null && !enemyDamaged) {
      
    }
  }
  
  void attack(float damage) {
    if(enemyDamaged) {
      //return;
    }
    
    float startX = parent.x + parent.sizeX / 2;
    float startY = parent.y + parent.sizeY / 2;
    float endX = startX + location.x;
    float endY = startY + location.y;
    
    for(Character enemy : game.getEnemies()) {
      PVector intersection = enemy.getLineIntersection(startX, startY, endX, endY);
      if(intersection != null) {
        if(!enemyDamaged) {
          enemy.damage(damage);
          enemyDamaged = true;
        }
        spawnParticles(intersection.x, intersection.y, 0, 0, enemy.fillColor, 1);
      }
    }
  }
}

class Katana extends LineWeapon {
  int maxSlashCooldown;
  int slashAnimationTime;
  int slashCooldown;
  float slashDamage;
  
  int maxStabCooldown;
  int stabCooldown;
  int stabDamage;
  
  Katana(Character parent) {
    super(parent);
    length = 70;
    
    maxSlashCooldown = 20;
    slashAnimationTime = 15;
    slashCooldown = 0;
    slashDamage = 10;
    
    maxStabCooldown = 10;
    stabCooldown = 0;
    stabDamage = 4;
  }
  
  void draw() {
    if(slashCooldown > 0 || stabCooldown > 0) {
      pushMatrix();
        noStroke();
        fill(0);
        
        translate(parent.x + parent.sizeX / 2, parent.y + parent.sizeY / 2); //<>//
        rotate(atan2(location.y, location.x)); //<>//
        
        rect(0, -2, location.mag(), 4);
      popMatrix();
    }
  }
  
  void update() {
    if(slashCooldown > 0) {
      slashCooldown--;
      location = new PVector(attackX, attackY).setMag(length).rotate((slashAnimationTime / 2 - (slashCooldown - (maxSlashCooldown - slashAnimationTime))) * 0.1 * Math.signum(attackX));
      attack(slashDamage);
    } else if(stabCooldown > 0) {
      stabCooldown--;
      location = new PVector(attackX, attackY).setMag(length - abs(stabCooldown - maxStabCooldown / 2) * 4);
      attack(stabDamage);
    } else {
      enemyDamaged = false;
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
      parent.animationLeft = slashAnimationTime;
    }
    
    if(action == 1) {
      stabCooldown = maxStabCooldown;
      parent.animationLeft = maxStabCooldown;
    }
  }
  
  @Override
  public boolean canAct(int action) { //<>//
    if(!super.canAct(action)) {
      return false;
    }
    if(action == 0 && slashCooldown > 0) {
      return false;
    } else {
      return true;
    }
  }
}

class OneTanto extends Katana {
  OneTanto(Character parent) {
    super(parent);
    length = 50;
    
    maxSlashCooldown = 15;
    slashAnimationTime = maxSlashCooldown;
    slashCooldown = 0;
    slashDamage = 3;
    
    maxStabCooldown = 10;
    stabCooldown = 0;
    stabDamage = 2;
  }
  
  @Override
  public boolean canAct(int action) {
    if(slashCooldown > 0 || stabCooldown > 0 || parent.queuedWeapon > -1) {
      return false;
    } else {
      return true;
    }
  }
}

class Tanto extends Weapon {
  OneTanto tanto1;
  OneTanto tanto2;
  
  Tanto(Character parent) {
    super(parent);
    tanto1 = new OneTanto(parent);
    tanto2 = new OneTanto(parent);
  }
  
  void update() {
    tanto1.update();
    tanto2.update();
  }
  
  void draw() {
    tanto1.draw();
    tanto2.draw();
  }
  
  void action(int action) {
    if(tanto1.canAct(action)) {
      tanto1.action(action);
    } else if(tanto2.canAct(action)) {
      tanto2.action(action);
    }
  }
}