class Game {
  Game() {
    setup();
  }
  
  void update() {
    player.update();
    for(Enemy enemy : enemies) {
      enemy.update();
    }
  }
  
  void setup() {
    setupMap();
    player = new Player(100, 100);
    enemies = new Enemy[] {
        new Enemy(100, 100, Behavior.STAY),
        new Enemy(900, mapSizeY - 64, Behavior.STAY),
        new Enemy(1200, 100, Behavior.STAY),
      };
  }
}

class ChaseRunGame extends Game {
  int chaseLen = 15 * 60;
  int restLen = 3 * 60;
  
  Character runner;
  Character chaser;
  
  ChaseRunGame() {
    setup();
    runner = player;
    chaser = enemies[0];
  }
  
  void setup() {
    setupMap();
    player = new Player(100, 100);
    enemies = new Enemy[] {
        new Enemy(100, 100, Behavior.RUN)
      };
  }
  
  void update() {
    for(Enemy enemy : enemies) {
      enemy.update();
    }
    player.update();
    
    if(frameCount % (chaseLen + restLen) == 0) {
      Character temp = runner;
      runner = chaser;
      chaser = temp;
      
      if(runner instanceof Enemy) {
        ((Enemy)runner).behavior = Behavior.RUN;
      } else {
        ((Enemy)chaser).behavior = Behavior.CHASE;
      }
      chaser.stun(restLen);
    }
    
    if(frameCount % (chaseLen + restLen) > restLen && chaser.intersects(runner)) {
      runner.sizeY--;
      if(runner.sizeY <= 0) {
        try  {
          Thread.sleep(5000);
        } catch(InterruptedException e) {
          e.printStackTrace();
        }
        game = new ChaseRunGame();
      }
    }
  }
}