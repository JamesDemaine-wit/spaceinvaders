import java.awt.Frame;
import processing.net.*;
import processing.sound.*;
import java.time.*;
import com.dosse.upnp.*;
import javax.swing.*;
import java.util.regex.*;
//third party/non-processing libraries:
//WaifUPnP  Source: https://github.com/adolfintel/WaifUPnP
//Only change I made to the jar file was including "this" in the class path of the manifest. 
//(I am not certain, but I believe this is to reference the parent class of the jar file)
//with help from:
//https://www.skotechlearn.com/2019/11/change-main-class-in-java-netbeans.html 
//and 
//https://processing.org/reference/environment/#Extensions

//server ip is only for the client to use. need to make a new pop up/menu screen for the input.
// negotiate requires the client to send the string "Negotiate" to ensure a random packet doesn't trigger the game to start.
// Learnt this the hard way when testing for open ports using and app on my cellphone.
//I used the minecraft port, since it is well known by ISP's and won't be likely to get blocked.

public Multiplayer multiplayer;
public int buyCounter, score, numberOfAliens, port;
public String serverIP, externalIP;
public boolean debug, isMultiplayer, menu, isHost, isClient, multiplayerEnabled;//some are used by both UI and Multiplayer classes, made them global
public Defender defender, defenderTwo;
public ArrayList<Alien> aliens;
public Runtime instance;
public UserInterface userInterface;
public Audio sounds;
public PApplet parent;
public Images images;
public float alienWidth, alienHeight;

//Data is mostly initialised in setup to use it for resetting the sketch
public void setup() {
  parent = this; //used to reference the audio files correctly to the main tab
  images = new Images();
  serverIP = "127.0.0.1";
  externalIP = UPnP.getExternalIP();
  port = 25565;//Using one port, no optional use of different port. new feature?
  fullScreen(P2D);//using the P2D OpenGL renderer improves framerate, especially when scaling images to non-native resolutions.
  pixelDensity(displayDensity());//ensures compatibility accross different resolutions.
  frameRate(60);
  background(0);
  noStroke();
  noCursor();
  multiplayerEnabled = false;
  debug = false;
  menu = true;
  isHost = false;
  isClient = false;
  isMultiplayer = false;
  userInterface = new UserInterface();
  defender = new Defender();
  multiplayer = new Multiplayer();
  buyCounter = 1;
  alienWidth = 90;
  alienHeight = 150;
  instance = Runtime.getRuntime();
  aliens = new ArrayList<Alien>();
  numberOfAliens = 4;
  for (int i = 1; i <= numberOfAliens; i++) {
    aliens.add(new Alien(i));
  }
  sounds = new Audio();
  instance.gc(); //if the game is reloaded, removes old junk
}

public void draw() {
  userInterface.singlePlayerUI();
  userInterface.multiplayerUI();
  //userInterface.freezeScreenUnfocused();
}

void correctNumberOfAliens() {
  if (aliens.size()<numberOfAliens) {
    for (int i = aliens.size(); i < numberOfAliens; i++) {//when there are fewer aliens than there should be;
      aliens.add(new Alien(i));//adds another alien to the list
    }
  }
  if (aliens.size()>numberOfAliens) {
    for (int i = aliens.size(); i > numberOfAliens; i--) {//when there are more aliens than there should be
      aliens.remove(i-1);//removes last alien from the list
    }
    instance.gc();
  }
}

public void buyLivesWithScore() {
  if (score>=500*buyCounter && defender.getLives()<defender.getMaxLives()) {
    score-=500*buyCounter;
    defender.setLives(defender.getLives()+1);
    buyCounter++;
  }
}

public void bonusScore() {
  if (areAliensAllDead()) {
    if (200-(5*buyCounter)*defender.getLives() > 5) {
      score+=200-(5*buyCounter)*defender.getLives();
      sounds.winnerSound.play();
    } else {
      score+=5;
      sounds.winnerSound.play();
    }
  }
}

public void resetToMenu() {
  sounds.gameMusic.stop();
  menu = true;
  if (sounds.getPlayDeathSound()) {
    sounds.deathSound.play();
  }
  setup();
  delay(500);
}

public boolean areAliensAllDead() { // Source: Michael Gerber - see readme)
  for (Alien a : aliens) {
    //"The way I did it, it will cycle through the list and as soon as one is alive,
    //it will return false and stop the whole for loop and ignore the rest of the list (Better optimized for large lists)"
    if (!a.getAlienDeathState()) { 
      return false;
    }
  }  
  return true;
}

public void mousePressed() {
  if (mouseButton == LEFT && focused && !menu && !(isHost || isClient)) {
    if (!defender.getBullet().getFire()) {
      defender.getBullet().setFire(true);
    }
  } else if (mouseButton == LEFT && focused && multiplayer.getConnected()) {
    if (isHost) {
      if (!defender.getBullet().getFire()) {
        defender.getBullet().setFire(true);
      }
    } else if (isClient) {
      if (!defenderTwo.getBullet().getFire()) {
        defenderTwo.getBullet().setFire(true);
      }
    }
  }
  if (focused) {
    loop();
  }
}

public void mouseClicked() {
  if (mouseButton == RIGHT && !menu) {
    buyLivesWithScore();
  }
}

public void keyReleased() {
  if (keyCode == 97) {
    if (debug == true) {
      debug = false;
    } else if (debug == false) {
      debug = true;
    }
  }
  if (keyCode == 105) {
    instance.gc(); //F9 acts as a garbage collector. I used this when resolving audio issues
  }
  if (keyCode == 77) {
    if (sounds.getMusicMuted()) {
      sounds.setMusicMuted(false);
    } else {
      sounds.setMusicMuted(true);
      sounds.gameMusic.stop();
    }
  }
}

//Source: https://forum.processing.org/one/topic/ignore-escape-key-do-other-action.html

public void keyPressed() {
  if (key == ESC && !menu) {
    userInterface.quitGame();
  }
  if (key == ESC && isMultiplayer && (isHost || isClient)) {
    userInterface.returnToMultiplayerMenu();
  }
  if (key == ESC && menu && isMultiplayer && !isHost && !isClient) {
    isMultiplayer = false;//return to main menu
    key = 0;
  }
  if (key == ESC && menu && !(isHost || isClient)) {
    //exitPrompt();      reserved to keep the game open in the main menu, make an exit prompt?
    key = 0;
  }
}

//Moved client and server to their own threads, drastically improves framerate.

public void server() {
  if (!UPnP.isMappedTCP(port) && multiplayer.getOpenPortAttempts()<3) {
    println("The port is closed, attempting to open again!");
    multiplayer.openAPort(port);
    multiplayer.setOpenPortAttempts(multiplayer.getOpenPortAttempts()+1);
  } else if (multiplayer.gameServer != null) {//needs to be nested in case game server is null, as the next if statement has reference to gameserver
    if (multiplayer.gameClient == null && multiplayer.getConnected()) {
      println("was the connection lost?");
      userInterface.returnToMultiplayerMenu();
      return;
    } else if (multiplayer.gameClient == null && !multiplayer.getConnected()) {//Nothing was sent
      multiplayer.gameClient = multiplayer.gameServer.available();
      println("Waiting for client");
    } else if (multiplayer.gameClient != null) {//found a client!
      if (!multiplayer.getConnected()) {
        multiplayer.setConnected(true);
        defenderTwo = new Defender(true);//create player two (client is player two)
      } else if (multiplayer.gameClient.available()>0) {//check there is a client connected and data is received
        multiplayer.parseReceivedClientData(); //server side parsing of client's data.
        //gameServer.write(generateServerData());
      } else {
        println("received nothing");
      }
    }
  } else if (multiplayer.gameServer == null) {
    if (multiplayer.getConnected()) {
      println("did the server crash?");
      userInterface.returnToMultiplayerMenu();
      return;
    }
    //set up the game as the server
    println("setup server");
    multiplayer.gameServer = new Server(parent, port);//ready to send data to client
    multiplayer.gameClient = null;
    multiplayer.openAPort(port);
  }
}

public void client() {
  if (multiplayer.gameClient != null) {
    if (!multiplayer.gameClient.active()) {//should see the server if this gameClient.active() is true
      println("Connection refused!");
      multiplayer.gameClient = null;
      userInterface.returnToMultiplayerMenu();
      userInterface.errorMessage("Connection Refused\nAsk your friend to Host a game!", true);
    } else {//if this runs, the client sees a server, send data.
      if (!multiplayer.getConnected() && multiplayer.gameClient.active()) {
        multiplayer.setConnected(true);
        defenderTwo = new Defender(true);//create player one (server is player one)
        thread("clientSender");//send the first piece of the pie! (send the first data, so the server see's a client is connected and active etc.)
        println("Connected to: " + serverIP + ":" + port);
      } else if (multiplayer.gameClient.available()>0) {//should only run when the client receives data.
        //parsReceivedServerData(gameClient.readString());//client side parsing of server's data
        multiplayer.gameClient.write(multiplayer.generateClientData());
      }
    }
  } else if ( multiplayer.gameClient == null) {
    println("setup client");
    multiplayer.gameClient = new Client(parent, serverIP, port);
    //Should throw an exception if the server refuses connection,
    //library catches exception instead of throwing it. 
    //rather annoying, so I have to check for the connection in the next loop cycle
  }
}
