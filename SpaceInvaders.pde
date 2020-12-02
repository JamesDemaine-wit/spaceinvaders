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

Multiplayer multiplayer;
int buyCounter, score, numberOfAliens, port;
String serverIP, externalIP;
boolean debug, isMultiplayer, menu, isHost, isClient;//some are used by both UI and Multiplayer classes, made them global
Defender defender, defenderTwo;
ArrayList<Alien> aliens;
Runtime instance;
UserInterface userInterface;
Audio sounds;
PApplet parent;
Images images;
float alienWidth, alienHeight;

//Data is mostly initialised in setup to use it for resetting the sketch
void setup() {
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

void draw() {
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
  }
}

void buyLivesWithScore() {
  if (score>=500*buyCounter && defender.getLives()<defender.getMaxLives()) {
    score-=500*buyCounter;
    defender.setLives(defender.getLives()+1);
    buyCounter++;
  }
}

void bonusScore() {
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

void resetToMenu() {
  sounds.gameMusic.stop();
  menu = true;
  if (sounds.getPlayDeathSound()) {
    sounds.deathSound.play();
  }
  setup();
  instance.gc();
  delay(500);
}

boolean areAliensAllDead() { // Source: Michael Gerber - see readme)
  for (Alien a : aliens) {
    //"The way I did it, it will cycle through the list and as soon as one is alive,
    //it will return false and stop the whole for loop and ignore the rest of the list (Better optimized for large lists)"
    if (!a.getAlienDeathState()) { 
      return false;
    }
  }  
  return true;
}

void mousePressed() {
  if (mouseButton == LEFT && focused && !menu) {
    if (!defender.getBullet().getFire()) {
      defender.getBullet().setFire(true);
    }
  }
  if (focused) {
    loop();
  }
}

void mouseClicked() {
  if (mouseButton == RIGHT && !menu) {
    buyLivesWithScore();
  }
}

void keyReleased() {
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

void keyPressed() {
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
