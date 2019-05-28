ArrayList<UIComponent> uiComponents = new ArrayList<UIComponent>();

// ui colors
int uiTextBlack = 0;
int uiDarkBorder = 120;
int uiLightBorder = 135;
int uiDarkGray = 210;
int uiLightGray = 240;
color uiLightBlue = color(117, 218, 255);
color uiPanelBG = color(220, 250);
color kfColor = color(255, 0, 0);
float kfStrokeWeight = 1.5;

int uiTextSize = 12;
int uiPadding = 5;
float thickBorder = 3;

void setupUI() {
  textSize(uiTextSize);
  
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
  //uiComponents.add(new Input("sequenceLength", bX + 202, timelineY + uiPadding));
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
  
  boolean testClick() { return false; }
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
  
  boolean testClick() {
    int x = xPos + boxPos + boxXOff;
    if (mouseX >= x && mouseX <= x + boxSize
      && mouseY >= yPos && mouseY <= yPos + boxSize) {
      active = true;
      dragStartX = mouseX;
      boxStartX = boxPos;
      return true;
    }
    return false;
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
    
    // name text
    fill(uiTextBlack);
    textAlign(RIGHT, TOP);
    text(name + "  " + nf(s.value, 0, 1), xPos, yPos);
    
    // slider track
    fill(uiDarkGray);
    stroke(uiLightBorder);
    rect(xPos + 5, yPos + boxSize - 3, sliderWidth + boxSize + 4, 5, 2);
    
    // slider
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
  
  boolean testClick() {
    if (mouseX >= xPos && mouseX <= xPos + w
      && mouseY >= yPos && mouseY <= yPos + h) {
      getSetting(name).advance();
      return true;
    }
    return false;
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
  
  boolean testClick() {
    if (mouseX >= xPos && mouseX <= xPos + w
      && mouseY >= yPos && mouseY <= yPos + h) {
      active = true;
      return true;
    }
    else {
      active = false;
      return false;
    }
  }
}
