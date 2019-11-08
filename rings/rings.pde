import processing.sound.*;

ArrayList<Float> points;
int time;
float currentAmplitude;
float amplitudeMultiplier;
Amplitude amplitude;
AudioIn audioIn;

void settings() {
  size(800, 800);
  smooth();
}

void setup() {
  time = millis();
  points = new ArrayList<Float>();
  amplitude = new Amplitude(this);
  audioIn = new AudioIn(this, 0);
  audioIn.start();
  amplitude.input(audioIn);
  amplitudeMultiplier = 20;
}

void draw() {
  currentAmplitude = amplitude.analyze();
  points.add(currentAmplitude);
  
  background(255);
  noFill();
  stroke(40);
  strokeWeight(0.1);
  translate(width/2, height/2);
  
  beginShape();
  float radius = 0.9;
  float dir = 1;
  for (int i = 0; i < points.size(); i++) {
    radius += .01;
    dir *= -1;
    float volume = points.get(i)*dir;
    float angle = radians(i);
    float cx = (radius+(volume * amplitudeMultiplier)) * cos(angle);  
    float cy = -(radius+(volume * amplitudeMultiplier)) * sin(angle);
    vertex(cx, cy);
  }
  endShape();
}
