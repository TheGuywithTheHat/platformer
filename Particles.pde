void spawnParticles(float x, float y, float vx, float vy, color fillColor, int number) {
  particles.ensureCapacity(particles.size() + number);
  for(int i = 0; i < number; i++) {
    spawnParticle(x, y, vx, vy, fillColor);
  }
}

void spawnParticle(float x, float y, float vx, float vy, color fillColor) {
  particles.add(new Particle(x, y, vx, vy, fillColor));
}

class Particle extends MovingRect {
  Particle(float x, float y, float vx, float vy, color fillColor) {
    this(x, y, random(4, 7));
    this.vx = vx + random(-2, 2);
    this.vy = vy + random(-1, 1);
    
    int delta = int(random(32));
    delta = delta | delta << 8;
    delta = delta | delta << 8;
    this.fillColor = fillColor ^ delta;
  }
  
  private Particle(float x, float y, float size) {
    super(x, y, size, size);
  }
  
  void update() {
    vx *= 0.98;
    vy += gravity / 2;
    super.move();
    if(x < -sizeX || x > mapSizeX + sizeX || y > mapSizeY + sizeY) {
      particles.remove(this);
    }
  }
  
  void draw() {
    pushMatrix();
      noStroke();
      fill(fillColor);
      
      translate(x, y);
      rotate(x / 10);
      
      rect(-sizeX / 2, -sizeY / 2, sizeX, sizeY);
    popMatrix();
  }
}