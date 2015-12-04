//Graph settings
float radius = 90; //Radius of the circle that will be used to map (pixles)
int winSize = 1000; //Window size in pixels (window is square) (pixels)
float K = 0.00002; //Used to scale mapped pixel bubbles
float scanRes = 0.145; //Increments used when scanning the image (MASSIVE impact on performance)

//Image settings
int imgSizeX = 60; //Bottom Right X coordinate in pixels
int imgSizeY = 60; //Bottom Right Y coordinate in pixles
int imgOffX = 78; //Shift right in pixels
int imgOffY = -30; //Shif up in pixels

//For storing original values
float origX = 0;
float origY = 0;

//For storing new values
float newX = 0;
float newY = 0;

//Misc other varables
float distance; //Length of line from origin to P prime
float theta; //Angle of the line from
int win = round(winSize / 2); //A lot of calculations use this, so there is no point in calculating it each time
PImage img; //Decalre an image

void setup() {
  size(winSize, winSize, P2D); //Set window size
  print("Initializing... ");
  background(255); //Set background to white
  smooth(8); //Anti-Aliasing
  noLoop();
  println("Done");
  
  //Place the image to be inverted
  print("Loading Image... ");
  img = loadImage("face.jpg"); //Load file
  image(img, win - imgSizeX + imgOffX, win - imgSizeY - imgOffY, imgSizeX, imgSizeY); //Place it
  println("Done");
  
  //Scan all pixels in the image and pass the values on to the graph function
  int timeStart = millis();
  print("Mapping Image... ");
  for(float y = win - imgSizeY - imgOffY; y <=  win - imgOffY; y += scanRes) { //Scan Y from top to bottom
    for(float x = win - imgSizeX + imgOffX; x <= win + imgOffX; x += scanRes) { //Scan X from left to right
      project(x - win, y - win); //Pass 0'd values to the function
    }
  }
  println("Done in " + round((millis() - timeStart) / 1000) + " seconds");
  
  //Draw graph elements
  print("Printing... ");
  stroke(0);
  fill(255);
  ellipse(win, win, radius * 2, radius * 2); //Circle that points were inverted about
  image(img, win - imgSizeX + imgOffX, win - imgSizeY - imgOffY, imgSizeX, imgSizeY); //Image again (circle is on top of old one)
  fill(0); //Fill center point black
  line(20, win, winSize - 20, win); //X axis line
  line(win, 20, win, winSize - 20); //Y axis line
}

void draw() {
  println("Done");
  print("Saving...");
  save("Example.png");
  println("Done");
}

//Take a point and make a corresponding point through circular inversion
void project(float origX, float origY) {
  distance = sq(radius) / sqrt(sq(origX) + sq(origY)); //Distance point is from origin
  theta = atan(origY / origX); //Angle of the line (Thanks C!)
  
  //The actual circle inversion math
  //The way the math is implemented will always return a positive X value even if it should be negative
  //This hack fixes that issue
  if (origX >= 0) { //If X should be positive
    newX = (distance * cos(theta));
    newY = (distance * sin(theta));
  } else { //If X should be negative
    newX = (distance * -cos(theta));
    newY = (distance * -sin(theta));
  }
  
  //Draw a circle with the same color as the pixel in question at the corresoponding location
  color c = get(round(origX + win), round(origY + win)); //Get color of pixel
  stroke(c); //Set stroke to that color
  fill(c); //Set fill to that color
  if(distance < win) {
    ellipse(newX + win, newY + win, pow(distance, 2) * K, pow(distance, 2) * K); //Draw the cirle
  }
  /*
  The radius is proportional to distance as the circles will be more spread out as distance increases.
  This helps to fill in the gaps between the circles.
  */
}
