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
  size(1000, 800);
  setupSettings();
  setupUI();
}

void generatePoints() {
  // ***************
  // concentric mode
  // ***************
  if (si.get("mode") == 0) {
    numPoints = int(s.get("numRings")) * int(s.get("ringSpokes"));
    points = new float[numPoints][2];
    
    for (int ring = 0; ring < int(s.get("numRings")); ring++) {
      for (int i = ring * int(s.get("ringSpokes")); i < (ring + 1) * int(s.get("ringSpokes")); i++) {
        float rotation = 2 * PI * i / s.get("ringSpokes");
        points[i][0] = sin(rotation + animProgress * (si.get("alternate") > 0 ? pow(-1, ring) : 1));
        points[i][0] *= s.get("ringSize") * (ring + .5);
        points[i][0] += width / 2;
        float perturbRot = s.get("perturbWrap") * ring / s.get("numRings") + animProgress * s.get("perturbSpeed");
        points[i][0] += s.get("perturbAmount") * sin(perturbRot);
        
        rotation = 2 * PI * i / s.get("ringSpokes");
        points[i][1] = cos(rotation + animProgress * (si.get("alternate") > 0 ? pow(-1, ring) : 1));
        points[i][1] *= s.get("ringSize") * (ring + .5);
        perturbRot = s.get("perturbWrap") * ring / s.get("numRings") + animProgress * s.get("perturbSpeed");
        points[i][1] += height / 2 + s.get("perturbAmount") * cos(perturbRot);
      }
    }
  }
  
  // ***********************
  // gears/kaleidoscope mode
  // ***********************
  else if (si.get("mode") == 1) {
    numPoints = int(s.get("numRings")) * int(s.get("ringSpokes")) + numWheels * int(s.get("wheelSpokes"));
    points = new float[numPoints][2];
    
    for (int gear = 0; gear < int(s.get("numRings")); gear++) {
      for (int spoke = 0; spoke < int(s.get("ringSpokes")); spoke++) {
        int i = gear * int(s.get("ringSpokes")) + spoke;
        
        float rotation = 2 * PI * spoke / s.get("ringSpokes");
        rotation += gear * s.get("ringTwist");
        rotation += animProgress * (si.get("alternate") > 0 ? pow(-1, gear) : 1);
        points[i][0] = sin(rotation);
        points[i][0] *= s.get("ringSize") * gearScale;
        points[i][0] += width / 2 + sin(2 * PI * gear / s.get("numRings")) * s.get("wheelSize");
        
        rotation = 2 * PI * spoke / s.get("ringSpokes");
        rotation += gear * s.get("ringTwist");
        rotation += animProgress * (si.get("alternate") > 0 ? pow(-1, gear) : 1);
        points[i][1] = cos(rotation);
        points[i][1] *= s.get("ringSize") * gearScale;
        points[i][1] += height / 2 + cos(2 * PI * gear / s.get("numRings")) * s.get("wheelSize");
      }
    }
    
    for (int wheel = 0; wheel < numWheels; wheel++) {
      for (int spoke = 0; spoke < int(s.get("wheelSpokes")); spoke++) {
        int i = int(s.get("numRings")) * int(s.get("ringSpokes")) + wheel * int(s.get("wheelSpokes")) + spoke;
        
        float rotation = 2 * PI * spoke / s.get("wheelSpokes");
        rotation += animProgress * s.get("wheelSpeed") * (si.get("alternate") > 0 ? pow(-1, wheel) : 1);
        points[i][0] = sin(s.get("lissajousX") * rotation);
        points[i][0] *= s.get("wheelSize") / (wheel + 1);
        points[i][0] += width / 2;
        
        rotation = 2 * PI * spoke / s.get("wheelSpokes");
        rotation += animProgress * s.get("wheelSpeed") * (si.get("alternate") > 0 ? pow(-1, wheel) : 1);
        points[i][1] = cos(s.get("lissajousY") * rotation);
        points[i][1] *= s.get("wheelSize") / (wheel + 1);
        points[i][1] += height / 2;
      }
    }
  }
}

void draw() {
  if (si.get("play") == 1) {
    animProgress += (millis() - lastMillis) / 1000.0 * s.get("speed");
  }
  lastMillis = millis();
  
  generatePoints();
  
  Voronoi voronoi = new Voronoi(points);
  MPolygon[] polygons = voronoi.getRegions();

  // color the rings
  color temp;
  for (int ring = 0; ring < int(s.get("numRings")); ring++) {
    for (int spoke = 0; spoke < int(s.get("ringSpokes")); spoke++) {
      int i = ring * int(s.get("ringSpokes")) + spoke;
      
      // cycle through colors cell by cell
      if (si.get("colorMode") == 0) {
        fill(lerpColor(palettes[si.get("palette")][i % (si.get("numColors") + 1)], color(255), .2));
        temp = palettes[si.get("palette")][i % (si.get("numColors") + 1)];
        stroke(red(temp), green(temp), blue(temp), 255 * s.get("borderOpacity"));
      }
      
      // cycle through colors ring by ring.
      // alternate between black and colored rings, or by cell (colorMode 2)
      else if (si.get("colorMode") == 1 || si.get("colorMode") == 2) {
        fill(lerpColor(palettes[si.get("palette")][(ring / 2) % (si.get("numColors") + 1)], color(0), .15));
        temp = lerpColor(palettes[si.get("palette")][(ring / 2) % (si.get("numColors") + 1)], color(0), .25);
        stroke(red(temp), green(temp), blue(temp), 255 * s.get("borderOpacity"));
        if (si.get("colorMode") == 1 && ring % 2 == 0 || si.get("colorMode") == 2 && spoke % 2 == 0) {
          fill(44);
          stroke(30, int(255 * s.get("borderOpacity")));
        }
      }
      polygons[i].draw(this);
    }
  }
    
  // color the big wheel(s) white
  if (si.get("mode") == 1) {
    for (int wheel = 0; wheel < numWheels; wheel++) {
      for (int spoke = 0; spoke < int(s.get("wheelSpokes")); spoke++) {
        int i = int(s.get("numRings")) * int(s.get("ringSpokes")) + wheel * int(s.get("wheelSpokes")) + spoke;
        fill(215);
        stroke(200);
        polygons[i].draw(this);
      }
    }
  }
  
  // draw generator points
  for (int i = 0; i < numPoints; i++) {
    stroke(235, 255 * s.get("pointOpacity"));
    point(points[i][0], points[i][1]);
    stroke(180, 255 * s.get("pointOpacity") * .9);
    point(points[i][0] + 1, points[i][1] + 1);
    point(points[i][0] - 1, points[i][1] + 1);
    point(points[i][0] + 1, points[i][1] - 1);
    point(points[i][0] - 1, points[i][1] - 1);
  }
  
  drawUI();
  
}
