public class UserInterface {

  boolean soundPlayed;

  UserInterface() {
    soundPlayed = false;// prevents looping of ui sound
  }

  void drawMultiplayerScreen() {
    sounds.menuMusic();
    background(0);
    drawBackground();
    drawMenuLayoutMultiplayer();
    menuCursor();
    debug();
  }

  void singleplayerUISelector() {
    if (!isMultiplayer) {
      if (menu) {
        menuScreen();//main menu screen
      } else {
        gameScreen();//singleplayer game
      }
    }
  }

  void multiplayerUISelector() {
    if (isMultiplayer) {
      if (menu && !(isHost || isClient)) {
        drawMultiplayerScreen();
      }
      if (isHost && !isClient) {//hosting the game
        //drawHostGameScreen();
        multiplayer.runMultiplayer();
      } else if (!isHost && isClient) {//joining the game
        //drawClientGameScreen();
        multiplayer.runMultiplayer();
      }
    }
  }

  void quitGame() {
    sounds.playDeathSound = false;
    resetToMenu();
    sounds.playDeathSound = true;
    key = 0;
    delay(500);
  }

  void stats() {
    textAlign(LEFT);
    textSize(24);
    fill(255, 0, 0);
    text("SCORE: "+ score, 10, 24);
    text("LIVES: "+ defender.getLives(), 10, 48);
    if (sounds.getMusicMuted()) {
      text("MUSIC: OFF - Press M to turn on.", 10, 72);
    }
    if (!sounds.getMusicMuted()) {
      text("MUSIC: ON - Press M to turn off.", 10, 72);
    }
    if (score>=500*buyCounter && defender.getLives()<defender.getMaxLives()) {
      textAlign(CENTER);
      text("Right click to buy more lives using "+ 500*buyCounter + " of your score.", displayWidth/2, displayHeight/3);
    }
  }

  void returnToMultiplayerMenu() {
    if (isHost) {
      multiplayer.gameServer.stop();
    }
    if (isClient) {
      multiplayer.gameClient.stop();
    }
    if (sounds.dialupSound.isPlaying()) {
      sounds.dialupSound.stop();
    }
    multiplayer.gameServer = null;
    multiplayer.gameClient = null;
    defenderTwo = null;
    isHost = false;
    isClient = false;
    key = 0;
  }


  void freezeScreenUnfocused() {
    if (!focused) {
      frame.toFront();
      frame.requestFocus();
      if (!focused) {//checks again before freezing the screen incase the request was successful.
        sounds.menuMusic.stop();
        sounds.gameMusic.stop();
        noLoop();
      }
    }
  }

  void drawAliens() {
    for (Alien a : aliens) {
      a.beAnAlien();
    }
    correctNumberOfAliens();
  }

  void drawClientAliens() {
    for (Alien a : aliens) {
      a.beAClientAlien();
    }
    correctNumberOfAliens();
  }

  void drawBackground() {
    fill(255);
    imageMode(CORNER);
    image(images.backgroundAsset, 0, 0, displayWidth, displayHeight);
  }

  void gameScreen() {
    if (sounds.menuMusic.isPlaying()) {
      sounds.menuMusic.stop();
    }
    background(0);
    drawBackground();
    defender.beADefender();
    drawAliens();
    debug();
    stats();
    sounds.music();
  }

  void gameScreenClient() {
    if (sounds.menuMusic.isPlaying()) {
      sounds.menuMusic.stop();
    }
    background(0);
    drawBackground();
    defender.beADefender();
    debug();
    drawClientAliens(); //FIX THIS for aliens that only move based on server
    stats();
    sounds.music();
  }

  void waitingForClient() {
    if (sounds.menuMusic.isPlaying()) {
      sounds.menuMusic.stop();
    }
    background(0);
    drawBackground();
    debug();
    drawServerWaitingScreen();
  }

  void waitingForServer() {
  }

  void menuScreen() {
    sounds.menuMusic();
    background(0);
    drawBackground();
    drawMenuLayout();
    debug();
    menuCursor();
  }

  void drawMenuLayout() {
    drawBanner();
    drawPlayButton();
    drawQuitButton();
    drawMultiplayerButton();
    drawLastScore();
    sounds.menuSoundBehaviour();
  }

  void drawServerWaitingScreen() {
    textAlign(CENTER);
    textSize(32);
    fill(255, 0, 0);
    String serverMessage = "Server is up and waiting for a client.\nServer Address is: "
      + externalIP + ":"
      + port
      +"\nPress 'Esc' to return the menu.";
    text(serverMessage, displayWidth/2, displayHeight/2-125);
  }

  void drawMenuLayoutMultiplayer() {
    drawBanner();
    drawHostButton();
    drawJoinButton();
    drawBackButton();
    drawLastScore();
    sounds.menuSoundBehaviour();
  }

  void drawPlayButton() {
    if (drawButton(images.playButtonAsset, images.playButtonAssetHighlighted, displayWidth/2, displayHeight/2-125, 300, 100)) {
      score = 0;
      menu = false;
    }
  }

  void drawQuitButton() {
    if (drawButton(images.quitButtonAsset, images.quitButtonAssetHighlighted, displayWidth/2, displayHeight/2, 300, 100)) {
      sounds.menuMusic.stop();
      sounds.exitGameSound.play();

      delay(1100);
      exit();
    }
  }

  void drawHostButton() {
    if (drawButton(images.hostButtonAsset, images.hostButtonAssetHighlighted, displayWidth/2, displayHeight/2-125, 300, 100)) {
      score = 0;
      isHost = true;
    }
  }

  void drawJoinButton() {
    if (drawButton(images.joinButtonAsset, images.joinButtonAssetHighlighted, displayWidth/2, displayHeight/2, 300, 100)) {
      //score = 0;
      //isClient = true;
      if (!sounds.errorSound.isPlaying()) {
        sounds.errorSound.play();
        //askForServerAddress();
      }
      textAlign(LEFT);
      textSize(24);
      fill(255, 0, 0);
      text("Almost ready!", displayWidth/2+155, displayHeight/2);
    }
  }

  void drawBackButton() {
    if (drawButton(images.backButtonAsset, images.backButtonAssetHighlighted, displayWidth/2, displayHeight/2+125, 300, 100)) {
      isMultiplayer = false;
      multiplayer.gameServer = null;
    }
  }

  void drawMultiplayerButton() {
    if (drawButton(images.multiplayerButtonAsset, images.multiplayerButtonAssetHighlighted, displayWidth/2 +250, displayHeight/2 - 125, 64, 64)) {
      isMultiplayer = true;
      //if (!sound.deathSound.isPlaying()) {
      //  sound.deathSound.play();
      //}
    }
  }

  boolean shouldMenuSoundPlay() {
    if (menu && !isMultiplayer) {
      boolean playButton = checkButton(displayWidth/2, displayHeight/2-125, 300, 100);
      boolean quitButton = checkButton(displayWidth/2, displayHeight/2, 300, 100);
      boolean multiplayerButton = checkButton(displayWidth/2 +250, displayHeight/2 - 125, 64, 64);
      if (playButton || quitButton || multiplayerButton) {
        return true;
      } else if (!playButton && !quitButton && !multiplayerButton) {
        return false;
      }
    }
    if (menu && isMultiplayer && !isHost && !isClient) {
      boolean hostButton = checkButton(displayWidth/2, displayHeight/2-125, 300, 100);
      boolean joinButton = checkButton(displayWidth/2, displayHeight/2, 300, 100);
      boolean backButton = checkButton(displayWidth/2, displayHeight/2+125, 300, 100);
      if (hostButton || joinButton || backButton) {
        return true;
      } else if (!hostButton && !joinButton && !backButton) {
        return false;
      }
    } 
    return false;
  }

  void menuCursor() {
    drawDefenderShip(mouseX, mouseY+25, 50);
  }

  void drawDefenderShip(float x, float y, float size) {
    imageMode(CENTER);
    image(images.defenderShipAsset, x, y, size, size);
  }

  void drawLastScore() {
    textAlign(CENTER);
    textSize(36);
    fill(255);
    text("Last Score: " + score, displayWidth/2, 30);
  }

  void drawBanner() {
    imageMode(CENTER);
    image(images.bannerAsset, displayWidth/2, 150, 800, 150);
  }

  boolean drawButton(PImage image, PImage imageHighlighted, float xPos, float yPos, int imageWidth, int imageHeight) {
    imageMode(CENTER);
    if (checkButton(xPos, yPos, imageWidth, imageHeight)) {
      image(imageHighlighted, xPos, yPos, imageWidth, imageHeight);
    } else {
      image(image, xPos, yPos, imageWidth, imageHeight);
    }
    if (checkButton(xPos, yPos, imageWidth, imageHeight) && mousePressed && mouseButton == LEFT) {
      return true;
    } else {
      return false;
    }
  }

  boolean checkButton(float xPos, float yPos, int imageWidth, int imageHeight) {
    if (mouseX<=xPos+(imageWidth/2) && mouseX>=xPos-(imageWidth/2) && mouseY<=yPos+(imageHeight/2) && mouseY>=yPos-(imageHeight/2)) {
      return true;
    } else {
      return false;
    }
  }

  void debug() {
    if (!debug) {
      fill(0, 255, 0);
      textAlign(RIGHT);
      textSize(16);
      text("Press F1 for Debug", displayWidth, 20);
    }
    if (debug && !menu) {
      int mb = 1024 * 1024; //https://crunchify.com/java-runtime-get-free-used-and-total-memory-in-java/
      int used = int(((instance.totalMemory()/mb)-(instance.freeMemory()/mb)));
      int total = int((instance.totalMemory()/mb)); 
      //I added in memory usage as I ran into an issue when loading large image and audio files
      fill(0, 255, 0);
      textAlign(RIGHT);
      textSize(16);
      text("Display Dimensions: "+ displayWidth + " x " + displayHeight, displayWidth, 20);
      text("Framerate: "+ int(frameRate), displayWidth, 40);
      text("Fire: "+ defender.bullet.fire, displayWidth, 60);
      text("Buy Counter: "+ (buyCounter-1), displayWidth, 80);
      text("Number Of Aliens: "+ numberOfAliens, displayWidth, 100);
      text("Are All Aliens Dead: "+areAliensAllDead(), displayWidth, 120);
      text("Memory: "+ used + "MB / "+ total + "MB", displayWidth, 140);
    }
    if (debug && menu && !(isHost || isClient)) {
      int mb = 1024 * 1024;
      int used = int(((instance.totalMemory()/mb)-(instance.freeMemory()/mb)));
      int total = int((instance.totalMemory()/mb));
      textAlign(RIGHT);
      fill(0, 255, 0);
      textSize(16);
      text("Display Dimensions: "+ displayWidth + " x " + displayHeight, displayWidth, 20);
      text("Framerate: "+ int(frameRate), displayWidth, 40);
      text("Memory: "+ used + "MB / "+ total + "MB", displayWidth, 60);
    }
    if (debug && menu && isMultiplayer && (isHost || isClient)) { //Created to find source of a crackling sound in the host waiting screen
      textAlign(RIGHT);
      fill(0, 255, 0);
      textSize(16);
      text("Available at: "+ externalIP + ":"+ port, displayWidth, 20);
      text("UPnP Avail: "+ UPnP.isUPnPAvailable(), displayWidth, 40);
      text("UPnP: "+ UPnP.isMappedTCP(port), displayWidth, 60);
      if (isHost && multiplayer.gameServer !=null) {
        text("Game Server:", displayWidth, 80);
        text("Active: "+ multiplayer.gameServer.active(), displayWidth, 100);
        text("Number of Clients: "+ multiplayer.gameServer.clientCount, displayWidth, 120);
      }
    }
  }
}
