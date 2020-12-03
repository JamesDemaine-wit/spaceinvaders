public class UserInterface {

  private boolean soundPlayed;

  public UserInterface() {
    soundPlayed = false;// prevents looping of ui sound
  }

  //Getters:
  public boolean getSoundPlayed() {
    return soundPlayed;
  }

  //Setters:
  public void setSoundPlayed(boolean soundPlayed) {
    this.soundPlayed = soundPlayed;
  }

  private void drawMultiplayerScreen() {
    sounds.menuMusic();
    background(0);
    drawBackground();
    drawBanner();
    drawHostButton();
    drawJoinButton();
    drawBackButton();
    drawLastScore();
    sounds.menuSoundBehaviour();
    menuCursor();
    debug();
  }

  public void singlePlayerUI() {
    if (!isMultiplayer) {
      if (menu) {
        menuScreen();//main menu screen
      } else {
        gameScreen();//singleplayer game
      }
    }
  }

  public void multiplayerUI() {
    if (isMultiplayer && menu && !(isHost || isClient)) {
      drawMultiplayerScreen();
    } else if ( isMultiplayer && (isHost || isClient)) {
      multiplayer.runMultiplayer();
    }
  }

  public void quitGame() {
    sounds.setPlayDeathSound(false);
    resetToMenu();
    sounds.setPlayDeathSound(true);
    key = 0;
    delay(500);
  }

  public boolean shouldMenuSoundPlay() {
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

  public void returnToMultiplayerMenu() {
    if (multiplayer.gameServer != null) {
      multiplayer.gameServer.stop();
      UPnP.closePortTCP(port);//close the port for good measure.
    }
    if (multiplayer.gameClient != null) {
      multiplayer.gameClient.stop();
    }
    if (sounds.dialupSound.isPlaying()) {
      sounds.dialupSound.stop();
    }
    multiplayer.gameServer = null;
    multiplayer.gameClient = null;
    multiplayer.setNegotiate(null);
    defenderTwo = null;
    isHost = false;
    isClient = false;
    key = 0;
  }

  public void gameScreen() {
    if (sounds.menuMusic.isPlaying()) {
      sounds.menuMusic.stop();
    }
    background(0);
    drawBackground();
    stats();
    defender.beADefender();
    drawAliens();
    debug();
    sounds.music();
  }

  public void gameScreenClient() {
    if (sounds.menuMusic.isPlaying()) {
      sounds.menuMusic.stop();
    }
    background(0);
    drawBackground();
    stats();
    defender.beADefender();
    debug();
    drawClientAliens(); //FIX THIS for aliens that only move based on server
    sounds.music();
  }

  public void waitingForClient() {
    if (sounds.menuMusic.isPlaying()) {
      sounds.menuMusic.stop();
    }
    background(0);
    drawBackground();
    debug();
    textAlign(CENTER);
    textSize(32);
    fill(255, 0, 0);
    String serverMessage = "Server is up and waiting for a client.\nServer Address is: "
      + externalIP + ":"
      + port
      +"\nPress 'Esc' to return the menu.";
    text(serverMessage, displayWidth/2, displayHeight/2-125);
  }

  public void waitingForServer() {
    if (sounds.menuMusic.isPlaying()) {
      sounds.menuMusic.stop();
    }
    background(0);
    drawBackground();
    debug();
    textAlign(CENTER);
    textSize(32);
    fill(255, 0, 0);
    String clientMessage = "Connecting...\nServer Address is: "
      + serverIP + ":"
      + port
      +"\nPress 'Esc' to return the menu.";
    text(clientMessage, displayWidth/2, displayHeight/2-125);
  }

  private void stats() {
    imageMode(CORNER);
    image(images.statsBoard, 0, 0, 480, 240);
    textAlign(LEFT);
    textSize(36);
    fill(0);
    text("SCORE: "+ score, 24, 48);
    text("LIVES: "+ defender.getLives(), 24, 88);
    if (sounds.getMusicMuted()) {
      text("MUSIC: Muted\nPress M to unmute.", 24, 160);
    }
    if (!sounds.getMusicMuted()) {
      text("MUSIC: ON\nPress M to mute.", 24, 160);
    }
    if (score>=500*buyCounter && defender.getLives()<defender.getMaxLives()) {
      textAlign(CENTER);
      fill(255,0,0);
      text("Right click to buy more lives using "+ 500*buyCounter + " of your score.", displayWidth/2, displayHeight-50);
    }
  }

  private void drawAliens() {
    for (Alien a : aliens) {
      a.beAnAlien();
    }
    correctNumberOfAliens();
  }

  private void drawClientAliens() {
    for (Alien a : aliens) {
      a.beAClientAlien();
    }
    correctNumberOfAliens();
  }

  private void drawBackground() {
    fill(255);
    imageMode(CORNER);
    image(images.backgroundAsset, 0, 0, displayWidth, displayHeight);
  }

  private void menuScreen() {
    sounds.menuMusic();
    background(0);
    drawBackground();
    drawBanner();
    drawPlayButton();
    drawQuitButton();
    drawMultiplayerButton();
    drawLastScore();
    sounds.menuSoundBehaviour();
    debug();
    menuCursor();
  }

  private void drawPlayButton() {
    if (drawButton(images.playButtonAsset, images.playButtonAssetHighlighted, displayWidth/2, displayHeight/2-125, 300, 100)) {
      score = 0;
      menu = false;
    }
  }

  private void drawQuitButton() {
    if (drawButton(images.quitButtonAsset, images.quitButtonAssetHighlighted, displayWidth/2, displayHeight/2, 300, 100)) {
      sounds.menuMusic.stop();
      sounds.exitGameSound.play();

      delay(1100);
      exit();
    }
  }

  private void drawHostButton() {
    if (drawButton(images.hostButtonAsset, images.hostButtonAssetHighlighted, displayWidth/2, displayHeight/2-125, 300, 100)) {
      score = 0;
      isHost = true;
    }
  }

  private void drawJoinButton() {
    if (drawButton(images.joinButtonAsset, images.joinButtonAssetHighlighted, displayWidth/2, displayHeight/2, 300, 100)) {
      askForAddress();
    }
  }

  private void drawBackButton() {
    if (drawButton(images.backButtonAsset, images.backButtonAssetHighlighted, displayWidth/2, displayHeight/2+125, 300, 100)) {
      isMultiplayer = false;
      multiplayer.gameServer = null;
    }
  }

  private void drawMultiplayerButton() {
    if (drawButton(images.multiplayerButtonAsset, images.multiplayerButtonAssetHighlighted, displayWidth/2 +250, displayHeight/2 - 125, 64, 64)) {
      if (multiplayerEnabled) {
        isMultiplayer = true;
      } else {
        if (!sounds.errorSound.isPlaying()) {
          sounds.errorSound.play();
        }
        textAlign(CENTER);
        textSize(24);
        fill(255, 0, 0);
        text("Coming in V1.0!", displayWidth/2 +250, displayHeight/2 - 175);
      }
    }
  }

  private void menuCursor() {
    drawDefenderShip(mouseX, mouseY+25, 50);
  }

  private void drawDefenderShip(float x, float y, float size) {
    imageMode(CENTER);
    image(images.defenderShipAsset, x, y, size, size);
  }

  private void drawLastScore() {
    textAlign(CENTER);
    textSize(36);
    fill(255);
    text("Last Score: " + score, displayWidth/2, 30);
  }

  private void drawBanner() {
    imageMode(CENTER);
    image(images.bannerAsset, displayWidth/2, 150, 800, 150);
  }

  private boolean drawButton(PImage image, PImage imageHighlighted, float xPos, float yPos, int imageWidth, int imageHeight) {
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

  private boolean checkButton(float xPos, float yPos, int imageWidth, int imageHeight) {
    if (mouseX<=xPos+(imageWidth/2) && mouseX>=xPos-(imageWidth/2) && mouseY<=yPos+(imageHeight/2) && mouseY>=yPos-(imageHeight/2)) {
      return true;
    } else {
      return false;
    }
  }

  public void errorMessage(String message, boolean externalCall) {
    if (externalCall) {
      com.jogamp.newt.opengl.GLWindow window = (com.jogamp.newt.opengl.GLWindow)(((PSurfaceJOGL)surface).getNative());
      noLoop();//prevents trying to draw while the window is not being displayed - will be resumed when sketch comes back into focus.
      window.setVisible(false);//hide the window
      JOptionPane.showMessageDialog(null, message);
      window.setVisible(true);//display the window
      window.requestFocus();
      loop();//resumes drawing
    } else {
      JOptionPane.showMessageDialog(null, message);
    }
  }

  private void askForAddress() {
    //Using: https://stackoverflow.com/questions/39107750/java-and-processing-3-0-frame-class-deprecated-is-there-an-alternative
    //casting PSurface window to OpenGL window and saving to GLWindow, to call its methods.
    //the frame object did not have the method needed.

    com.jogamp.newt.opengl.GLWindow window = (com.jogamp.newt.opengl.GLWindow)(((PSurfaceJOGL)surface).getNative());
    noLoop();//prevents trying to draw while the window is not being displayed - will be resumed when sketch comes back into focus.
    window.setVisible(false);//hide the window

    //now that the window is hidden, ask for input: 
    String userInput = JOptionPane.showInputDialog(null, "Enter Server IP:", "127.0.0.1");//request the IP
    if (userInput == null || userInput == "127.0.0.1") {
      errorMessage("You need to enter an IP address to play online.", false);
      window.setVisible(true);//display the window
      window.requestFocus();
      loop();//resumes drawing
      returnToMultiplayerMenu();
    } else if (userInput.length()>15) {
      errorMessage("Input too long!", false);
      askForAddress();
      return;//return is to prevent the rest of the first instance of the method from continuing if it is called again
    } else if (userInput.contains(".")) {//looks similar to an IP?
      String[] sections = userInput.split("\\D", 4);//only checks non-digits, assuming '.' as the non digits
      for (String s : sections) {
        //regex support for hostnames in future?
        boolean match3 = Pattern.matches("\\d{3}", s);//any digit 0-9, length of 3
        boolean match2 = Pattern.matches("\\d{2}", s);//    ""       , length of 2
        boolean match1 = Pattern.matches("\\d{1}", s);//    ""        , length of 1
        if (!match3 && !match2 && !match1) {
          errorMessage("That was not a valid IP address.", false);
          askForAddress();
          return;
        }
      }
      serverIP = userInput;
      println("User connecting to IP: "+userInput);
      window.setVisible(true);//display the window
      window.requestFocus();
      loop();//resumes drawing
      score = 0;
      isClient = true;
      sounds.menuMusic.stop();
    } else {
      errorMessage("That was not an IP address.", false);
      println(userInput);
      askForAddress();
      return;
    }
  }

  private void debug() {
    int mb = 1024 * 1024;
    int used = int(((instance.totalMemory()/mb)-(instance.freeMemory()/mb)));
    int total = int((instance.totalMemory()/mb));
    if (!debug) {
      fill(0, 255, 0);
      textAlign(RIGHT);
      textSize(16);
      text("Press F1 for Debug", displayWidth, 20);
    }
    if (debug && !menu) {
      //I added in memory usage as I ran into an issue when loading large image and audio files
      fill(0, 255, 0);
      textAlign(RIGHT);
      textSize(16);
      text("Display Dimensions: "+ displayWidth + " x " + displayHeight, displayWidth, 20);
      text("Framerate: "+ int(frameRate), displayWidth, 40);
      text("Fire: "+ defender.getBullet().getFire(), displayWidth, 60);
      text("Buy Counter: "+ (buyCounter-1), displayWidth, 80);
      text("Number Of Aliens: "+ numberOfAliens, displayWidth, 100);
      text("Are All Aliens Dead: "+areAliensAllDead(), displayWidth, 120);
      text("Memory: "+ used + "MB / "+ total + "MB", displayWidth, 140);
    }
    if (debug && menu && !(isHost || isClient)) {
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
        text("Connected: "+multiplayer.getConnected(), displayWidth, 140);
        text("Display Dimensions: "+ displayWidth + " x " + displayHeight, displayWidth, 160);
        text("Framerate: "+ int(frameRate), displayWidth, 180);
        text("Memory: "+ used + "MB / "+ total + "MB", displayWidth, 200);
      } else if (isClient && multiplayer.gameClient != null) {
        text("Game Client:", displayWidth, 80);
        text("Active: "+ multiplayer.gameClient.active(), displayWidth, 100);
        text("Connected: "+multiplayer.getConnected(), displayWidth, 120);
        text("Display Dimensions: "+ displayWidth + " x " + displayHeight, displayWidth, 140);
        text("Framerate: "+ int(frameRate), displayWidth, 160);
        text("Memory: "+ used + "MB / "+ total + "MB", displayWidth, 180);
      }
    }
  }
}
