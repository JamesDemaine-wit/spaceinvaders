public class Bullet {
  private float bulletX, bulletY;
  private boolean fire;

  Bullet() {
    fire = false;
  }

  public void bullet(float x, float y) {//defender x and y
    if (bulletY<=0) {
      bulletX = x;
      bulletY = y-50; //Above the ship
      if (!mousePressed && fire) {
        fire = false;
      }
    }
    if (fire 
      && bulletY>0) {
      if (bulletY == y-50) {
        bulletX = mouseX; //prevents firing upon launch and play the launch sound
        if (sounds.bulletSound.isPlaying()) {
          sounds.bulletSound.jump(0);
        } else { 
          sounds.bulletSound.play();
        }
      }
      drawBullet(bulletX, bulletY);
      bulletY-=60;
    } else if (!fire && bulletY>0 && bulletY!=y-50) {
      bulletY-=60;
      drawBullet(bulletX, bulletY);
    }
  }

  private void drawBullet(float x, float y) {
    imageMode(CENTER);
    image(images.bulletAsset, x, y, 32, 64);
  }

  public void drawBullet(float x, float y, float size) {//menu bullet
    imageMode(CENTER);
    image(images.bulletAsset, x, y, size, size);
  }

  //Getters:
  public float getBulletX() {
    return bulletX;
  }
  public float getBulletY() {
    return bulletY;
  }
  public boolean getFire() {
    return fire;
  }

  //Setters:
  public void setBulletX(float bulletX) { 
    this.bulletX = bulletX;
  }
  public void setBulletY(float bulletY) {
    this.bulletY = bulletY;
  }
  public void setFire(boolean fire) {
    this.fire = fire;
  }
}
