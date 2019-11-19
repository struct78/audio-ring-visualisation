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
int startColour;
PFont font;
PShape logo;
SimpleDateFormat format;
String dateFormat;
String hourFormat;

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
  dist = 4;
  
  // Load assets
  font = loadFont("OpenSans-24.vlw");
  logo = loadShape("sbp.svg");
  
  // Date/time stuff
  format = new SimpleDateFormat( dateFormat );
  calendar = Calendar.getInstance();
  dateFormat = "yyyy-MM-dd@HH-mm-ss";
  hourFormat = "HH:mm";
  
  // Colours
  startColour = 0xff3e2e86;
  endColour = 0xff7f1d78;
  
  // Constraints
  shouldStop = false;
  startRadius = 0.4;
  stopRadius = ((height / 2) - 40);
  stopDeg = 0.0;
  
  // Frame rate
  frameRate(60);
}

void draw() {
  if (!shouldStop) {
    currentAmplitude = amplitude.analyze();
    points.add(currentAmplitude);
  }
  
  background(0);
  shape(logo, 80, 80, 266, 124);
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
      println("STOPPING");
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
  
  String hour = new SimpleDateFormat( hourFormat ).format(new Date());
  pushMatrix();
  translate(width-80, height-90);
  textAlign(RIGHT, BOTTOM);
  textLeading(40);
  text("21 July 2019\n14:00-" + hour, 0, 10);
  popMatrix();
}

void keyPressed() {
  String filename = format.format(new Date());
  saveData(filename);
  
  if (keyCode == ' ') {
    saveFrame(filename);
  }
  
  if (key == 'r') {
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
