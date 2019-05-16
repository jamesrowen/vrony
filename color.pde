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

int bgGray = 45;

void colorAndDrawCells(MPolygon[] cells) {
  color c;
  for (int ring = 0; ring < int(param("numRings")); ring++) {
    for (int spoke = 0; spoke < int(param("ringSpokes")); spoke++) {
      c = getSpokeColor(ring, spoke);
      fill(lerpColor(color(bgGray), c, param("brightness")));
      stroke(lerpColor(color(param("borderBlack")), c, param("borderBrightness")));
      cells[ring * int(param("ringSpokes")) + spoke].draw(this);
    }
  }
  
  // color the big wheel(s) white
  if (setting("mode") == 1) {
    for (int wheel = 0; wheel < numWheels; wheel++) {
      for (int spoke = 0; spoke < int(param("wheelSpokes")); spoke++) {
        int i = int(param("numRings")) * int(param("ringSpokes")) + wheel * int(param("wheelSpokes")) + spoke;
        fill(215);
        stroke(200);
        cells[i].draw(this);
      }
    }
  }
}

color getSpokeColor(int ring, int spoke) {
  
  if (setting("colorMode") == 0) {
    // cycle through colors cell by cell
    int i = ring * int(param("ringSpokes")) + spoke;
    return palettes[setting("palette")][i % (setting("numColors") + 1)];
  }
  
  else if (setting("colorMode") == 1) {
    // cycle through colors by ring, alternate between black and colored rings
    if (ring % 2 == 0) {
      // not casting this to a color creates lerpColor opacity weirdness (looks cool)
      return bgGray;
    }
    return palettes[setting("palette")][(ring / 2) % (setting("numColors") + 1)];
  }
  
  else if (setting("colorMode") == 2) {
  // cycle through colors by ring, alternate between black and colored cells
    if (spoke % 2 == 0) {
      return bgGray;
    }
    return palettes[setting("palette")][ring % (setting("numColors") + 1)];
  }
  return color(0);
}
