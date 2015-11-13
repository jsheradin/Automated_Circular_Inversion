//Graph settings
float radius = 90; //Radius of the circle that will be used to map (pixles)
int winSize = 600; //Window size in pixels (window is square) (pixels)
float J = 0.03; //This is a constant that is used to scale the mapped bubbles. There are no units and it needs to be found experimentally.

//Image settings
int imgSizeX = 60; //Bottom Right X coordinate in pixels
int imgSizeY = 60; //Bottom Right Y coordinate in pixles
int imgOffX = -10; //Shift right in pixels
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
float win = winSize / 2; //A lot of calculations use this, so there is no point in calculating it each time
float x; //Used for scanning
float y; //Used for scanning
PImage img; //Decalre an image

void setup() {
  size(winSize, winSize, P2D); //Set window size
  background(255); //Set background to white
  smooth(8); //Anti-Aliasing
  noLoop();
  
  //Place the image to be inverted
  img = loadImage("face.jpg"); //Load file
  image(img, win - imgSizeX + imgOffX, win - imgSizeY - imgOffY, imgSizeX, imgSizeY); //Place it
  
  //Scan all pixels in the image and pass the values on to the graph function
  x =  win - imgSizeX + imgOffX;
  y =  win - imgSizeY - imgOffY;
  
  while (y <=  win - imgOffY) { //Scan Y from top to bottom
    while (x <= win + imgOffX) { //Scan X from left to right
      project(x - win, y - win); //Pass 0'd values to the function
      x++; //Move right
    }
    y++; //Move down
    x = win - imgSizeX + imgOffX; //Set X back to far left
  }
  
  //Draw graph elements
  stroke(0);
  fill(255);
  ellipse(win, win, radius * 2, radius * 2); //Circle that points were inverted about
  image(img, win - imgSizeX + imgOffX, win - imgSizeY - imgOffY, imgSizeX, imgSizeY); //Image again (circle is on top of old one)
  fill(0); //Fill center point black
  line(20, win, winSize - 20, win); //X axis line
  line(win, 20, win, winSize - 20); //Y axis line
  
  draw();
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
  ellipse(newX + win, newY + win, distance * J, distance * J); //Draw the cirle
  /*
  The radius is proportional to distance as the circles will be more spread out as distance increases.
  This helps to fill in the gaps between the circles.
  */
}
