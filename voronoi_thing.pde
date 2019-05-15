import megamu.mesh.*;

// user settings
boolean showUI = true;

// gear mode
float gearScale = 5;
int numWheels = 1;

//colors
color[][] palettes = {
  {
    color(20, 171, 189),
    color(255, 170, 0),
    color(255, 56, 0),
    color(49, 139, 163),
    color(255, 96, 0)
  }, {
    color(2, 166, 118),
    color(0, 140, 114),
    color(0, 115, 105),
    color(0, 90, 91),
    color(0, 56, 64)
  }, {
    color(0),
    color(25),
    color(50),
    color(75),
    color(100)
  }
};

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

void generatePoints() {
  // ***************
  // concentric mode
  // ***************
  if ((int)getSetting("mode") == 0) {
    numPoints = int(getSetting("numRings")) * int(getSetting("ringSpokes"));
    points = new float[numPoints][2];
    
    for (int ring = 0; ring < int(getSetting("numRings")); ring++) {
      for (int i = ring * int(getSetting("ringSpokes")); i < (ring + 1) * int(getSetting("ringSpokes")); i++) {
        float rotation = 2 * PI * i / getSetting("ringSpokes");
        points[i][0] = sin(rotation + animProgress * ((int)getSetting("alternate") > 0 ? pow(-1, ring) : 1));
        points[i][0] *= getSetting("ringSize") * (ring + .5);
        points[i][0] += width / 2;
        float perturbRot = getSetting("perturbWrap") * ring / getSetting("numRings") + animProgress * getSetting("perturbSpeed");
        points[i][0] += getSetting("perturbAmount") * sin(perturbRot);
        
        rotation = 2 * PI * i / getSetting("ringSpokes");
        points[i][1] = cos(rotation + animProgress * ((int)getSetting("alternate") > 0 ? pow(-1, ring) : 1));
        points[i][1] *= getSetting("ringSize") * (ring + .5);
        perturbRot = getSetting("perturbWrap") * ring / getSetting("numRings") + animProgress * getSetting("perturbSpeed");
        points[i][1] += height / 2 + getSetting("perturbAmount") * cos(perturbRot);
      }
    }
  }
  
  // ***********************
  // gears/kaleidoscope mode
  // ***********************
  else if ((int)getSetting("mode") == 1) {
    numPoints = int(getSetting("numRings")) * int(getSetting("ringSpokes")) + numWheels * int(getSetting("wheelSpokes"));
    points = new float[numPoints][2];
    
    for (int gear = 0; gear < int(getSetting("numRings")); gear++) {
      for (int spoke = 0; spoke < int(getSetting("ringSpokes")); spoke++) {
        int i = gear * int(getSetting("ringSpokes")) + spoke;
        
        float rotation = 2 * PI * spoke / getSetting("ringSpokes");
        rotation += gear * getSetting("ringTwist");
        rotation += animProgress * ((int)getSetting("alternate") > 0 ? pow(-1, gear) : 1);
        points[i][0] = sin(rotation);
        points[i][0] *= getSetting("ringSize") * gearScale;
        points[i][0] += width / 2 + sin(2 * PI * gear / getSetting("numRings")) * getSetting("wheelSize");
        
        rotation = 2 * PI * spoke / getSetting("ringSpokes");
        rotation += gear * getSetting("ringTwist");
        rotation += animProgress * ((int)getSetting("alternate") > 0 ? pow(-1, gear) : 1);
        points[i][1] = cos(rotation);
        points[i][1] *= getSetting("ringSize") * gearScale;
        points[i][1] += height / 2 + cos(2 * PI * gear / getSetting("numRings")) * getSetting("wheelSize");
      }
    }
    
    for (int wheel = 0; wheel < numWheels; wheel++) {
      for (int spoke = 0; spoke < int(getSetting("wheelSpokes")); spoke++) {
        int i = int(getSetting("numRings")) * int(getSetting("ringSpokes")) + wheel * int(getSetting("wheelSpokes")) + spoke;
        
        float rotation = 2 * PI * spoke / getSetting("wheelSpokes");
        rotation += animProgress * getSetting("wheelSpeed") * ((int)getSetting("alternate") > 0 ? pow(-1, wheel) : 1);
        points[i][0] = sin(getSetting("lissajousX") * rotation);
        points[i][0] *= getSetting("wheelSize") / (wheel + 1);
        points[i][0] += width / 2;
        
        rotation = 2 * PI * spoke / getSetting("wheelSpokes");
        rotation += animProgress * getSetting("wheelSpeed") * ((int)getSetting("alternate") > 0 ? pow(-1, wheel) : 1);
        points[i][1] = cos(getSetting("lissajousY") * rotation);
        points[i][1] *= getSetting("wheelSize") / (wheel + 1);
        points[i][1] += height / 2;
      }
    }
  }
}

void draw() {
  float tick = (millis() - lastMillis) / 1000.0 * getSetting("speed");
  if ((int)getSetting("sequencer") == 1) {
    if ((int)getSetting("sequencePlay") == 1) {
      tickSequence(tick);
    }
  }
  if ((int)getSetting("play") == 1) {
    animProgress += tick;
  }
  lastMillis = millis();
  
  generatePoints();
  
  Voronoi voronoi = new Voronoi(points);
  MPolygon[] polygons = voronoi.getRegions();

  // color the rings
  color temp;
  for (int ring = 0; ring < int(getSetting("numRings")); ring++) {
    for (int spoke = 0; spoke < int(getSetting("ringSpokes")); spoke++) {
      int i = ring * int(getSetting("ringSpokes")) + spoke;
      
      // cycle through colors cell by cell
      if ((int)getSetting("colorMode") == 0) {
        fill(lerpColor(palettes[(int)getSetting("palette")][i % ((int)getSetting("numColors") + 1)], color(255), .2));
        temp = palettes[(int)getSetting("palette")][i % ((int)getSetting("numColors") + 1)];
        stroke(red(temp), green(temp), blue(temp), 255 * getSetting("borderOpacity"));
      }
      
      // cycle through colors ring by ring.
      // alternate between black and colored rings, or by cell (colorMode 2)
      else if ((int)getSetting("colorMode") == 1 || (int)getSetting("colorMode") == 2) {
        fill(lerpColor(palettes[(int)getSetting("palette")][(ring / 2) % ((int)getSetting("numColors") + 1)], color(0), .15));
        temp = lerpColor(palettes[(int)getSetting("palette")][(ring / 2) % ((int)getSetting("numColors") + 1)], color(0), .25);
        stroke(red(temp), green(temp), blue(temp), 255 * getSetting("borderOpacity"));
        if ((int)getSetting("colorMode") == 1 && ring % 2 == 0 || (int)getSetting("colorMode") == 2 && spoke % 2 == 0) {
          fill(44);
          stroke(30, int(255 * getSetting("borderOpacity")));
        }
      }
      polygons[i].draw(this);
    }
  }
    
  // color the big wheel(s) white
  if ((int)getSetting("mode") == 1) {
    for (int wheel = 0; wheel < numWheels; wheel++) {
      for (int spoke = 0; spoke < int(getSetting("wheelSpokes")); spoke++) {
        int i = int(getSetting("numRings")) * int(getSetting("ringSpokes")) + wheel * int(getSetting("wheelSpokes")) + spoke;
        fill(215);
        stroke(200);
        polygons[i].draw(this);
      }
    }
  }
  
  // draw generator points
  for (int i = 0; i < numPoints; i++) {
    stroke(235, 255 * getSetting("pointOpacity"));
    point(points[i][0], points[i][1]);
    stroke(180, 255 * getSetting("pointOpacity") * .9);
    point(points[i][0] + 1, points[i][1] + 1);
    point(points[i][0] - 1, points[i][1] + 1);
    point(points[i][0] + 1, points[i][1] - 1);
    point(points[i][0] - 1, points[i][1] - 1);
  }
  
  drawUI();
  
}
