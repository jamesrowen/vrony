ArrayList<UIComponent> uiComponents = new ArrayList<UIComponent>();

int uiXOff = 8;
int uiDarkGray = 210;
int uiLightGray = 240;
int uiDarkBorder = 120;
int uiLightBorder = 140;
int uiTextBlack = 0;
color uiLightBlue = color(117, 218, 255);
color uiPanelBG = color(200, 250);
color uiKeyframe = color(200, 0, 0);

void setupUI() {
  textSize(12);
  int x0 = 145;
  int y0 = 12;
  int spacing = 25;
  int bSpacing = 105;
  int by = 15 + spacing * 17;
  uiComponents.add(new Slider("speed", x0, y0));
  uiComponents.add(new Slider("pointOpacity", x0, y0 + spacing * 1));
  uiComponents.add(new Slider("brightness", x0, y0 + spacing * 2));
  uiComponents.add(new Slider("borderBrightness", x0, y0 + spacing * 3));
  uiComponents.add(new Slider("borderBlack", x0, y0 + spacing * 4));
  uiComponents.add(new Slider("numRings", x0, y0 + spacing * 5));
  uiComponents.add(new Slider("ringSpokes", x0, y0 + spacing * 6));
  uiComponents.add(new Slider("ringSize", x0, y0 + spacing * 7));
  uiComponents.add(new Slider("ringTwist", x0, y0 + spacing * 8));
  uiComponents.add(new Slider("wheelSpokes", x0, y0 + spacing * 9));
  uiComponents.add(new Slider("wheelSize", x0, y0 + spacing * 10));
  uiComponents.add(new Slider("wheelSpeed", x0, y0 + spacing * 11));
  uiComponents.add(new Slider("lissajousX", x0, y0 + spacing * 12));
  uiComponents.add(new Slider("lissajousY", x0, y0 + spacing * 13));
  uiComponents.add(new Slider("perturbAmount", x0, y0 + spacing * 14));
  uiComponents.add(new Slider("perturbSpeed", x0, y0 + spacing * 15));
  uiComponents.add(new Slider("perturbWrap", x0, y0 + spacing * 16));
  uiComponents.add(new Button("play", uiXOff, by));
  uiComponents.add(new Button("mode", uiXOff + bSpacing, by));
  uiComponents.add(new Button("alternate", uiXOff + bSpacing * 2, by));
  uiComponents.add(new Button("colorMode", uiXOff, by + 25));
  uiComponents.add(new Button("palette", uiXOff + bSpacing, by + 25));
  uiComponents.add(new Button("numColors", uiXOff + bSpacing * 2, by + 25));
  // sequencer
  int seqY = 560;
  uiComponents.add(new Timeline("timeline", uiXOff, seqY));
  uiComponents.add(new Button("sequencer", uiXOff, seqY + 4));
}

void drawUI() {
  if (showUI) {
    stroke(uiDarkBorder);
    fill(uiPanelBG);
    rect(4, 4, 320, 485, 2);
    
    for (UIComponent c : uiComponents) {
      c.draw();
    }
    
    // debugging output
    fill(uiTextBlack);
    textAlign(LEFT, BOTTOM);
    //text("keyCode: " + keyCode, uiXOff, height - 10);
  }
}


// ***********
// Event hooks
// ***********
void mousePressed() {
  for (UIComponent c : uiComponents) {
    c.testClick();
  }
}

void mouseDragged() {
  for (UIComponent c : uiComponents) {
    c.doDrag();
  }
}

void mouseReleased() {
  for (UIComponent c : uiComponents) {
    c.doRelease();
  }
}


// *****************
// Base UI Component
// *****************
class UIComponent {
  String name;
  int xPos, yPos;
  
  UIComponent(String n, int x, int y) {
    name = n;
    xPos = x;
    yPos = y;
  }
  
  void testClick() {}
  void doDrag() {}
  void doRelease() {}
  void draw() {}
}


// ******
// Slider
// ******
class Slider extends UIComponent {
  boolean active = false;
  int boxPos = 0;
  int boxXOff = 7;
  int boxSize = 12;
  int sliderWidth = 150;
  int dragStartX = 0;
  int boxStartX = 0;
  
  Slider(String n, int x, int y) {
    super(n, x, y);
    Setting s = getSetting(name);
    boxPos = int((s.value - s.minVal) / (s.maxVal - s.minVal) * sliderWidth);
  }
  
  void testClick() {
    int x = xPos + boxPos + boxXOff;
    if (mouseX >= x && mouseX <= x + boxSize && mouseY >= yPos && mouseY <= yPos + boxSize) {
      active = true;
      dragStartX = mouseX;
      boxStartX = boxPos;
    }
  }
  
  void doDrag() {
    if (active) {
      boxPos = min(max(boxStartX + mouseX - dragStartX, 0), sliderWidth);
      Setting s = getSetting(name);
      s.value = lerp(s.minVal, s.maxVal, boxPos / float(sliderWidth));
    }
  }
  
  void doRelease() {
    active = false;
  }
  
  void draw() {
    Setting s = getSetting(name);
    // update position if changed elsewhere (keyboard, automation)
    boxPos = int((s.value - s.minVal) / (s.maxVal - s.minVal) * sliderWidth);
    
    // draw text
    fill(uiTextBlack);
    textAlign(RIGHT, TOP);
    text(name + "  " + nf(s.value, 0, 1), xPos, yPos);
    textAlign(LEFT, BOTTOM);
    
    // draw track
    fill(uiDarkGray);
    stroke(uiLightBorder);
    rect(xPos + 5, yPos + boxSize - 3, sliderWidth + boxSize + 4, 5, 2);
    
    // draw slider
    fill(uiLightGray);
    stroke(uiDarkBorder);
    if (active) {
      fill(uiLightBlue);
      stroke(80, 80, 160);
    }
    rect(xPos + boxPos + boxXOff, yPos - 1, boxSize, boxSize, 2);
  }
}


// ******
// Button
// ******
class Button extends UIComponent {
  int w = 100;
  int h = 19;
  
  Button(String n, int x, int y) {
    super(n, x, y);
  }
  
  void testClick() {
    if (mouseX >= xPos && mouseX <= xPos + w && mouseY >= yPos && mouseY <= yPos + h) {
      Setting s = getSetting(name);
      s.value = (int)(s.value + 1) % (int)(s.maxVal + 1);
    }
  }
  
  void draw() {
    Setting s = getSetting(name);
    fill(uiLightGray);
    if (s.type == 2 && s.value == 1) {
      fill(uiLightBlue);
    }
    stroke(uiDarkBorder);
    rect(xPos, yPos, w, h, 2);
    fill(uiTextBlack);
    textAlign(CENTER, TOP);
    text(name + (s.type == 2 ? "" : ": " + (int)s.value), xPos + w / 2, yPos + 2);
  }
}


// ********
// Timeline
// ********
class Timeline extends UIComponent {
  int trackSpacing = 22;
  int trackOffset = 100;
  int trackWidth = 600;
  int trackPadding = 2;
  
  Timeline(String n, int x, int y) {
    super(n, x, y);
  }
  
  void draw() {
    int numParams = sequenceParams.entrySet().size();
    int trackStart = xPos + trackOffset;
    int panelWidth = trackOffset + trackWidth + 8;
    
    // panel background
    stroke(uiDarkBorder);
    fill(uiPanelBG);
    rect(xPos - 4, yPos, panelWidth, 60 + numParams * trackSpacing, 2);
    
    // position marker
    fill(uiLightGray);
    noStroke();
    int markerX = int(param("sequencePosition") / param("sequenceLength") * (trackWidth - 2));
    rect(trackStart + markerX, yPos + 28, 2, 30 + numParams * trackSpacing, 2);
    
    // parameter tracks
    int i = 0;
    textAlign(LEFT, TOP);
    for (Map.Entry<String, ArrayList<Keyframe>> seqParam : sequenceParams.entrySet()) {
      // name text
      fill(uiTextBlack);
      int yStart = yPos + 40 + i * trackSpacing;
      text(seqParam.getKey(), xPos, yStart + 3);
      
      // border lines
      stroke(uiLightBorder);
      line(xPos - 4, yStart, panelWidth + 4, yStart);
      
      // keyframes
      fill(uiKeyframe);
      int prevX = 0, prevY = 0;
      int j = 0;
      for (Keyframe k : seqParam.getValue()) {
        int xOff = int(k.time / param("sequenceLength") * trackWidth);
        int yPct = int(k.value / getSetting(seqParam.getKey()).maxVal);
        int yOff = yPct * (trackSpacing - trackPadding * 2) + trackPadding;
        noStroke();
        circle(trackStart + xOff, yStart + yOff, 5);
        stroke(uiKeyframe);
        if (j > 0) {
          line(trackStart + xOff, yStart + yOff, trackStart + prevX, yStart + prevY);
        }
        prevX = xOff;
        prevY = yOff;
        j++;
      }
      i++;
    }
  }
}
