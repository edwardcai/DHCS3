import java.util.ArrayList;
import java.util.Collections;

int index = 0;

//your input code should modify these!!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 0;

int trialCount = 20; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0;
int errorCount = 0;  
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;

final int screenPPI = 424; //what is the DPI of the screen you are using
//Many phones listed here: https://en.wikipedia.org/wiki/Comparison_of_high-definition_smartphone_displays 

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void setup() {
  //size does not let you use variables, so you have to manually compute this
  size(848, 1484); //set this, based on your sceen's PPI to be a 2x3.5" area.

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.15f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);
  
  screenZ = inchesToPixels(.15f);

  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    t.z = ((i%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0"
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}

void draw() {

  background(60); //background is dark grey
  rectMode(CORNER);

  if (startTime == 0)
    startTime = millis();

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);

    return;
  }

 if (checkForSuccess()) {
    fill(#00FF00);
    rect(0, 0, width, 80);
  }
  fill(200);
  noStroke();
  rectMode(CENTER);
  //===========DRAW TARGET SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen

  
  if (trialIndex >= trialCount) return; 
  Target t = targets.get(trialIndex);


  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen
 


  rotate(radians(t.rotation));
   
  fill(255, 0, 0); //set color to semi translucent
  rect(0, 0, t.z, t.z);
  fill(0);
  ellipse(0,0, 10,10); //center circle for targetting (gray) square
  
  if (!isMove) {
    stroke(255);
    if (checkForAngle()) stroke(#00ff00);
    line(-t.z*30, -t.z*30, t.z*30, t.z*30);
    line(-t.z*30, t.z*30, t.z*30, -t.z*30);
  }
  noStroke();
  if (!isMove) {
    rotate(-radians(t.rotation + 45));
    fill(10,10,10,130);
    triangle(0,0, 1800,200,1800,-200);
    triangle(0,0, -1800,200, -1800,-200);
    triangle(0,0, 200,1800,-200,1800);
    triangle(0,0, 200,-1800, -200,-1800);
  }
  noStroke();

  popMatrix();

  //===========DRAW TARGETTING SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  rotate(radians(screenRotation));

  //custom shifts:
  //translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen

  fill(255, 128); //set color to semi translucent
  rect(0, 0, screenZ, screenZ);
  fill(0);
  noFill();
  stroke(0);
  strokeWeight(2);
  if(checkForDist()) fill(0,255,0);
  ellipse(0,0, inchesToPixels(.1),inchesToPixels(.1));
  noStroke();

  popMatrix();

  scaffoldControlLogic(); //you are going to want to replace this!

  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

void scaffoldControlLogic()
{
  /*
  //upper left corner, rotate counterclockwise
  text("CCW", inchesToPixels(.2f), inchesToPixels(.2f));
  if (mousePressed && dist(0, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenRotation--;

  //upper right corner, rotate clockwise
  text("CW", width-inchesToPixels(.2f), inchesToPixels(.2f));
  if (mousePressed && dist(width, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenRotation++;
  */
}

float calculateAngle(int x1, int y1, int x2, int y2) {
  float dy = y2-y1;
  float dx = x2-x1+1;
  println("dy: " + dy + " dx: " + dx + " deg: " + degrees(atan(dy/dx)));
  return degrees(atan(dy/dx)); 
}

float calculateDist(int x1, int y1, int x2, int y2) {
  float dy = y2-y1;
  float dx = x2-x1+1;
  return (sqrt(sq(dy) + sq(dx))); 
}

float initRotation;
float startingRotation;
float initZ;
float startingZ;
float initX;
float startingX;
float initY;
float startingY;

boolean isMove = true;
float startPress;

void mousePressed()
{ if (trialIndex < trialCount) {
  startPress = millis();
  Target t = targets.get(trialIndex);
  initRotation = t.rotation;
  startingRotation = calculateAngle(width/2,height/2, mouseX, mouseY); 
  initZ = t.z;
  startingZ = calculateDist(width/2,height/2, mouseX, mouseY);
  initX = t.x;
  initY = t.y;
  startingX = mouseX;
  startingY = mouseY;
  }
  

}

void mouseDragged() {
  if (trialIndex <trialCount) {
  Target t = targets.get(trialIndex);
  if (!isMove) {
    float dRotation = calculateAngle(width/2,height/2, mouseX, mouseY) - startingRotation;
    t.rotation = initRotation + dRotation; 
    float dZ = initZ - initZ * (calculateDist(width/2,height/2, mouseX, mouseY)/ startingZ);
    t.z = constrain(initZ - (dZ*3), inchesToPixels(.15f), inchesToPixels(3f));
  } else {
    float dX = mouseX - startingX;
    float dY = mouseY - startingY;
    t.x = initX +dX;
    t.y = initY +dY;
  }
  }
}

void mouseReleased()
{  
  if (millis() - startPress < 100) {
     if (trialIndex==trialCount && userDone==true)
      {
        trialIndex = -1;
        userDone = false;
        finishTime = millis();
        startTime = 0;
      }

      isMove = !isMove; 
      if (checkForSuccess()) {
        trialIndex++;
        isMove = true; 
      }
      
        screenTransX = 0;
  screenTransY = 0;

  if (trialIndex==trialCount && userDone==false)
  {
    userDone = true;
    finishTime = millis();
  }
  }

  
  println(millis() - startPress);
  
  //check to see if user clicked middle of screen
  
}


public boolean checkForDist() {
    Target t = targets.get(trialIndex);
    return  dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f);
}

public boolean checkForSuccess()
{
	Target t = targets.get(trialIndex);	
	boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
    boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
	boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"	);
	
	return closeDist && closeRotation && closeZ;	
}

public boolean checkForAngle() {
    Target t = targets.get(trialIndex);
  return calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
}


double calculateDifferenceBetweenAngles(float a1, float a2)
  {
     double diff=abs(a1-a2);
      diff%=90;
      if (diff>45)
        return 90-diff;
      else
        return diff;
 }