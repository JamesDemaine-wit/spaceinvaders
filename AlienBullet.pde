public class AlienBullet {

  private boolean firing, hitPlayer, parentAlienDeath;
  private float alienBulletX, alienBulletY, parentAlienXLive;
  private int parentAlienNumber;

  public AlienBullet(int parentAlienNumber) {
    firing = false;
    hitPlayer = false;
    this.parentAlienNumber = parentAlienNumber;
  }

  private void beAnAlienBullet(float alienXLive, float alienYLive, boolean alienDeath) {
    this.parentAlienXLive = alienXLive;
    this.parentAlienDeath = alienDeath;
    if (shouldTheBulletFire()) {
      firing = true;
      alienBulletY = alienYLive;
      alienBulletX = alienXLive;
      sounds.bulletSound.play();
    }
    moveTheBullet();
    if (firing) {
      drawAlienBullet(alienBulletX, alienBulletY);
    }
    debug();
    hurtThePlayers();
    if (alienBulletY>= displayHeight || hitPlayer) {//destroys the bullet upon hit/passing off screen
      destroySelf(alienXLive, alienYLive);
    }
  }

  //Getters
  public boolean getFiring() { 
    return firing;
  }
  public boolean getHitPlayer() { 
    return hitPlayer;
  }
  public boolean getAlienDeath() {
    return parentAlienDeath;
  }
  public float getAlienBulletX() {
    return alienBulletX;
  }
  public float getAlienBulletY() {
    return alienBulletY;
  }
  public float getParentAlienXLive() {
    return parentAlienXLive;
  }
  public int getParentAlienNumber() {
    return parentAlienNumber;
  }

  //Setters
  public void setFiring(boolean newFiring) { 
    firing = newFiring;
  }
  public void setHitPlayer(boolean newHitPlayer) { 
    hitPlayer = newHitPlayer;
  }
  public void setParentAlienDeath(boolean newParentAlienDeath) { 
    parentAlienDeath = newParentAlienDeath;
  }
  public void setAlienBulletX(float newAlienBulletX) { 
    alienBulletX = newAlienBulletX;
  }
  public void setAlienBulletY(float newAlienBulletY) { 
    alienBulletY = newAlienBulletY;
  }
  public void setParentAlienXLive(float newParentAlienXLive) {
    parentAlienXLive = newParentAlienXLive;
  }
  public void setParentAlienNumber(int newParentAlienNumber) {
    parentAlienNumber = newParentAlienNumber;
  }

  private void moveTheBullet() {
    if (firing) {
      if (score <500) {
        alienBulletY+=4.5;
        numberOfAliens = 4;
      }
      if (score>=500 
        && score<1000) {
        alienBulletY+=5;
        numberOfAliens = 5;
      }
      if (score>=1000 
        && score<2000) {
        alienBulletY+=5.5;
        numberOfAliens = 6;
      }
      if (score>=2000 
        && score<3000) {
        alienBulletY+=6;
        numberOfAliens = 7;
      }
      if (score>=3000 
        && score<4000) {
        alienBulletY+=7;
        numberOfAliens = 8;
      }
      if (score>=4000) {
        alienBulletY+=8;
        numberOfAliens = 9;
      }
    }
  }

  private boolean shouldTheBulletFire() {
    if (((parentAlienXLive <= defender.getDefenderX()+50 
      && parentAlienXLive >= defender.getDefenderX()-50) || (Math.random()>=0.99))
      && !firing 
      && !parentAlienDeath) {
      return true;
    } else if (defenderTwo != null) {
      if (((parentAlienXLive <= defenderTwo.getDefenderX()+50 
        && parentAlienXLive >= defenderTwo.getDefenderX()-50) || (Math.random()>=0.99))
        && !firing 
        && !parentAlienDeath) {
        return true;
      } else {
        return false;
      }
    } else { 
      return false;
    }
  }

  private void hurtPlayerTwo() {
    if (isMultiplayer && defenderTwo !=null) {
      defenderTwo.setLives(defenderTwo.getLives()-1);
      if (defenderTwo.getLives() > 0) {
        sounds.defenderHitSound();
        firing = false;
        defenderTwo.setHitCoolDown(300);
      }
      if (defenderTwo.getLives() == 0) {
        resetToMenu();
        firing = false;
      }
      hitPlayer = true;
    }
  }

  private void hurtPlayerOne() {
    defender.setLives(defender.getLives()-1);
    if (defender.getLives() > 0) {
      sounds.defenderHitSound();
      firing = false;
      defender.setHitCoolDown(300);
    }
    if (defender.getLives() == 0) {
      resetToMenu();
      firing = false;
    }
    hitPlayer = true;
  }

  private void hurtThePlayers() {
    if (didBulletHitPlayerOne()) {
      hurtPlayerOne();
    }
    if (didBulletHitPlayerTwo()) {
      hurtPlayerTwo();
    }
  }

  private boolean didBulletHitPlayerTwo() {
    if (defenderTwo !=null) {
      if (alienBulletY<= defenderTwo.getDefenderY() -40 
        && alienBulletY >= defenderTwo.getDefenderY() -48 
        && alienBulletX >= defenderTwo.getDefenderX() - 48 
        && alienBulletX <= defenderTwo.getDefenderX() +48 
        && !hitPlayer 
        && defenderTwo.getIsVisible()) {
        return true;
      } else {
        return false;
      }
    } else { 
      return false;
    }
  }

  private boolean didBulletHitPlayerOne() {
    if (alienBulletY <= defender.getDefenderY() -40 //only an 8 pixel window of detection. chance of missing?
      && alienBulletY >= defender.getDefenderY() -48 
      && alienBulletX >= defender.getDefenderX() - 48 
      && alienBulletX <= defender.getDefenderX() +48 
      && !hitPlayer 
      && defender.getIsVisible()) {
      return true;
    } else { 
      return false;
    }
  }

  private void debug() {
    if (debug) {
      textAlign(LEFT);
      textSize(12);
      text("alienNumber: "+ parentAlienNumber, alienBulletX, alienBulletY-50);
      text("alienBullet: "+ int(alienBulletX) + " x "+ int(alienBulletY), alienBulletX, alienBulletY-65);
    }
  }

  private void destroySelf(float alienXLive, float alienYLive) {
    sounds.hitSound();
    explode(alienBulletX, alienBulletY, 64);
    alienBulletY = alienYLive;
    alienBulletX = alienXLive;
    firing = false;
    hitPlayer = false;
  }

  private void explode(float x, float y, float size) {
    imageMode(CENTER);
    image(images.explosionAsset, x, y, size, size);
  }

  private void drawAlienBullet(float x, float y) {
    imageMode(CENTER);
    image(images.alienBulletAsset, x, y, 32, 64);
  }
}
