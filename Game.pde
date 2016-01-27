class Game {
  Game() {
    setup();
  }
  
  void update() {
    if(player.alive()) {
      player.update();
    }
    for(Character enemy : getEnemies()) {
      enemy.update();
    }
  }
  
  void setup() {
    setupMap();
    player = new Player(100, 100);
    enemies = new AIEnemy[] {
        new AIEnemy(100, 100, Behavior.STAY),
        new AIEnemy(900, mapSizeY - 64, Behavior.STAY),
        new AIEnemy(1200, 100, Behavior.STAY),
      };
  }
  
  Character[] getEnemies() {
    List<Character> chars = new ArrayList<Character>(enemies.length);
    for(Character c : enemies) {
      if(c.alive()) {
        chars.add(c);
      }
    }
    
    return chars.toArray(new Character[0]);
  }
}

class OneVOne extends Game {
  OneVOne() {
    super();
  }
  
  void setup() {
    setupMap();
    player = new Player(100, 100);
    enemies = new AIEnemy[] {
        new AIEnemy(200, 100, Behavior.STAY),
      };
  }
  
  Character[] getEnemies() {
    if(enemies[0].health > 0) {
      return new Character[] {enemies[0]};
    } else {
      return new Character[] {};
    }
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
    enemies = new AIEnemy[] {
        new AIEnemy(100, 100, Behavior.RUN)
      };
  }
  
  void update() {
    for(Character enemy : getEnemies()) {
      enemy.update();
    }
    player.update();
    
    if(frameCount % (chaseLen + restLen) == 0) {
      Character temp = runner;
      runner = chaser;
      chaser = temp;
      
      if(runner instanceof AIEnemy) {
        ((AIEnemy)runner).behavior = Behavior.RUN;
      } else {
        ((AIEnemy)chaser).behavior = Behavior.CHASE;
      }
      chaser.stun(restLen);
    }
    
    if(frameCount % (chaseLen + restLen) > restLen && chaser.intersects(runner)) {
      runner.damage(2);
      if(runner.health <= 0) {
        /*try  {
          Thread.sleep(5000);
        } catch(InterruptedException e) {
          e.printStackTrace();
        }
        game = new ChaseRunGame();*/
      }
    }
  }
}