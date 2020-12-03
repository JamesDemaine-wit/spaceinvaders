public class Multiplayer {

  public Server gameServer;
  public Client gameClient;
  private boolean connected, serverThreadRunning, clientThreadRunning;//whosTurn prevents parsing and sending at the same time, improves performance, client and server take turns updating.
  private String[] dataReceived;
  private String clientIP, negotiate;
  private int openPortAttempts; 

  //Setters:
  public void setConnected(boolean connected) {
    this.connected = connected;
  }
  public void setDataReceived(String[] dataReceived) {
    this.dataReceived = dataReceived;
  }
  public void setClientIP(String clientIP) {
    this.clientIP = clientIP;
  }
  public void setNegotiate(String negotiate) {
    this.negotiate = negotiate;
  }
  public void setOpenPortAttempts(int openPortAttempts) {
    this.openPortAttempts = openPortAttempts;
  }

  //Getters:
  public boolean getServerThreadRunning() {
    return serverThreadRunning;
  }
  public boolean getClientThreadRunning() {
    return clientThreadRunning;
  }
  public boolean getConnected() {
    return connected;
  }
  public String[] getDataReceived() {
    return dataReceived;
  }
  public String getClientIP() {
    return clientIP;
  }
  public String getNegotiate() {
    return negotiate;
  }
  public int getOpenPortAttempts() {
    return openPortAttempts;
  }

  //Constructor
  public Multiplayer() {
    connected = false;
    clientIP = "127.0.0.1";
    openPortAttempts = 0;
    negotiate = null;//initialised to null, isn't the "magic" keyword that accepts the connection
    serverThreadRunning = false;
    clientThreadRunning = false;
  }

  public void runMultiplayer() {//multiplayer menu screen behaviour.
    if (isHost) {
      if (connected) {
        sounds.multiplayerGameScreenSound();
        userInterface.gameScreen();
      } else {
        userInterface.waitingForClient();
        sounds.waitingSound();
      }
      if (!serverThreadRunning) {
        serverThreadRunning = true;
        thread("server");
        serverThreadRunning = false;//server();
      }
    }
    if (isClient) {
      if (connected) {
        sounds.multiplayerGameScreenSound();
        userInterface.gameScreenClient();
      } else {
        userInterface.waitingForServer();
        sounds.waitingSound();
      }
      if (!clientThreadRunning) {
        clientThreadRunning = true;
        thread("client");
        clientThreadRunning = false;//server();
      }
    }
  }

  public void openAPort(int port) {
    //Source - WaifUPnP docs
    if (UPnP.isUPnPAvailable()) { //is UPnP available?
      if (UPnP.isMappedTCP(port)) { //is the port already mapped?
        println("UPnP port forwarding not enabled: port is already mapped");
      } else if (UPnP.openPortTCP(port)) { //try to map port
        println("UPnP port forwarding enabled");
      } else {
        if (!UPnP.isMappedTCP(port) && openPortAttempts<3) {
          println("UPnP port forwarding failed, retrying");
          openAPort(port);
          openPortAttempts++;
        }
      }
    } else {
      println("UPnP is not available");
    }
  }

  public String generateClientData() {
    String dataToSend;
    //all positional floats have been converted to be proportianal to the display. ie, pos x at 800 of a 1000 wide display, is 0.8
    dataToSend = "begin.main ";//index 0
    dataToSend = dataToSend.concat(defender.getLives() + " ");//index 1
    dataToSend = dataToSend.concat(defender.getMaxLives() + " ");//index 2
    dataToSend = dataToSend.concat(buyCounter + " ");//index 3
    dataToSend = dataToSend.concat(score + " ");//index 4
    dataToSend = dataToSend.concat(numberOfAliens + " ");//index 5
    dataToSend = dataToSend.concat(debug + " ");//index 6
    dataToSend = dataToSend.concat(frameCount + " ");//index 7
    dataToSend = dataToSend.concat("end.main ");//index 8      //frame count will be used to adjust for correct deathFrame in each alien to maintain sync.
    dataToSend = dataToSend.concat("\nbegin.clientplayer ");//index 9
    dataToSend = dataToSend.concat((defender.getDefenderX()/displayWidth) + " ");//index 10
    dataToSend = dataToSend.concat((defender.getDefenderY()/displayHeight) + " ");//index 11
    dataToSend = dataToSend.concat(defender.getHitCooldown() + " ");//index 12
    dataToSend = dataToSend.concat(defender.getIsVisible() + " ");//index 13
    dataToSend = dataToSend.concat(defender.getTargetHit() + " ");//index 14
    dataToSend = dataToSend.concat(defender.getBullet().getBulletX()/displayWidth + " "); //index 15
    dataToSend = dataToSend.concat(defender.getBullet().getBulletY()/displayHeight + " "); //index 16
    dataToSend = dataToSend.concat(defender.getBullet().getFire() + " "); //index 17
    dataToSend = dataToSend.concat("end.clientplayer ");//index 18
    // lag? correctNumberOfAliens(); // forces a recheck of how many aliens there should be to maintain sync between client and server
    //As a new alien may not have been created yet or an old alien may not have been removed
    return dataToSend;
  }

  //public String generateServerData() {
  //  String dataToSend;
  //  //all positional floats have been converted to be proportianal to the display. ie, pos x at 800 of a 1000 wide display, is 0.8
  //  dataToSend = "begin.main ";//index 0
  //  dataToSend = dataToSend.concat(defender.getLives() + " ");//index 1
  //  dataToSend = dataToSend.concat(defender.getMaxLives() + " ");//index 2
  //  dataToSend = dataToSend.concat(buyCounter + " ");//index 3
  //  dataToSend = dataToSend.concat(score + " ");//index 4
  //  dataToSend = dataToSend.concat(numberOfAliens + " ");//index 5
  //  dataToSend = dataToSend.concat(debug + " ");//index 6
  //  dataToSend = dataToSend.concat(frameCount + " ");//index 7
  //  dataToSend = dataToSend.concat("end.main ");//index 8      //will be used to adjust for correct deathFrame in each alien to maintain sync.
  //  dataToSend = dataToSend.concat("\nbegin.serverplayer ");//index 9
  //  dataToSend = dataToSend.concat((defender.getDefenderX()/displayWidth) + " ");//index 10
  //  dataToSend = dataToSend.concat((defender.getDefenderY()/displayHeight) + " ");//index 11
  //  dataToSend = dataToSend.concat(defender.getHitCooldown() + " ");//index 12
  //  dataToSend = dataToSend.concat(defender.getIsVisible() + " ");//index 13
  //  dataToSend = dataToSend.concat(defender.getTargetHit() + " ");//index 14
  //  dataToSend = dataToSend.concat("end.serverplayer ");//index 15
  //  correctNumberOfAliens(); // forces a recheck of how many aliens there should be to maintain sync between client and server
  //  //As a new alien may not have been created yet or an old alien may not have been removed
  //  for (Alien a : aliens) {//iterate through each alien and add their variables to the string
  //    //variable indexes, will have to test alien number of each list of strings
  //    dataToSend = dataToSend.concat("\nbegin.alien."+ a.getAlienNumber() + " ");
  //    dataToSend = dataToSend.concat((a.getAlienBullet().getAlienBulletX()/displayWidth) + " ");
  //    dataToSend = dataToSend.concat((a.getAlienBullet().getAlienBulletY()/displayHeight) + " ");
  //    dataToSend = dataToSend.concat(a.getAlienBullet().getFiring() + " ");
  //    dataToSend = dataToSend.concat(a.getAlienBullet().getHitPlayer() + " ");
  //    dataToSend = dataToSend.concat(a.getAlienDeathState() + " ");
  //    dataToSend = dataToSend.concat((a.getAlienX()/displayWidth) + " ");
  //    dataToSend = dataToSend.concat((a.getAlienY()/displayHeight) + " ");
  //    dataToSend = dataToSend.concat(a.getDeathFrame() + " ");
  //    dataToSend = dataToSend.concat(a.getDirectionIsRight() + " ");
  //    dataToSend = dataToSend.concat(a.getExplosionSize() + " ");
  //    dataToSend = dataToSend.concat(a.getHits() + " ");
  //    dataToSend = dataToSend.concat(a.getMaxHits() + " ");
  //    dataToSend = dataToSend.concat("end.alien."+ a.getAlienNumber()+" ");
  //  }
  //  return dataToSend;
  //}

  public void parseReceivedClientData() {
    String rawDataReceived = multiplayer.gameClient.readString();
    if (rawDataReceived == null) { 
      println("nothing received");
      return;
    }
    boolean dataIntegrity = false;//to prevent nullpointer if the client sent garbage

    //create local variables for the client data, use local values to initialise,
    //prevents nullpointer in case of data integrity failure

    int clientLives = defenderTwo.getLives();
    // int clientMaxLives = defenderTwo.getMaxLives();
    int clientBuyCounter = buyCounter;
    int clientScore = score;
    //int clientNumberOfAliens = numberOfAliens;
    //boolean clientDebug = debug;
    //int clientFrameCount = frameCount;
    float clientDefenderX = defenderTwo.getDefenderX();
    float clientDefenderY = defenderTwo.getDefenderY();
    int clientDefenderHitCooldown = defenderTwo.getHitCooldown();
    boolean clientDefenderIsVisible = defenderTwo.getIsVisible();
    boolean clientDefenderTargetHit = defenderTwo.getTargetHit();
    float clientBulletX = defenderTwo.getBullet().getBulletX();
    float clientBulletY = defenderTwo.getBullet().getBulletY();
    boolean clientBulletFire = defenderTwo.getBullet().getFire();

    //split the client data

    multiplayer.setDataReceived(rawDataReceived.split(" "));
    if (debug) {
      println("dataReceived: "+rawDataReceived);
    }
    //verify client data and write to local equivalent
    if (multiplayer.getDataReceived()[0] == "begin.main " 
      && multiplayer.getDataReceived()[8] == "end.main " 
      && multiplayer.getDataReceived()[9] == "\nbegin.clientplayer "
      && multiplayer.getDataReceived()[18] == "end.clientplayer ") {
      dataIntegrity = true;

      //save data to local variables

      clientLives = int(multiplayer.getDataReceived()[1]);
      //clientMaxLives = int(dataReceived[2]);
      clientBuyCounter = int(multiplayer.getDataReceived()[3]);
      clientScore = int(multiplayer.getDataReceived()[4]);
      //clientNumberOfAliens = int(dataReceived[5]);
      //clientDebug = boolean(dataReceived[6]);
      //clientFrameCount = int(dataReceived[7]);
      clientDefenderX = float(multiplayer.getDataReceived()[10])*displayWidth;
      clientDefenderY = float(multiplayer.getDataReceived()[11])*displayHeight;//use local y pos?
      clientDefenderHitCooldown = int(multiplayer.getDataReceived()[12]);
      clientDefenderIsVisible = boolean(multiplayer.getDataReceived()[13]);
      clientDefenderTargetHit = boolean(multiplayer.getDataReceived()[14]);
      clientBulletX = float(multiplayer.getDataReceived()[15]);
      clientBulletY = float(multiplayer.getDataReceived()[16]);
      clientBulletFire = boolean(multiplayer.getDataReceived()[17]);
    }
    if (dataIntegrity) {
      if (clientLives<defenderTwo.getLives()) {
        defenderTwo.setLives(clientLives);
      }
      if (clientBuyCounter>buyCounter) {
        buyCounter = clientBuyCounter;
      }
      if (clientScore>score && clientBuyCounter == buyCounter) {
        score = clientScore;
      } else if (clientScore<score && clientBuyCounter>buyCounter) {
        buyCounter = clientBuyCounter;
        score = clientScore;
      }
      defenderTwo.setDefenderX(clientDefenderX);
      defenderTwo.setDefenderY(clientDefenderY);
      defenderTwo.setHitCoolDown(clientDefenderHitCooldown);
      defenderTwo.setIsVisible(clientDefenderIsVisible);
      defenderTwo.setTargetHit(clientDefenderTargetHit);
      defenderTwo.getBullet().setBulletX(clientBulletX);
      defenderTwo.getBullet().setBulletY(clientBulletY);
      defenderTwo.getBullet().setFire(clientBulletFire);
      multiplayer.gameClient.clear();
    } else {
      println("Received garbage when parsing client data.");
      multiplayer.gameClient.clear();
    }
  }
}
