public class Defender {

  private float defenderX, defenderY;
  private int hitCooldown, lives, maxLives;
  private boolean isVisible, targetHit, isPlayerTwo;
  private Bullet bullet;

  public Defender() {
    bullet = new Bullet();
    this.isPlayerTwo = false;
    if (isClient && multiplayer.getConnected()) {
      defenderX = 3*(displayWidth/4);
    }
    if (isHost && multiplayer.getConnected()) {
      defenderX = displayWidth/4;
    } else {
      defenderX = displayWidth/2;
    }
    defenderY= displayHeight-(displayHeight/8);
    hitCooldown = 0;
    isVisible = true;
    targetHit = false;
    lives = 3;
    maxLives = 3;
  }
  
  public Defender(boolean isPlayerTwo) {//Fix this so server places in same position as client
    bullet = new Bullet();
    this.isPlayerTwo = isPlayerTwo;
    if (isClient && multiplayer.getConnected()) {
      defenderX = 3*(displayWidth/4);
    }
    if (isHost && multiplayer.getConnected()) {
      defenderX = displayWidth/4;
    } else {
      defenderX = displayWidth/2;
    }
    defenderY= displayHeight-(displayHeight/8);
    hitCooldown = 0;
    isVisible = true;
    targetHit = false;
    lives = 3;
    maxLives = 3;
  }

  public void beADefender() {
    drawDefender();
    debug();
    updateVisibility();
    bullet.bullet(defenderX, defenderY);
    targetHit = false;
  }

  private void drawDefender() {
    if (isPlayerTwo) {
      if (isVisible) {
        imageMode(CENTER);
        image(images.defenderShipAssetPlayerTwo, defenderX, defenderY, 96, 96);
      }
      if (!isVisible) {
        imageMode(CENTER);
        tint(255, 128);
        image(images.defenderShipAssetPlayerTwo, defenderX, defenderY, 96, 96);
        tint(255, 255);
        image(images.shieldAsset, defenderX, defenderY, 128, 128);
      }
    } else {
      defenderX = mouseX;
      defenderY= displayHeight-(displayHeight/8);
      if (isVisible) {
        imageMode(CENTER);
        image(images.defenderShipAsset, defenderX, defenderY, 96, 96);
      }
      if (!isVisible) {
        imageMode(CENTER);
        tint(255, 128);
        image(images.defenderShipAsset, defenderX, defenderY, 96, 96);
        tint(255, 255);
        image(images.shieldAsset, defenderX, defenderY, 128, 128);
      }
    }
  }

  private void debug() {
    if (debug) {
      textAlign(CENTER);
      textSize(12);
      text("hitCooldown: "+ hitCooldown, defenderX, defenderY -48);
    }
  }

  private void updateVisibility() {
    if (hitCooldown > 0) {
      hitCooldown--;
      if (!isVisible 
        && hitCooldown%60 <=15) {
        isVisible = true;
      }
      if (isVisible 
        && hitCooldown%60 >15) {
        isVisible = false;
      }
    }
  }

  //Getters
  public Bullet getBullet(){
    return bullet;
  }
  public float getDefenderX() {
    return defenderX;
  }
  public float getDefenderY() {
    return defenderY;
  }
  public int getLives() {
    return lives;
  }
  public int getMaxLives() {
    return maxLives;
  }
  public int getHitCooldown() {
    return hitCooldown;
  }
  public boolean getIsVisible() {
    return isVisible;
  }
  public boolean getTargetHit() {
    return targetHit;
  }

  //Setters
  public void setDefenderX(float newDefenderX) {
    defenderX = newDefenderX;
  }
  public void setDefenderY(float newDefenderY) {
    defenderY = newDefenderY;
  }
  public void setHitCoolDown(int newHitCooldown) {
    hitCooldown = newHitCooldown;
  }
  public void setLives(int newLives) {
    lives = newLives;
  }
  public void setMaxLives(int newMaxLives) {
    maxLives = newMaxLives;
  }
  public void setIsVisible(boolean newIsVisible) {
    isVisible = newIsVisible;
  }
  public void setTargetHit(boolean newTargetHit) {
    targetHit = newTargetHit;
  }
}
