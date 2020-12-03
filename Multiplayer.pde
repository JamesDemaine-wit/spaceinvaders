public class Multiplayer {

  private Server gameServer;
  private Client gameClient;
  private boolean connected;//whosTurn prevents parsing and sending at the same time, improves performance, client and server take turns updating.
  private String[] dataReceived;
  private String clientIP, negotiate;
  private int openPortAttempts; 

  //Constructor
  public Multiplayer() {
    connected = false;
    clientIP = "127.0.0.1";
    openPortAttempts = 0;
    negotiate = null;//initialised to null, isn't the "magic" keyword that accepts the connection
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
      server();
    }
    if (isClient) {
      if (connected) {
        sounds.multiplayerGameScreenSound();
        userInterface.gameScreenClient();
      } else {
        userInterface.waitingForServer();
        sounds.waitingSound();
      }
      client();
    }
  }

  //private void negotiateConnectionServerSide() {
  //  negotiate = gameClient.readString();//save string
  //    gameServer.write("SpaceInvaders");//tell the client servers string
  //  if (negotiate.contains("IamAclient")) {//test string
  //    clientIP = gameClient.ip();
  //    println("Connection accepted by Server! Client IP is: "+ clientIP);
  //    connected = true;
  //    //this method should not be called again if this code ran
  //  } else if (!negotiate.contains("IamAclient") && negotiate != null) {
  //    println("Garbage received, resetting buffer. Received: "+ negotiate);
  //    gameClient.clear();
  //    clientIP = "127.0.0.1";
  //    negotiate = null;
  //  } else if (negotiate == null) {
  //    println("Waiting for a client...");
  //  }
  //}


  //private void negotiateConnectionClientSide() {
  //  gameClient.write("IamAclient");
  //  if (gameClient.available()>0) {
  //    negotiate = gameClient.readString();
  //  }
  //  if (negotiate.contains("SpaceInvaders")) {
  //    connected = true;
  //    println("Connection accepted by Server!");
  //  } else if (!negotiate.contains("SpaceInvaders") && negotiate != null) {
  //    println("Garbage received, resetting buffer. Received: "+ negotiate);
  //    gameClient.clear();
  //    connected = false;
  //    negotiate = null;
  //  } else if (negotiate == null) {
  //    connected = false;
  //  }
  //}


  private void client() {
    if (gameClient != null) {
      if (!gameClient.active()) {//should see the server if this gameClient.active() is true
        println("Don't mind the exception, processing net library won't let me catch it.");
        gameClient = null;
      } else {//if this runs, the client sees a server, send data.
        if (!connected && gameClient.active()) {
          connected = true;
          defenderTwo = new Defender(true);//create player one (server is player one)
          println("Connected to: " + serverIP + ":" + port);
        } else if (gameClient.available()>0) {
          println("reading data");
          //parsReceivedServerData(gameClient.readString());//client side parsing of server's data
          gameClient.write(generateClientData());
        }
      }
    } else if ( gameClient == null) {
      println("setup client");
      gameClient = new Client(parent, serverIP, port);
      //Should throw an exception if the server refuses connection,
      //library catches exception instead of throwing it. 
      //rather annoying, so I have to check for the connection in the next loop cycle
    }
  }


  private void server() {
    if (!UPnP.isMappedTCP(port) && openPortAttempts<3) {
      println("The port is closed, attempting to open again! Expect latency!");
      openAPort(port);
      openPortAttempts++;
    }
    if (gameServer != null) {//needs to be nested in case game server is null, as the next if statement has reference to gameserver
      if (gameClient == null) {
        gameClient = gameServer.available();
        println("Attempting to capture client data");
      }
      if (gameClient != null) {//found a client!
        if (!connected) {
          connected = true;
          defenderTwo = new Defender(true);//create player two (client is player two)
        }
        if (gameClient.available()>0) {//check there is a client connected and data is received
          thread("parseReceivedClientData"); //server side parsing of client's data
          gameServer.write(generateServerData());
        }
      }
    } else if (gameServer == null) {
      //set up the game as the server
      println("setup server");
      gameServer = new Server(parent, port);//ready to send data to client
      gameClient = null;
      openAPort(port);
    }
  }

  private void openAPort(int port) {
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
    correctNumberOfAliens(); // forces a recheck of how many aliens there should be to maintain sync between client and server
    //As a new alien may not have been created yet or an old alien may not have been removed
    return dataToSend;
  }

  public String generateServerData() {
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
    dataToSend = dataToSend.concat("end.main ");//index 8      //will be used to adjust for correct deathFrame in each alien to maintain sync.
    dataToSend = dataToSend.concat("\nbegin.serverplayer ");//index 9
    dataToSend = dataToSend.concat((defender.getDefenderX()/displayWidth) + " ");//index 10
    dataToSend = dataToSend.concat((defender.getDefenderY()/displayHeight) + " ");//index 11
    dataToSend = dataToSend.concat(defender.getHitCooldown() + " ");//index 12
    dataToSend = dataToSend.concat(defender.getIsVisible() + " ");//index 13
    dataToSend = dataToSend.concat(defender.getTargetHit() + " ");//index 14
    dataToSend = dataToSend.concat("end.serverplayer ");//index 15
    correctNumberOfAliens(); // forces a recheck of how many aliens there should be to maintain sync between client and server
    //As a new alien may not have been created yet or an old alien may not have been removed
    for (Alien a : aliens) {//iterate through each alien and add their variables to the string
      //variable indexes, will have to test alien number of each list of strings
      dataToSend = dataToSend.concat("\nbegin.alien."+ a.getAlienNumber() + " ");
      dataToSend = dataToSend.concat((a.getAlienBullet().getAlienBulletX()/displayWidth) + " ");
      dataToSend = dataToSend.concat((a.getAlienBullet().getAlienBulletY()/displayHeight) + " ");
      dataToSend = dataToSend.concat(a.getAlienBullet().getFiring() + " ");
      dataToSend = dataToSend.concat(a.getAlienBullet().getHitPlayer() + " ");
      dataToSend = dataToSend.concat(a.getAlienDeathState() + " ");
      dataToSend = dataToSend.concat((a.getAlienX()/displayWidth) + " ");
      dataToSend = dataToSend.concat((a.getAlienY()/displayHeight) + " ");
      dataToSend = dataToSend.concat(a.getDeathFrame() + " ");
      dataToSend = dataToSend.concat(a.getDirectionIsRight() + " ");
      dataToSend = dataToSend.concat(a.getExplosionSize() + " ");
      dataToSend = dataToSend.concat(a.getHits() + " ");
      dataToSend = dataToSend.concat(a.getMaxHits() + " ");
      dataToSend = dataToSend.concat("end.alien."+ a.getAlienNumber()+" ");
    }
    return dataToSend;
  }


  public void parseReceivedClientData() {
    String rawDataReceived = gameClient.readString();
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
    dataReceived = rawDataReceived.split(" ");
    if (debug) {
      println("dataReceived: "+rawDataReceived);
    }
    //verify client data and write to local equivalent
    if (dataReceived[0] == "begin.main " 
      && dataReceived[8] == "end.main " 
      && dataReceived[9] == "\nbegin.clientplayer "
      && dataReceived[18] == "end.clientplayer ") {
      dataIntegrity = true;
      //save data to local variables
      clientLives = int(dataReceived[1]);
      //clientMaxLives = int(dataReceived[2]);
      clientBuyCounter = int(dataReceived[3]);
      clientScore = int(dataReceived[4]);
      //clientNumberOfAliens = int(dataReceived[5]);
      //clientDebug = boolean(dataReceived[6]);
      //clientFrameCount = int(dataReceived[7]);
      clientDefenderX = float(dataReceived[10])*displayWidth;
      clientDefenderY = float(dataReceived[11])*displayHeight;//use local y pos?
      clientDefenderHitCooldown = int(dataReceived[12]);
      clientDefenderIsVisible = boolean(dataReceived[13]);
      clientDefenderTargetHit = boolean(dataReceived[14]);
      clientBulletX = float(dataReceived[15]);
      clientBulletY = float(dataReceived[16]);
      clientBulletFire = boolean(dataReceived[17]);
    }
    if (dataIntegrity) {
      if (clientLives<defenderTwo.getLives()) {
        defenderTwo.setLives(int(dataReceived[1]));
      }
      if (clientBuyCounter>buyCounter) {
        buyCounter = int(dataReceived[3]);
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
    } else {
      println("Received garbage when parsing client data.");
    }
  }

  //Setters:
  public void setGameServer(Server gameServer) {
    this.gameServer = gameServer;
  }
  public void setGameClient(Client gameClient) {
    this.gameClient = gameClient;
  }
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
  public Server getGameServer() {
    return gameServer;
  }
  public Client getGameClient() {
    return gameClient;
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
}
