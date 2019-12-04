/*
This project was created by Anish Ghai from Parramatta High School in 2018.

Don't Go There is a story based platformer about a block and an external force telling it to not go certain places. But naturally 
because of curiousity...you will got there :) 

This game generates levels by having two images, a collision image and a detail image. 
The collision image is made up of pure #000000 pixels. The code scans for these pixels and adds a collision system there. The detail image, is place on top of the collision
image to make the map looks pretty, and provide a user friendly experience.

This project is already converted to processing.js for you. Just click the index.html file to start running it. It is tested on Safari (MacOS). 

Since sound libraries are not supported in processing.js, this uses a special file called minim.js open sourced code provided by Daniel Hodgin (https://github.com/Pomax/Pjs-2D-Game-Engine/blob/master/minim.js)
This enables sound to work by emulating minim. Thanks David!

Hope the judges have fun playing the game. It consists of 10 levels.

Enjoy!

*/


import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

// This uses the Processing Minim library for Audio.
// Music borrowed from OpenGameArt, a site which offers free music and other game art for developers.
PImage collisionImage;
PImage displayImage;
PImage loseImage;
float playerX;
float playerY;
float playerVelocityY = 0;
float playerVelocityX = 0;
float playerSpeed = 3;
float playerJumpSpeed = -5;
float playerSize = 10;
float upKey;
float rightKey;
float downKey;
float leftKey;
float restart;
boolean onGround;
float gravity = .3;
int timer;
PFont f;
int lastTime = 0;
int startTime = millis();
boolean win;
int playerXWin;
int playerYWin;
int newTimer;
int actualTime;
int currentTime;
int delayNextLevel = 1;
int levelNumber = 1;
int currentLevel = 1;
Minim minim;
AudioPlayer bgMusic;
void setup()
{
  minim = new Minim(this);
  bgMusic = minim.loadFile("bgMusic.mp3", 2048);
  Win();
  size(500, 500);
  LevelOne();
  loseImage = requestImage("Game_Over.png");
  f = createFont("Impact", 16, true); // STEP 2 Create Font
  bgMusic.loop();
  //frameRate(60);
  
}

void draw()
{
  Win();
  fill(236, 0, 71);
  playerVelocityY += gravity;
  playerVelocityX = (rightKey - leftKey) * playerSpeed;
  float nextY = playerY + playerVelocityY;
  float nextX = playerX + playerVelocityX;
  boolean tempOnGround = false;
  if (collisionImage.width > 0)
  {
    image(collisionImage, 0, 0, width, height);
    if (displayImage.width > 0)
    {
      image(displayImage, 0, 0, width, height);
    }
    collisionImage.loadPixels();
    for (int y = 0; y < collisionImage.height; y += 1) 
    {
      for (int x = 0; x < collisionImage.width; x += 1)
      { 
        color pixelColor = collisionImage.pixels[y*collisionImage.width+x];
        float scaleDiff = width / collisionImage.width; // 500 / 50 = 10
        int xx = (int)(nextX / scaleDiff);
        int yy = (int)(playerY / scaleDiff);
        int platformX = x * (int)scaleDiff;
        int platformY = y * (int)scaleDiff;
        if (xx == x &&  yy == y && red(pixelColor) == 0)
        {
          // moving left and character is currently on the right side of the wall
          if (playerVelocityX < 0 && playerX >= platformX)
          {
            playerVelocityX = 0;
          }
          // moving right and character is currently on the left side of the wall
          if (playerVelocityX > 0 && playerX < platformX)
          {
            playerVelocityX = 0;
          }
        }

        xx = (int)(playerX / scaleDiff);
        yy = (int)(nextY / scaleDiff);
        if (xx == x &&  yy == y && red(pixelColor) == 0)
        {
          fill(255, 0, 255);

          // moving up and character is currently on the bottom side of the wall
          // commented out to jump up through platforms
          /*if (playerVelocityY < 0  && playerY >= platformY)
           {
           playerVelocityY = 0;
           }*/
          // moving down and character is currently on the top side of the wall
          if (playerVelocityY > 0 && playerY < platformY)
          {
            playerVelocityY = 0;
            tempOnGround = true;
          }
        }
      }
    }
    
    if (playerX > 500) {
       playerX =499; 
    } else if (playerX < 0) {
     playerX =1; 
    }
    if (playerY > 500) {
       playerY =499; 
    }  else if (playerY < 0) {
       playerY=1; 
    }
    timer = 45000;
    currentTime = (millis() - startTime)/1000;
    actualTime = (timer/1000) - currentTime;
    if (actualTime <= 0 && (win == false)) {
      Lose();
      actualTime = 0;
    } else if ((actualTime < 0) && (win == true)) {
      win = true;
    } else if (win) {
      nextLevel();
    }
  } else {
    textFont(f, 10); 
    text(actualTime, 10, 100);
    //textSize(4);
  }



  if ((key == 'R') || (key == 'r')) {
    LevelOne();
    startTime = millis();
  }                
  textFont(f, 60); 
  text(actualTime, 10, 100);

  playerX += playerVelocityX;
  playerY += playerVelocityY;
  rectMode(CENTER);
  rect(playerX, playerY, playerSize, playerSize);
  onGround = tempOnGround;
}


void keyReleased()
{
  if (key == CODED)
  {
    if (keyCode == LEFT)
    {
      leftKey = 0;
    }
    if (keyCode == RIGHT)
    {
      rightKey = 0;
    }
    if (keyCode == UP)
    {
      upKey = 0;
    }
    if (keyCode == DOWN)
    {
      downKey = 0;
    }
  }
}

void keyPressed()
{
  if ((key == 'R') || (key == 'r')) {
    LevelOne();
  }
  if (key == ' ')
  {
    if (onGround == true)
    {
      playerVelocityY = playerJumpSpeed;
    }
  }


  if (key == CODED)
  {
    if (keyCode == LEFT)
    {
      leftKey = 1;
    }
    if (keyCode == RIGHT)
    {
      rightKey = 1;
    }
    if (keyCode == UP)
    {
      upKey = 1;
    }
    if (keyCode == DOWN)
    {
      downKey = 1;
    }
  }
}


//void Restart() {
//  playerSpeed = 3;
//  playerJumpSpeed = -5;
//  displayImage = requestImage("levelDetail.png");
//  collisionImage = requestImage("level.png");
//  playerY = 475;
//  playerX = 475;
//  win = false;
//  playerSize = 10;
//}

void Lose() {
  playerSpeed = 0;
  playerJumpSpeed = 0; 
  image(loseImage, 0, 0);
  playerSize = 0;
  actualTime = 0;
}

void LevelOne() {
  startTime = millis();
  collisionImage = loadImage("level.png");
  displayImage = loadImage("levelDetail.png");
  playerX = 465;
  playerY = 390;
  playerXWin = 425;
  playerYWin = 45;
  playerSize = 10;
  playerSpeed = 3;
  playerJumpSpeed = -5;
  win = false;
  timer = 45000;
  currentLevel = 1;
}



void Win() {
  if (currentLevel == 1) {
    if ((playerX >= playerXWin) && (playerY <= playerYWin)) {
      nextLevel();
      win = true;
    }
  } else if (currentLevel >= 2) {
    if ((playerX >= playerXWin) && (playerY >= playerYWin)) {
      win = true;
      nextLevel();
    }
  }
}



void Level2() {
  collisionImage = loadImage("Level2.png");
  displayImage = loadImage("Level2Detail.png");
  startTime = millis();
  playerX = 20;
  playerY = 480;
  playerXWin = 400;
  playerYWin = 480;
  playerSize = 10;
  playerSpeed = 3;
  playerJumpSpeed = -5;
  win = false;
  timer = 40000;
  currentLevel = 2;
}

void Level3() {
  collisionImage = loadImage("Level3.png");
  displayImage = loadImage("Level3Detail.png");
  startTime = millis();
  playerX = 10;
  playerY = 460;
  playerXWin = 350;
  playerYWin = 480;
  playerSize = 10;
  playerSpeed = 3;
  playerJumpSpeed = -5;
  win = false;
  timer = 40000;
  currentLevel = 3;
}

void Level4() {
  collisionImage = loadImage("Level4.png");
  displayImage = loadImage("Level4Detail.png");
  startTime = millis();
  playerX = 35;
  playerY = 50;
  playerXWin = 380;
  playerYWin = 480;
  playerSize = 10;
  playerSpeed = 3;
  playerJumpSpeed = -5;
  win = false;
  timer = 40000;
  currentLevel = 4;
}
void Level5() {
  collisionImage = loadImage("Level5.png");
  displayImage = loadImage("Level5Detail.png");
  startTime = millis();
  playerX = 300;
  playerY = 400;
  playerXWin = 460;
  playerYWin = 480;
  playerSize = 10;
  playerSpeed = 3;
  playerJumpSpeed = -5;
  win = false;
  timer = 40000;
  currentLevel = 5;
}

void Level6() {
  collisionImage = loadImage("Level6.png");
  displayImage = loadImage("Level6Detail.png");
  startTime = millis();
  playerX = 140;
  playerY = 300;
  //delay(3000);
  playerXWin = 460;
  playerYWin = 480;
  playerSize = 10;
  playerSpeed = 3;
  playerJumpSpeed = -5;
  win = false;
  timer = 40000;
  currentLevel = 6;
}

void Level7() {
  collisionImage = loadImage("Level7.png");
  displayImage = loadImage("Level7Detail.png");
  startTime = millis();
  playerX = 20;
  playerY = 50;
  playerXWin = 40;
  playerYWin = 480;
  playerSize = 10;
  playerSpeed = 3;
  playerJumpSpeed = -5;
  win = false;
  timer = 40000;
  currentLevel = 7;
}

void Level8() {
  collisionImage = loadImage("Level8.png");
  displayImage = loadImage("Level8Detail.png");
  startTime = millis();
  playerX = 50;
  playerY = 20;
  playerXWin = 480;
  playerYWin = 480;
  playerSize = 10;
  playerSpeed = 3;
  playerJumpSpeed = -5;
  win = false;
  timer = 40000;
  currentLevel = 8;
}

void Level9() {
  collisionImage = loadImage("Level9.png");
  displayImage = loadImage("Level9Detail.png");
  startTime = millis();
  playerX = 50;
  playerY = 10;
  playerXWin = 480;
  playerYWin = 480;
  playerSize = 10;
  playerSpeed = 3;
  playerJumpSpeed = -5;
  win = false;
  timer = 40000;
  currentLevel = 9;
}

void Level10() {
  collisionImage = loadImage("Level10.png");
  displayImage = loadImage("Level10Detail.png");
  startTime = millis();
  playerX = 50;
  playerY = 10;
  playerXWin = 480;
  playerYWin = 480;
  playerSize = 10;
  playerSpeed = 3;
  playerJumpSpeed = -5;
  win = false;
  timer = 40000;
  currentLevel = 10;
}
void nextLevel() {
  if (currentLevel == 1) {
    Level2();
  } else if (currentLevel == 2) { 
    Level3();
  } else if (currentLevel == 3) {
    Level4();
  } else if (currentLevel == 4) {
    Level5();
  } else if (currentLevel == 5) {
    Level6();
  } else if (currentLevel == 6) {
    Level7();
  } else if (currentLevel == 7) {
    Level8();
  } else if (currentLevel == 8) {
    Level9();
  } else if (currentLevel == 9) {
     Level10();
  } else {
     LevelOne(); 
  }
}