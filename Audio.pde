public class Audio {
  //I made all audio into its own class to simplify finding audio bugs.

  public SoundFile gameMusic;
  public SoundFile bulletSound;
  public SoundFile deathSound;
  public SoundFile defenderHitSound;
  public SoundFile explosionSound;
  public SoundFile menuMusic;
  public SoundFile menuButtonSound;
  public SoundFile exitGameSound;
  public SoundFile winnerSound;
  public SoundFile dialupSound;
  public SoundFile errorSound;
  private boolean musicMuted;
  private boolean playDeathSound;

  Audio() {
    //If an error shows up over false below, you have not replaced the default processing sound library with the latest version.
    //see readme for more info
    //THE OLD VERSION HAD BUGS :-(

    gameMusic = new SoundFile(parent, "assets/gameMusic.wav", false);//an mp3 is available too
    bulletSound = new SoundFile(parent, "assets/bullet.wav", false);
    explosionSound = new SoundFile(parent, "assets/explosionMini.wav", false);
    menuMusic = new SoundFile(parent, "assets/menuMusic.wav", false);
    menuButtonSound = new SoundFile(parent, "assets/uiSound.wav", false);
    exitGameSound = new SoundFile(parent, "assets/exitSound.wav", false);
    winnerSound = new SoundFile(parent, "assets/winnerSound.wav", false);
    deathSound = new SoundFile(parent, "assets/deathSound.wav", false);
    defenderHitSound = new SoundFile(parent, "assets/playerHit.wav", false);
    dialupSound = new SoundFile(parent, "assets/dialup.wav", false);
    errorSound = new SoundFile(parent, "assets/error.wav", false);

    //Alternatively, uncomment the following and comment out the above:

    //gameMusic = new SoundFile(parent, "assets/gameMusic.wav");//an mp3 is available too
    //bulletSound = new SoundFile(parent, "assets/bullet.wav";
    //explosionSound = new SoundFile(parent, "assets/explosionMini.wav");
    //menuMusic = new SoundFile(parent, "assets/menuMusic.wav");
    //menuButtonSound = new SoundFile(parent, "assets/uiSound.wav");
    //exitGameSound = new SoundFile(parent, "assets/exitSound.wav");
    //winnerSound = new SoundFile(parent, "assets/winnerSound.wav");
    //deathSound = new SoundFile(parent, "assets/deathSound.wav");
    //defenderHitSound = new SoundFile(parent, "assets/playerHit.wav");
    //dialupSound = new SoundFile(parent, "assets/dialup.wav");
    //errorSound = new SoundFile(parent, "assets/error.wav");

    musicMuted = false;
    playDeathSound = true;
    gameMusic.amp(0.5);
    gameMusic.rate(1);
    menuMusic.amp(0.5);
    exitGameSound.amp(0.25);
    bulletSound.amp(0.25);
    bulletSound.rate(2);
    winnerSound.rate(0.85);
    menuMusic.rate(1);
    dialupSound.amp(0.5);
  }

  public void music() {
    if (!gameMusic.isPlaying() && !musicMuted && !menu) {
      gameMusic.loop();
    }
  }

  public void menuSoundBehaviour() {
    if (menu) {
      if (userInterface.shouldMenuSoundPlay() && !userInterface.getSoundPlayed()) {
        menuButtonSound.play();
        userInterface.setSoundPlayed(true);
      } else if (!userInterface.shouldMenuSoundPlay()) {
        userInterface.setSoundPlayed(false);
      }
    }
  }

  public void multiplayerGameScreenSound() {
    if (dialupSound.isPlaying()) {
      dialupSound.stop();
    }
    music();
  }

  public void defenderHitSound() {
    if (!defenderHitSound.isPlaying()) {
      defenderHitSound.play();
    } else {
      defenderHitSound.jump(0);//should reduce the memory usage of the sound library and prevent the library from crashing
    }
  }

  public void hitSound() {
    explosionSound.amp(0.1);
    if (!explosionSound.isPlaying()) {
      explosionSound.play();
    } else {
      explosionSound.jump(0);//should reduce the memory usage of the sound library and prevent the library from crashing
    }
  }

  public void deathSound() {
    explosionSound.amp(1);
    if (!explosionSound.isPlaying()) {
      explosionSound.play();
    } else {
      explosionSound.jump(0);//should reduce the memory usage of the sound library and prevent the library from crashing
    }
  }

  public void waitingSound() {
    if (!sounds.dialupSound.isPlaying()) {
      sounds.dialupSound.loop();
    }
  }

  public void menuMusic() {
    if (menu && !menuMusic.isPlaying() && !musicMuted) {
      menuMusic.loop();
    }
  }
  
  //Getters:
  public boolean getMusicMuted() {
    return musicMuted;
  }
  public boolean getPlayDeathSound() {
    return playDeathSound;
  }

  //Setters:
  public void setMusicMuted(boolean musicMuted) {
    this.musicMuted = musicMuted;
  }
  public void setPlayDeathSound(boolean playDeathSound){
    this.playDeathSound = playDeathSound;
  }
}
