void generatePoints() {
  
  // concentric mode
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
  
  // gears/kaleidoscope mode
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
