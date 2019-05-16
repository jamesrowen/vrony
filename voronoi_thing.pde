import megamu.mesh.*;

// user settings
boolean showUI = true;

// gear mode
float gearScale = 5;
int numWheels = 1;

//program vars
int numPoints = 0;
float[][] points = new float[numPoints][2];
int lastMillis = 0;
float animProgress = 0;
  
void setup() {
  size(1200, 800);
  setupSettings();
  setupSequencer();
  setupUI();
}

void draw() {
  if (setting("play") == 1) {
    float tick = (millis() - lastMillis) / 1000.0;
    if (setting("sequencer") == 1) {
      tickSequence(tick);
    }
    animProgress += tick * param("speed");
  }
  lastMillis = millis();
  
  generatePoints();
  Voronoi voronoi = new Voronoi(points);
  MPolygon[] cells = voronoi.getRegions();
  colorAndDrawCells(cells);
  
  // draw points
  for (int i = 0; i < numPoints; i++) {
    stroke(235, 255 * param("pointOpacity"));
    point(points[i][0], points[i][1]);
    stroke(180, 255 * param("pointOpacity") * .9);
    point(points[i][0] + 1, points[i][1] + 1);
    point(points[i][0] - 1, points[i][1] + 1);
    point(points[i][0] + 1, points[i][1] - 1);
    point(points[i][0] - 1, points[i][1] - 1);
  }
  
  drawUI();
}
