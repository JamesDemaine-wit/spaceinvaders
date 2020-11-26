public class Alien {

  private float alienX, alienY, explosionSize;
  private int hits, maxHits, alienNumber, deathFrame;
  private boolean directionIsRight, alienDeathState;
  private AlienBullet alienBullet;
  private Object defenderThatWasHit, defenderThatHitTarget;

  //default constructor, i is the alien number passed from the main class.
  public Alien(int i) {
    hits = 0;
    maxHits = 3;
    alienNumber = i;
    alienDeathState = false;
    directionIsRight = boolean((int)Math.random());//random true or false.
    alienX = (displayWidth/(numberOfAliens+1))*alienNumber;
    alienY = 40;
    alienBullet = new AlienBullet(alienNumber);
    explosionSize=75;
  }

  public void beAnAlien() {
    moveSideways();
    moveVertically();
    explode();
    hit();
    reset();
    drawAlienShip(alienX, alienY);
    debug();
    alienBullet.beAnAlienBullet(alienX, alienY+75, alienDeathState);
  }

  public void beAClientAlien() {
    explode();
    hit();
    reset();
    drawAlienShip(alienX, alienY);
    debug();
    alienBullet.beAnAlienBullet(alienX, alienY+75, alienDeathState);
  }

  //Setters
  public void setAlienX(float newAlienX) {
    alienX = newAlienX;
  }
  public void setAlienY(float newAlienY) {
    alienY = newAlienY;
  }
  public void setExplosionSize(float newExplosionSize) {
    explosionSize = newExplosionSize;
  }
  public void setHits(int newHits) {
    hits = newHits;
  }
  public void setMaxHits(int newMaxHits) {
    maxHits = newMaxHits;
  }
  public void setAlienNumber(int newAlienNumber) {
    alienNumber = newAlienNumber;
  }
  public void setDeathFrame(int newDeathFrame) {
    deathFrame = newDeathFrame;
  }
  public void setAlienWidth(float newAlienWidth) {
    alienWidth = newAlienWidth;
  }
  public void setAlienHeight(float newAlienHeight) {
    alienHeight = newAlienHeight;
  }
  public void setDirectionIsRight(boolean newDirectionIsRight) {
    directionIsRight = newDirectionIsRight;
  }
  public void setAlienDeathState(boolean newAlienDeathState) {
    alienDeathState = newAlienDeathState;
  }


  //Getters
  public Object getAlienBullet() {
    return alienBullet;
  }
  public float getAlienX() {
    return alienX;
  }
  public float getAlienY() {
    return alienY;
  }
  public float getExplosionSize() {
    return explosionSize;
  }
  public int getHits() {
    return hits;
  }
  public int getMaxHits() { 
    return maxHits;
  }
  public int getAlienNumber() {
    return alienNumber;
  }
  public int getDeathFrame() {
    return deathFrame;
  }
  public float getAlienWidth() {
    return alienWidth;
  }
  public float getAlienHeight() {
    return alienHeight;
  }
  public boolean getDirectionIsRight() {
    return directionIsRight;
  }
  public boolean getAlienDeathState() {
    return alienDeathState;
  }

  private void explode() {
    if (alienDeathState 
      && explosionSize<=200) {
      explosionSize+=1;
      explode(explosionSize);
    }
    if (!alienDeathState) {
      explosionSize=50*(hits+1);
    }
  }

  private void debug() {
    if (debug) {
      textAlign(CENTER);
      textSize(12);
      fill(255, 0, 0);
      text("Alien pos: "+ int(alienX) + " x " + int(alienY), alienX, alienY+50);
      text("DeathFrame: "+deathFrame, alienX, alienY+65);
      text("Death: "+ alienDeathState, alienX, alienY+80);
    }
  }

  private void reset() {
    if (alienDeathState 
      && (int(frameCount-deathFrame)/frameRate) > int(7+(numberOfAliens*2*(float)Math.random()))) {
      alienDeathState = false;
      hits = 0;
      alienX = (displayWidth/(numberOfAliens+1))*alienNumber;
      alienY=40;
    }
  }

  private void die() {
    alienDeathState = true;
    bonusScore();//must run after setting death flag to work
    deathFrame = frameCount;
    sounds.deathSound();
    reset();
    score+=30;
  }

  private void explode(float size) {
    imageMode(CENTER);
    image(images.explosionAsset, alienX, alienY, size, size);
  }

  private boolean didBulletHitTarget() {
    if (defenderTwo == null) {
      if (defender.bullet.getBulletX() >= alienX-45 
        && defender.bullet.getBulletX() <= alienX+45 
        && defender.bullet.getBulletY() >= alienY+14 
        && defender.bullet.getBulletY() <= alienY+75 
        && !alienDeathState) {
        return true;
      } else { 
        return false;
      }
    } else {
      if (defender.bullet.getBulletX() >= alienX-45 
        && defender.bullet.getBulletX() <= alienX+45 
        && defender.bullet.getBulletY() >= alienY+14 
        && defender.bullet.getBulletY() <= alienY+75 
        && !alienDeathState) {
        defenderThatHitTarget = defender;
        return true;
      } 
      if (defenderTwo.bullet.bulletX >= alienX-45 
        && defenderTwo.bullet.getBulletX() <= alienX+45 
        && defenderTwo.bullet.getBulletY() >= alienY+14 
        && defenderTwo.bullet.getBulletY() <= alienY+75 
        && !alienDeathState) {
        defenderThatHitTarget = defenderTwo;
        return true;
      } else { 
        return false;
      }
    }
  }

  private void hit() {
    if (didBulletHitTarget()) {
      hits++;
      if (hits<maxHits) {
        sounds.hitSound();
      }
      explode(explosionSize);
      score+=10;
      if (defenderThatHitTarget == defender) {
        defender.setTargetHit(true);
      }
      if (defenderTwo != null) {
        if (defenderThatHitTarget == defenderTwo) {
          defenderTwo.setTargetHit(true);
        }
      }
      if (hits==maxHits) {
        die();
      }
    }
  }

  private void moveVertically() {
    if (!alienDeathState) {
      if (score <1000) {
        alienY+=Math.random()*0.4;
      }
      if (score>=1000 
        && score<2000) {
        alienY+=Math.random()*0.5;
      }
      if (score>=2000 
        && score<3000) {
        alienY+=Math.random()*0.65;
      }
      if (score>=3000 
        && score<4000) {
        alienY+=Math.random()*0.85;
      }
      if (score>=4000) {
        alienY+=Math.random()*(1+((score-4000)/1000));
        sounds.gameMusic.rate(1+0.05*((score-4000)/1000));
      }
      if (didAlienHitDefender()) {
        if (defenderThatWasHit == defender) {
          defender.setLives(defender.getLives()-1);
          die();
        }
        if (defenderTwo != null) {
          if (defenderThatWasHit == defenderTwo) {
            defenderTwo.setLives(defenderTwo.getLives()-1);
            die();
          }
        }
      }
      if (didAlienPassDefender()) {
        resetToMenu();
      }
    }
  }

  private boolean didAlienPassDefender() {
    if (alienY>=defender.defenderY-50 && !(alienX<=defender.defenderX+96 
      && alienX >= defender.defenderX-96)) {
      return true;
    } else {
      return false;
    }
  }

  private boolean didAlienHitDefender() {
    if (isMultiplayer && defenderTwo !=null) {
      if (alienY>=defender.getDefenderY()-100 
        && alienX<=defender.getDefenderX()+96 
        && alienX >= defender.getDefenderX()-96) {
        defenderThatWasHit = defender;
        return true;
      }
      if (alienY>=defenderTwo.getDefenderY()-100 
        && alienX<=defenderTwo.getDefenderX()+96 
        && alienX >= defenderTwo.getDefenderX()-96) {
        defenderThatWasHit = defenderTwo;
        return true;
      } else {
        return false;
      }
    } else {
      if (alienY>=defender.getDefenderY()-100 
        && alienX<=defender.getDefenderX()+96 
        && alienX >= defender.getDefenderX()-96) {
        return true;
      } else {
        return false;
      }
    }
  }

  private void moveSideways() {
    if (!alienDeathState) {
      if (directionIsRight) {
        if (alienX<(displayWidth/(numberOfAliens+1))*alienNumber+(displayWidth/(numberOfAliens+1))) {
          alienX+=4*Math.random();
        }
        if (alienX>=(displayWidth/(numberOfAliens+1))*alienNumber+(displayWidth/(numberOfAliens+1))) {
          directionIsRight = false;
        }
      }
      if (!directionIsRight) {
        if (alienX>(displayWidth/(numberOfAliens+1))*(alienNumber-1)) {
          alienX-=4*Math.random();
        }
        if (alienX<=(displayWidth/(numberOfAliens+1))*(alienNumber-1)) {
          directionIsRight=true;
        }
      }
    }
  }

  private void drawAlienShip(float x, float y) {
    if (hits<maxHits) {
      imageMode(CENTER);
      image(images.alienShipAsset, x, y, alienWidth, alienHeight);
    }
  }
}
