import processing.video.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import ddf.minim.*;

Minim minim;
AudioPlayer player;

PImage[] images = new PImage[6];
EmotionImage[] emotionImages = new EmotionImage[6];

boolean showAnimation = false;
float animationSize = 50;
boolean growing = true;

ArrayList<Star> stars = new ArrayList<Star>(); 
ArrayList<Dot> dots = new ArrayList<Dot>(); 

PrintWriter output; 

String[] emojiNames = { "happy", "sad", "neutral", "angry", "thumbsup", "thumbsdown" };

void setup() {
  size(1200, 800);

  // Load images
  images[0] = loadImage("happy.png");
  images[1] = loadImage("sad.png");
  images[2] = loadImage("neutral.png");
  images[3] = loadImage("angry.png");
  images[4] = loadImage("thumbsup.png");
  images[5] = loadImage("thumbsdown.png"); 
  
  minim = new Minim(this);
  player = minim.loadFile("miracle.mp3");
  player.play(); 

  // Initialize EmotionImage objects
  emotionImages[0] = new EmotionImage(images[0], 50, 50, 150, 150);     // happy
  emotionImages[1] = new EmotionImage(images[1], 1000, 50, 140, 140);   // sad
  emotionImages[2] = new EmotionImage(images[2], 50, 600, 140, 140);    // neutral
  emotionImages[3] = new EmotionImage(images[3], 1000, 600, 140, 140);  // angry
  emotionImages[4] = new EmotionImage(images[4], 50, 300, 150, 150);    // thumbsup
  emotionImages[5] = new EmotionImage(images[5], 1000, 350, 150, 150);  // thumbsdown

  // Create a new file in the sketch directory
  output = createWriter("positions.txt"); 

}

int selectedEmoji = -1; // Track clicked emoji 

// Button positions and sizes
float btnW = 75;
float btnH = 30;
float btnY = 700; 


color getRandomLightColor() {
  return color(random(150, 255), random(150, 255), random(150, 255)); // Light tones
}

color getRandomDarkColor() {
  return color(random(0, 120), random(0, 120), random(0, 120)); // Dark tones
} 

void draw() {
  drawGradient();


  // Timeline bar
  float progress = map(player.position(), 0, player.length(), 0, width - 40);
  fill(50);
  rect(20, height - 50, width - 40, 20, 10); // Rounded background bar
  fill(0, 200, 0);
  rect(20, height - 50, progress, 20, 10); // Progress bar

  // Buttons
  drawButton(450, 700, "Play");
  drawButton(530, 700, "Pause");
  drawButton(610, 700, "Stop");
  drawButton(690, 700, "Restart");

  
// Song info
  fill(255);
  textAlign(CENTER);
  textSize(30);
  String fileName = player.getMetaData().fileName();
  String title = player.getMetaData().title();
  String author = player.getMetaData().author(); 
  text(author + " " + title, width/2, height - 700 );


  // Center rectangle
  fill(50);
  stroke (255);
  strokeWeight (2);
  rect(260, 180, 675, 425); 
  
// Draw star rain if thumbs up selected
if (selectedEmoji == 4 && showAnimation) {
  // Add new stars randomly
  if (frameCount % 5 == 0) {
    float sx = random(280, 260 + 660); // inside rectangle width
    stars.add(new Star(sx, 200)); // start at top of rectangle
  }

  // Update and display stars
  for (int i = stars.size() - 1; i >= 0; i--) {
    Star s = stars.get(i);
    s.update();
    s.display();
    if (s.isOutOfBounds()) {
      stars.remove(i);
    }
  }
}

if (selectedEmoji == 5 && showAnimation) {
  if (frameCount % 5 == 0) {
    float dx = random(280, 260 + 660); // inside rectangle width
    dots.add(new Dot(dx, 200)); // start at top of rectangle
  }

  for (int i = dots.size() - 1; i >= 0; i--) {
    Dot d = dots.get(i);
    d.update();
    d.display();
    if (d.isOutOfBounds()) {
      dots.remove(i);
    }
  }
}


  // Display emojis
  for (EmotionImage ei : emotionImages) {
    ei.display();
  }

  
// Animation in center rectangle
  if (showAnimation && selectedEmoji != -1) {
    float centerX = width / 2;
    float centerY = height / 2; 
    pushStyle(); // Save current styles 
    color shapeColor;
    stroke(255, 100, 100);
    strokeWeight(3); 
    
    
// Assign color based on side
  if (selectedEmoji == 0 || selectedEmoji == 2) { // happy, neutral (left)
    shapeColor = getRandomLightColor();
  } else if (selectedEmoji == 1 || selectedEmoji == 3) { // sad, angry (right)
    shapeColor = getRandomDarkColor();
  } else {
    shapeColor = color(255, 100, 100); // fallback
  }

    stroke(shapeColor);
    strokeWeight(3); 
    
  switch (selectedEmoji) {
    case 0: drawStar(centerX, centerY, animationSize/2, animationSize, 5); break;
    case 1: ellipse(centerX, centerY, animationSize, animationSize); break;
    case 2: drawTriangle(centerX, centerY, animationSize); break;
    case 3:
      rectMode(CENTER);
      rect(centerX, centerY, animationSize, animationSize);
      rectMode(CORNER);
      break;
  }
 
switch (selectedEmoji) {
  case 0: // happy → star
    drawStar(centerX, centerY, animationSize/2, animationSize, 5);
    break;
  case 1: // sad → circle
    ellipse(centerX, centerY, animationSize, animationSize);
    break;
  case 2: // neutral → triangle
    drawTriangle(centerX, centerY, animationSize);
    break;
  case 3: // angry → rectangle
    rectMode(CENTER);
    rect(centerX, centerY, animationSize, animationSize);
    rectMode(CORNER); // ✅ Reset mode after drawing
    break;
}
popStyle(); // Restore previous styles 
}

    // Animate size
    if (growing) {
      animationSize += 2;
      if (animationSize > 200) growing = false;
    } else {
      animationSize -= 2;
      if (animationSize < 50) growing = true;
    }
  }

void drawButton(float x, float y, String label) {
  fill(80);
  stroke(255);
  rect(x, y, btnW, btnH, 8);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(18);
  text(label, x + btnW/2, y + btnH/2);
}

void mouseClicked() { 
  //EmoJi clicks
  for (int i = 0; i < emotionImages.length; i++) {
    if (emotionImages[i].isClicked(mouseX, mouseY)) {
      println("Clicked on emoji: " + i);
      showAnimation = true;
      animationSize = 50;
      growing = true;
      selectedEmoji = i; // Store which emoji was clicked 
      
      // ✅ Log emoji name, current time, and total duration
      float currentTime = player.position() / 1000.0; // in seconds
      float totalDuration = player.length() / 1000.0; // in seconds
      output.println("Emoji: " + emojiNames[i] +
                     " | Time: " + nf(currentTime, 0, 2) + "s" +
                     " / " + nf(totalDuration, 0, 2) + "s");
      output.flush(); // write immediately
    }
  }
  
  // Button clicks
  if (mouseX > 450 && mouseX < 525 && mouseY > btnY && mouseY < btnY + btnH) {
    player.play();
  } else if (mouseX > 530 && mouseX < 605 && mouseY > btnY && mouseY < btnY + btnH) {
    player.pause();
  } else if (mouseX > 610 && mouseX < 685 && mouseY > btnY && mouseY < btnY + btnH) {
    player.pause();
    player.rewind();
  } else if (mouseX > 690 && mouseX < 765 && mouseY > btnY && mouseY < btnY + btnH) {
    player.rewind();
    player.play();
  }
}

// Helper to draw star
void drawStar(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle / 2.0;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a + halfAngle) * radius1;
    sy = y + sin(a + halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

// Helper to draw triangle
void drawTriangle(float x, float y, float size) {
  float half = size / 2;
  triangle(x, y - half, x - half, y + half, x + half, y + half);
}


class EmotionImage {
  PImage img;
  float x, y, w, h;

  EmotionImage(PImage img, float x, float y, float w, float h) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void display() {
    image(img, x, y, w, h);
  }

  boolean isClicked(float mx, float my) {
    return mx > x && mx < x + w && my > y && my < y + h;
  }
}

class Star {
  float x, y, size, speed;
  color col;

  Star(float x, float y) {
    this.x = x;
    this.y = y;
    this.size = random(5, 15);
    this.speed = random(2, 5);
    this.col = color(random(200, 255), random(200, 255), random(150, 255));
  }

  void update() {
    y += speed;
  } 
  
  void display() {
    stroke(col);
    strokeWeight(2);
    drawStar(x, y, size/2, size, 5);
  }

  boolean isOutOfBounds() {
    return y > 170 + 410; // bottom of rectangle
  }
}


class Dot {
  float x, y, size, speed;
  color col;

  Dot(float x, float y) {
    this.x = x;
    this.y = y;
    this.size = random(8, 20);
    this.speed = random(2, 5);
// ✅ Darker tones: RGB values between 0 and 120
    this.col = color(random(0, 120), random(0, 120), random(0, 120));
  }

  void update() {
    y += speed;
  }

  void display() {
    noStroke();
    fill(col);
    ellipse(x, y, size, size);
  }

  boolean isOutOfBounds() {

return y > 580; // bottom of rectangle
  }
} 

void drawGradient() {
  for (int i = 0; i < height; i++) {
    float inter = map(i, 0, height, 0, 1);
    color c = lerpColor(color(20, 20, 60), color(0, 0, 0), inter);
    stroke(c);
    line(0, i, width, i);
  }
}

void exit() {
  output.close();
  super.exit();
}
