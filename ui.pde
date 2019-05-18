ArrayList<UIComponent> uiComponents = new ArrayList<UIComponent>();

int uiPadding = 5;
int uiDarkGray = 210;
int uiLightGray = 240;
int uiDarkBorder = 120;
int uiLightBorder = 135;
int uiTextBlack = 0;
color uiLightBlue = color(117, 218, 255);
color uiPanelBG = color(220, 250);
color uiKeyframe = color(255, 0, 0);

void setupUI() {
  textSize(12);
  
  // sliders
  int sliderX = 141 + uiPadding;
  int sliderYStart = uiPadding * 2 + 2;
  int sliderSpacing = 25;
  String[] sliders = {"speed", "pointOpacity", "brightness", "borderBrightness",
    "borderBlack", "numRings", "ringSpokes", "ringSize", "ringTwist", "wheelSpokes",
    "wheelSize", "wheelSpeed", "lissajousX", "lissajousY", "perturbAmount", 
    "perturbSpeed", "perturbWrap"};
  for (int i = 0; i < sliders.length; i++) {
    uiComponents.add(
      new Slider(sliders[i], sliderX, sliderYStart + sliderSpacing * i)
    );
  }
  
  // buttons
  int bX = uiPadding * 2;
  int bY = 14 + sliderSpacing * sliders.length;
  int bXSpacing = 101 + uiPadding;
  int bYSpacing = 21 + uiPadding;
  uiComponents.add(new Button("play", bX, bY));
  uiComponents.add(new Button("mode", bX + bXSpacing, bY));
  uiComponents.add(new Button("alternate", bX + bXSpacing * 2, bY));
  uiComponents.add(new Button("colorMode", bX, bY + bYSpacing));
  uiComponents.add(new Button("palette", bX + bXSpacing, bY + bYSpacing));
  uiComponents.add(new Button("numColors", bX + bXSpacing * 2, bY + bYSpacing));
  
  // sequencer timeline
  int timelineY = 560;
  uiComponents.add(new Timeline("timeline", uiPadding, timelineY));
  uiComponents.add(new Button("sequencer", bX, timelineY + uiPadding));
  uiComponents.add(new Input("sequenceLength", bX + 202, timelineY + uiPadding));
}

void drawUI() {
  if (showUI) {
    // main control panel
    stroke(uiDarkBorder);
    fill(uiPanelBG);
    rect(uiPadding, uiPadding, 313 + uiPadding * 2, 486, 2);
    
    for (UIComponent c : uiComponents) {
      c.draw();
    }
    
    // debugging output
    //fill(uiTextBlack);
    //textAlign(LEFT, BOTTOM);
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


// ************************
// Base UI Component
// ************************
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


// ************************
// Slider
// ************************
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
    if (mouseX >= x && mouseX <= x + boxSize
      && mouseY >= yPos && mouseY <= yPos + boxSize) {
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


// ************************
// Button
// ************************
class Button extends UIComponent {
  int w = 100;
  int h = 20;
  
  Button(String n, int x, int y) {
    super(n, x, y);
  }
  
  void testClick() {
    if (mouseX >= xPos && mouseX <= xPos + w
      && mouseY >= yPos && mouseY <= yPos + h) {
      getSetting(name).advance();
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
    text(name + (s.type == 2 ? "" : ": " + (int)s.value), xPos + w / 2, yPos + 3);
  }
}

// ************************
// Input
// ************************
class Input extends UIComponent {
  boolean active = false;
  int w = 50;
  int h = 20;
  Input(String n, int x, int y) {
    super(n, x, y);
  }
  
  void draw() {
    Setting s = getSetting(name);
    
    // box
    fill(uiLightGray);
    if (active) {
      fill(uiLightBlue);
    }
    stroke(uiDarkBorder);
    rect(xPos + 2, yPos, w, h, 2);
    
    // text
    fill(uiTextBlack);
    textAlign(RIGHT, TOP);
    text(name, xPos, yPos + 3);
    textAlign(LEFT, TOP);
    text((int)s.value, xPos + 10, yPos + 3);
  }
  
  void testClick() {
    if (mouseX >= xPos && mouseX <= xPos + w
      && mouseY >= yPos && mouseY <= yPos + h) {
      active = true;
    }
    else {
      active = false;
    }
  }
}

// ************************
// Timeline
// ************************
class Timeline extends UIComponent {
  int trackXOff = 100;
  int trackYOff = 20 + uiPadding * 2;
  int trackWidth = 600;
  int trackHeight = 30;
  int trackXPad = 5;
  int trackYPad = 8;
  
  Timeline(String n, int x, int y) {
    super(n, x, y);
  }
  
  void draw() {
    int numParams = sequenceParams.entrySet().size();
    int trackX = xPos + trackXOff;
    
    // panel background
    stroke(uiDarkBorder);
    fill(uiPanelBG);
    rect(xPos, yPos, trackXOff + trackWidth, trackYOff + numParams * trackHeight, 2);
    
    // parameter tracks
    int i = 0;
    textAlign(LEFT, TOP);
    for (Map.Entry<String, ArrayList<Keyframe>> seqParam : sequenceParams.entrySet()) {
      int trackTop = yPos + trackYOff + i * trackHeight;
      int trackBottom = trackTop + trackHeight;
      
      // track background
      fill(200);
      stroke(uiLightBorder);
      strokeWeight(1.8);
      rect(trackX, trackTop, trackWidth - 1, trackHeight);
      strokeWeight(1);
      
      // name box
      stroke(uiLightBorder);
      strokeWeight(1.8);
      fill(185);
      rect(xPos + 1, trackTop, trackXOff - 1, trackHeight);
      strokeWeight(1);
      
      // name text
      fill(uiTextBlack);
      text(seqParam.getKey(), xPos + uiPadding, trackTop + 7);
      
      // keyframe dots
      fill(uiKeyframe);
      int prevX = 0, prevY = 0;
      int j = 0;
      for (Keyframe k : seqParam.getValue()) {
        float xPct = k.time / param("sequenceLength");
        int xDist = int(xPct * (trackWidth - trackXPad * 2)) + trackXPad;
        float yPct = k.value / getSetting(seqParam.getKey()).maxVal;
        int yDist = int(yPct * (trackHeight - trackYPad * 2)) + trackYPad;
        noStroke();
        circle(trackX + xDist, trackBottom - yDist, 5);
        stroke(uiKeyframe);
        
        // line connecting to previous keyframe
        if (j > 0) {
          line(trackX + xDist, trackBottom - yDist,
            trackX + prevX, trackTop + trackHeight - prevY);
        }
        // line extending to end of sequence from last keyframe
        if (j == seqParam.getValue().size() - 1 && k.time < param("sequenceLength")) {
          line(trackX + xDist, trackBottom - yDist,
            trackX + trackWidth, trackBottom - yDist);
        }
        prevX = xDist;
        prevY = yDist;
        j++;
      }
      i++;
    }
    
    // position marker
    fill(0);
    noStroke();
    float seqProg = param("sequencePosition") / param("sequenceLength");
    int markerX = int(seqProg * (trackWidth - trackXPad * 2)) + trackXPad;
    rect(trackX + markerX, yPos + 28, 1, 7 + numParams * trackHeight, 2);
  }
}
