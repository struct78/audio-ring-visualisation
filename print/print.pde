import processing.pdf.*;

ArrayList<Float> points;
boolean shouldStop;
float amplitudeMultiplier;
float compression;
float currentAmplitude;
float dist;
float startRadius;
float stopDeg;
float stopRadius;
int endColour;
int startColour;
Table table;

void settings() {
  size(800, 1200, PDF, "print.pdf");
  smooth(8);
}

void setup() {
  points = new ArrayList<Float>();
  table = loadTable("data.csv", "header");
  amplitudeMultiplier = 20;
  dist = 5;
  compression = 100;
  
  for (TableRow row : table.rows()) {
    points.add(row.getFloat("Amplitude"));
  }
  
  // Colours
  startColour = 0xff222222;
  endColour = 0xff222222;
  
  // Constraints
  startRadius = 0.1;
  stopRadius = ((height / 2) - 120);
  stopDeg = 0.0;
}

void draw() {
  background(255);
  noFill();
  strokeWeight(0.025);
  
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
  }
  
  endShape();
  popMatrix();
  exit();
}
