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
  if (setting("mode") == 0) {
    numPoints = int(param("numRings")) * int(param("ringSpokes"));
    points = new float[numPoints][2];
    
    for (int ring = 0; ring < int(param("numRings")); ring++) {
      int dir = int(setting("alternate") > 0 ? pow(-1, ring) : 1);
      
      for (int i = ring * int(param("ringSpokes")); i < (ring + 1) * int(param("ringSpokes")); i++) {
        float rotation = 2 * PI * i / param("ringSpokes");
        points[i][0] = sin(rotation + animProgress * dir);
        points[i][0] *= param("ringSize") * (ring + .5);
        points[i][0] += width / 2;
        float perturbRot = param("perturbWrap") * ring / param("numRings") + animProgress * param("perturbSpeed");
        points[i][0] += param("perturbAmount") * sin(perturbRot);
        
        rotation = 2 * PI * i / param("ringSpokes");
        points[i][1] = cos(rotation + animProgress * dir);
        points[i][1] *= param("ringSize") * (ring + .5);
        perturbRot = param("perturbWrap") * ring / param("numRings") + animProgress * param("perturbSpeed");
        points[i][1] += height / 2 + param("perturbAmount") * cos(perturbRot);
      }
    }
  }
  
  // ***********************
  // gears/kaleidoscope mode
  // ***********************
  else if (setting("mode") == 1) {
    numPoints = int(param("numRings")) * int(param("ringSpokes")) + numWheels * int(param("wheelSpokes"));
    points = new float[numPoints][2];
    
    for (int gear = 0; gear < int(param("numRings")); gear++) {
      int dir = int(setting("alternate") > 0 ? pow(-1, gear) : 1);
      
      for (int spoke = 0; spoke < int(param("ringSpokes")); spoke++) {
        int i = gear * int(param("ringSpokes")) + spoke;
        
        float rotation = 2 * PI * spoke / param("ringSpokes");
        rotation += gear * param("ringTwist");
        rotation += animProgress * dir;
        points[i][0] = sin(rotation);
        points[i][0] *= param("ringSize") * gearScale;
        points[i][0] += width / 2 + sin(2 * PI * gear / param("numRings")) * param("wheelSize");
        
        rotation = 2 * PI * spoke / param("ringSpokes");
        rotation += gear * param("ringTwist");
        rotation += animProgress * dir;
        points[i][1] = cos(rotation);
        points[i][1] *= param("ringSize") * gearScale;
        points[i][1] += height / 2 + cos(2 * PI * gear / param("numRings")) * param("wheelSize");
      }
    }
    
    for (int wheel = 0; wheel < numWheels; wheel++) {
      int dir = int(setting("alternate") > 0 ? pow(-1, wheel) : 1);
      
      for (int spoke = 0; spoke < int(param("wheelSpokes")); spoke++) {
        int i = int(param("numRings")) * int(param("ringSpokes")) + wheel * int(param("wheelSpokes")) + spoke;
        
        float rotation = 2 * PI * spoke / param("wheelSpokes");
        rotation += animProgress * param("wheelSpeed") * dir;
        points[i][0] = sin(param("lissajousX") * rotation);
        points[i][0] *= param("wheelSize") / (wheel + 1);
        points[i][0] += width / 2;
        
        rotation = 2 * PI * spoke / param("wheelSpokes");
        rotation += animProgress * param("wheelSpeed") * dir;
        points[i][1] = cos(param("lissajousY") * rotation);
        points[i][1] *= param("wheelSize") / (wheel + 1);
        points[i][1] += height / 2;
      }
    }
  }
}

void draw() {
  float tick = (millis() - lastMillis) / 1000.0;
  if (setting("play") == 1) {
    if (setting("sequencer") == 1) {
      tickSequence(tick);
    }
    animProgress += tick * param("speed");
  }
  lastMillis = millis();
  
  generatePoints();
  
  Voronoi voronoi = new Voronoi(points);
  MPolygon[] polygons = voronoi.getRegions();

  // color the rings
  color temp;
  for (int ring = 0; ring < int(param("numRings")); ring++) {
    for (int spoke = 0; spoke < int(param("ringSpokes")); spoke++) {
      int i = ring * int(param("ringSpokes")) + spoke;
      
      // cycle through colors cell by cell
      if (setting("colorMode") == 0) {
        fill(lerpColor(palettes[setting("palette")][i % (setting("numColors") + 1)], color(255), .2));
        temp = palettes[setting("palette")][i % (setting("numColors") + 1)];
        stroke(red(temp), green(temp), blue(temp), 255 * param("borderOpacity"));
      }
      
      // cycle through colors by ring, alternate between black and colored rings
      else if (setting("colorMode") == 1) {
        color c = palettes[setting("palette")][(ring / 2) % (setting("numColors") + 1)];
        fill(lerpColor(c, color(0), 0));
        temp = lerpColor(c, color(0), .25);
        stroke(red(temp), green(temp), blue(temp), 255 * param("borderOpacity"));
        if (ring % 2 == 0) {
          fill(44);
          stroke(30, int(255 * param("borderOpacity")));
        }
      }
      
      // cycle through colors by ring, alternate between black and colored cells
      else if (setting("colorMode") == 2) {
        color c = palettes[setting("palette")][ring % (setting("numColors") + 1)];
        fill(lerpColor(c, color(0), 0));
        temp = lerpColor(c, color(0), .25);
        stroke(red(temp), green(temp), blue(temp), 255 * param("borderOpacity"));
        if (spoke % 2 == 0) {
          fill(44);
          stroke(30, int(255 * param("borderOpacity")));
        }
      }
      
      polygons[i].draw(this);
    }
  }
    
  // color the big wheel(s) white
  if (setting("mode") == 1) {
    for (int wheel = 0; wheel < numWheels; wheel++) {
      for (int spoke = 0; spoke < int(param("wheelSpokes")); spoke++) {
        int i = int(param("numRings")) * int(param("ringSpokes")) + wheel * int(param("wheelSpokes")) + spoke;
        fill(215);
        stroke(200);
        polygons[i].draw(this);
      }
    }
  }
  
  // draw generator points
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
