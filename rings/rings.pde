import processing.sound.*;
import processing.pdf.*;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

Amplitude amplitude;
ArrayList<Float> points;
AudioIn audioIn;
boolean shouldStop;
Calendar calendar;
float amplitudeMultiplier;
float compression;
float currentAmplitude;
float dist;
float startRadius;
float stopDeg;
float stopRadius;
int endColour;
int FPS;
int startColour;
PFont font;
PShape logo;
SimpleDateFormat format;
String dateFormat;
String endTime;
String hourFormat;
String startTime;

void settings() {
  fullScreen(P3D);
  smooth(8);
}

void setup() {
  // Audio in
  amplitude = new Amplitude(this);
  audioIn = new AudioIn(this, 0);
  audioIn.start();
  amplitude.input(audioIn);
  amplitudeMultiplier = 20;
  
  // Spiral properties
  points = new ArrayList<Float>();
  compression = 100;
  dist = 5;
  
  // Load assets
  font = loadFont("OpenSans-24.vlw");
  logo = loadShape("sbb.svg");
  
  // Date/time stuff
  calendar = Calendar.getInstance();
  dateFormat = "yyyy-MM-dd@HH-mm-ss";
  hourFormat = "HH:mm";
  format = new SimpleDateFormat( dateFormat );
  startTime = "14:00";
  
  // Colours
  startColour = 0xff3e2e86;
  endColour = 0xff7f1d78;
  
  // Constraints
  shouldStop = false;
  startRadius = 0.1;
  stopRadius = ((height / 2) - 120);
  stopDeg = 0.0;
  
  // Frame rate
  FPS = 13;
  frameRate(FPS);
  calculateRunningTime();
}

void calculateRunningTime() {
  boolean isRunning = true;
  float radius = startRadius;
  float alpha = 0;
  int frames = 0;
  
  while (isRunning) {
    float k = width/radius/compression;
    alpha += radians(k);
    radius += dist/(360/k);
    
    float angleDeg = degrees(alpha);
    float actualDeg = angleDeg % 360;
    frames++;
    if (radius >= stopRadius && parseFloat(nf(actualDeg, 0, 1)) == stopDeg) {
      isRunning = false;
    }
  }
  
  println(frames + " frames");
  println(frames/FPS + " seconds");
  println(frames/FPS/60 + " minutes");
  println(frames/FPS/60/60 + " hours");
  println("Resolution: " + width + " x " + height);
  println("Radius: " + radius);
  println("Diameter: " + radius*2);
}

void draw() {
  if (!shouldStop) {
    currentAmplitude = amplitude.analyze();
    points.add(currentAmplitude);
    endTime = new SimpleDateFormat( hourFormat ).format(new Date());
  }
  
  background(0);
  shape(logo, 80, 88, 483, 52);
  noFill();
  strokeWeight(2);
  
  pushMatrix();
  translate(width/2, height/2);
  rotate(radians(-90));
  beginShape();
  
  float dir = 1;
  float radius = startRadius;
  float alpha = 0;
  
  for (int i = 0; i < points.size(); i+=1) {
    dir *= -1;
    float volume = (points.get(i) * amplitudeMultiplier) * dir;
    float k = width/radius/compression;
    
    alpha += radians(k);
    radius += dist/(360/k);
    
    float angleDeg = degrees(alpha);
    float actualDeg = angleDeg % 360;
    float cx = (radius+volume) * cos(alpha);  
    float cy = -(radius+volume) * sin(alpha);
    
    if (actualDeg >= 0 && actualDeg <= 180) {
      stroke(lerpColor(startColour, endColour, map(actualDeg, 0, 180, 0, 1)));
    } else {
      stroke(lerpColor(endColour, startColour, map(actualDeg, 180, 360, 0, 1)));
    }
    
    vertex(cx, cy);
    
    if (radius >= stopRadius && parseFloat(nf(actualDeg, 0, 1)) == stopDeg) {
      shouldStop = true;
    }
  }
  
  endShape();
  popMatrix();
  
  fill(255);
  pushMatrix();
  textFont(font, 24);
  textAlign(LEFT, BOTTOM);
  translate(80, height-90);
  textLeading(40);
  text("Abbotsford Convent\n VIC, Australia", 0, 0);
  popMatrix();
  
  pushMatrix();
  translate(width-80, height-90);
  textAlign(RIGHT, BOTTOM);
  textLeading(40);
  text("21 November 2019\n" + startTime + "-" + endTime, 0, 10);
  popMatrix();
}

void keyPressed() {
  String filename = format.format(new Date());
  
  if (keyCode == ' ') {
    saveData(filename);
    saveFrame(filename);
  }
  
  if (key == 'r') {
    saveData(filename);
    saveFrame(filename);
    points = new ArrayList<Float>();
  }
}

void saveData(String filename) {
  PrintWriter writer = createWriter(filename + ".csv");
  for ( float point : points ) {
    writer.println(point);
  }
  writer.flush();
  writer.close();
}
