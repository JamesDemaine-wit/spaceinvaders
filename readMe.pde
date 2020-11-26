/*
Name : James Demaine
 Student Number:  20093118  
 Course Name: Applied Computing General Y1 Group W1
 
 Brief description of the animation achieved: A modernised clone of Space Invaders
 
 Known bugs/problems: Multiplayer functionality is incomplete
 
 Any sources referred to during the development of the assignment (no need to reference lecture/lab materials):
 
 https://github.com/adolfintel/WaifUPnP
 https://www.skotechlearn.com/2019/11/change-main-class-in-java-netbeans.html
 https://processing.org/reference/environment/#Extensions
 https://forum.processing.org/one/topic/ignore-escape-key-do-other-action.html
 https://crunchify.com/java-runtime-get-free-used-and-total-memory-in-java/
 https://processing.org/reference
 
 Audio: https://freesound.org/
 Images: Bing search - creative commons/free to share use/public domain
 
 A restructured method from a fellow student, I was puzzled as to why this was giving the wrong result, so I explained what I needed: 
   Original:
     boolean areAliensAllDead() {
        boolean areAllDead = false;
       for (Alien a : aliens) {
         if(a.alienDeath){
            areAllDead = true;
          }
          else{
            areAllDead = false;
          }
        }
        return areAllDead;
      }
      
      Restructured:
      boolean areAliensAllDead() { // Source: Michael Gerber
        for (Alien a : aliens) {
                      //Michael Gerber:
                     //"The way I did it, it will cycle through the list and as soon as one is alive,
                    //it will return false and stop the whole for loop and ignore the rest of the list (Better optimized for large lists)"
        if (!a.alienDeathState) { 
            return false;
            }
          }  
          return true;
        }
 

NB!!:

 
 Uses a test version of the sound library, as the current version handles memory very poorly, causing distortion when many files are loaded.
 Please extract sound.zip and replace the 'sound' folder in your processing library folder.
 https://github.com/processing/processing-sound/releases/tag/v2.3.0-test
 
 OR
 
 run the exe to see the sketch run, and use the pde for the source code only.
 
 */
