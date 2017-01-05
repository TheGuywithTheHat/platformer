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
  
  /**
   * Damages the area covered by the weapon
   * 
   * @param damage The amount of damage to deal
   */
  void attack(float damage) {
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
  float maxSlashCooldown;
  float slashAnimationTime;
  float slashCooldown;
  float slashDamage;
  
  float maxStabCooldown;
  float stabCooldown;
  float stabDamage;
  
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
      slashCooldown -= deltaTick;
      location = new PVector(attackX, attackY).setMag(length).rotate((slashAnimationTime / 2 - (slashCooldown - (maxSlashCooldown - slashAnimationTime))) * 0.1 * Math.signum(attackX));
      attack(slashDamage);
    } else if(stabCooldown > 0) {
      stabCooldown -= deltaTick;
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
    if(slashCooldown > 0 || stabCooldown > 0) {
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

class Kunai extends Weapon {
  PVector pos;
  PVector velocity;
  
  int state = -1; // -1 = nothing, 0 = moving, 1 = grappled
  float grappleDist = -1;
  
  Kunai(Character parent) {
    super(parent);
  }
  
  void action(int action) {
    if(!canAct(action)) {
      return;
    }
    super.action(action);
    if(action == 0) {
      parent.breakGrapple();
      state = 0;
      pos = new PVector(parent.x + parent.sizeX / 2, parent.y + parent.sizeY / 2);
      velocity = new PVector(attackX, attackY).setMag(40);
    } else if(action == 1) {
      parent.breakGrapple();
    }
  }
  
  void update() {
    if(state == 0) {
      for(Box box : map) {
        PVector intersection = box.getLineIntersection(pos.x, pos.y, pos.x + velocity.x, pos.y + velocity.y);
        if(intersection != null) {
          state = 1;
          pos = intersection;
          parent.grapple = this;
          grappleDist = new PVector(pos.x - (parent.x + parent.sizeX / 2), pos.y - (parent.y + parent.sizeY / 2)).mag();
          spawnParticles(intersection.x, intersection.y, 0, 0, box.fillColor, 10);
        }
      }
      if(state == 0) {
        pos.add(velocity);
      }
    }
  }
  
  void draw() {
    if(state != -1) {
      stroke(0);
      strokeWeight(2);
      //line(pos.x, pos.y, parent.x + parent.sizeX / 2, parent.y + parent.sizeY / 2);
      noFill();
      bezier(pos.x, pos.y,
        pos.x + (parent.x + parent.sizeX / 2 - pos.x) * 0.4, pos.y + (parent.y + parent.sizeY / 2 - pos.y) * 0.4 + (grappleDist - new PVector(pos.x - (parent.x + parent.sizeX / 2), pos.y - (parent.y + parent.sizeY / 2)).mag()),
        pos.x + (parent.x + parent.sizeX / 2 - pos.x) * 0.6, pos.y + (parent.y + parent.sizeY / 2 - pos.y) * 0.6 + (grappleDist - new PVector(pos.x - (parent.x + parent.sizeX / 2), pos.y - (parent.y + parent.sizeY / 2)).mag()),
        parent.x + parent.sizeX / 2, parent.y + parent.sizeY / 2);
    }
  }
  
  void breakGrapple() {
    state = -1;
    grappleDist = -1;
  }
}