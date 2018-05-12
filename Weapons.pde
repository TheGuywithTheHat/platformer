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
    
    attackX = screenXOffset + mouseX - parent.centerX();
    attackY = screenYOffset + mouseY - parent.centerY();
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
    float startX = parent.centerX();
    float startY = parent.centerY();
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
         //<>//
        translate(parent.centerX(), parent.centerY()); //<>// //<>//
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
  
  @Override //<>//
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

enum KunaiState {
  INACTIVE(false),
  MOVING(true),
  GRAPPLED(true);
  
  boolean drawn;
  
  private KunaiState(boolean drawn) {
    this.drawn = drawn;
  }
}

class Kunai extends Weapon {
  
  PVector pos;
  PVector velocity;
  
  KunaiState state = KunaiState.INACTIVE;
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
      state = KunaiState.MOVING;
      pos = new PVector(parent.centerX(), parent.centerY());
      velocity = new PVector(attackX, attackY).setMag(80);
    } else if(action == 1) {
      parent.breakGrapple();
    }
  }
  
  void update() {
    if(state == KunaiState.MOVING) {
      for(Box box : map) {
        PVector intersection = box.getLineIntersection(pos.x, pos.y, pos.x + velocity.x, pos.y + velocity.y);
        if(intersection != null) {
          state = KunaiState.GRAPPLED;
          pos = intersection;
          parent.grapple = this;
          grappleDist = new PVector(pos.x - parent.centerX(), pos.y - parent.centerY()).mag();
          spawnParticles(intersection.x, intersection.y, 0, 0, box.fillColor, 10);
        }
      }
      if(state == KunaiState.MOVING) {
        pos.add(velocity);
      }
    }
  }
  
  void draw() {
    if(state.drawn) {
      stroke(0);
      strokeWeight(2);
      noFill();
      float slack = grappleDist - new PVector(pos.x - parent.centerX(), pos.y - parent.centerY()).mag();
      if(state == KunaiState.MOVING) {
        slack = 0;
      }
      bezier(pos.x, pos.y,
        pos.x + (parent.centerX() - pos.x) * 0.4, pos.y + (parent.centerY() - pos.y) * 0.4 + slack,
        pos.x + (parent.centerX() - pos.x) * 0.6, pos.y + (parent.centerY() - pos.y) * 0.6 + slack,
        parent.centerX(), parent.centerY());
    }
  }
  
  void breakGrapple() {
    state = KunaiState.INACTIVE;
    grappleDist = -1;
  }
  
  void reelIn() {
    grappleDist -= 4;
    constrainGrapple();
  }
  
  void reelOut() {
    grappleDist += 8;
    constrainGrapple();
  }
  
  void constrainGrapple() {
    grappleDist = max(grappleDist, 0);
  }
}
