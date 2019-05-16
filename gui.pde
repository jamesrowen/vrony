ArrayList<UIComponent> uiComponents = new ArrayList<UIComponent>();

int uiXOff = 8;
int uiDarkGray = 190;
int uiLightGray = 240;
int uiDarkBorder = 80;
int uiLightBorder = 120;
int uiTextBlack = 0;

void setupUI() {
  textSize(14);
  int x0 = 155;
  int y0 = 12;
  int spacing = 30;
  int bSpacing = 110;
  int by = 460;
  uiComponents.add(new Slider("speed", x0, y0));
  uiComponents.add(new Slider("pointOpacity", x0, y0 + spacing * 1));
  uiComponents.add(new Slider("borderOpacity", x0, y0 + spacing * 2));
  uiComponents.add(new Slider("numRings", x0, y0 + spacing * 3));
  uiComponents.add(new Slider("ringSpokes", x0, y0 + spacing * 4));
  uiComponents.add(new Slider("ringSize", x0, y0 + spacing * 5));
  uiComponents.add(new Slider("ringTwist", x0, y0 + spacing * 6));
  uiComponents.add(new Slider("wheelSpokes", x0, y0 + spacing * 7));
  uiComponents.add(new Slider("wheelSize", x0, y0 + spacing * 8));
  uiComponents.add(new Slider("wheelSpeed", x0, y0 + spacing * 9));
  uiComponents.add(new Slider("lissajousX", x0, y0 + spacing * 10));
  uiComponents.add(new Slider("lissajousY", x0, y0 + spacing * 11));
  uiComponents.add(new Slider("perturbAmount", x0, y0 + spacing * 12));
  uiComponents.add(new Slider("perturbSpeed", x0, y0 + spacing * 13));
  uiComponents.add(new Slider("perturbWrap", x0, y0 + spacing * 14));
  uiComponents.add(new Button("play", uiXOff, by));
  uiComponents.add(new Button("mode", uiXOff + bSpacing, by));
  uiComponents.add(new Button("alternate", uiXOff + bSpacing * 2, by));
  uiComponents.add(new Button("colorMode", uiXOff, by + 25));
  uiComponents.add(new Button("palette", uiXOff + bSpacing, by + 25));
  uiComponents.add(new Button("numColors", uiXOff + bSpacing * 2, by + 25));
  // sequencer
  int seqX = 400;
  uiComponents.add(new Button("sequencePlay", seqX, y0));
  uiComponents.add(new Timeline("timeline", 4, 560));
}

void drawUI() {
  if (showUI) {
    stroke(0, 0, 0);
    fill(190, 210);
    rect(4, 4, 335, 540, 2);
    fill(0);
    textAlign(LEFT, BOTTOM);
    
    // debugging output
    text("keyCode: " + keyCode, uiXOff, height - 10);
    text("sequencePos: " + getSetting("sequencePosition"), uiXOff, height - 24);
    
    for (UIComponent c : uiComponents) {
      c.draw();
    }
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
  int boxSize = 15;
  int sliderWidth = 150;
  int dragStartX = 0;
  int boxStartX = 0;
  
  Slider(String n, int x, int y) {
    super(n, x, y);
    Setting s = settings.get(name);
    boxPos = int((s.value - s.minVal) / (s.maxVal - s.minVal) * sliderWidth);
  }
  
  void testClick() {
    if (mouseX >= xPos + boxPos && mouseX <= xPos + boxPos + boxSize && mouseY >= yPos && mouseY <= yPos + boxSize) {
      active = true;
      dragStartX = mouseX;
      boxStartX = boxPos;
    }
  }
  
  void doDrag() {
    if (active) {
      boxPos = min(max(boxStartX + mouseX - dragStartX, 0), sliderWidth);
      Setting s = settings.get(name);
      s.value = lerp(s.minVal, s.maxVal, boxPos / float(sliderWidth));
    }
  }
  
  void doRelease() {
    active = false;
  }
  
  void draw() {
    Setting s = settings.get(name);
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
    rect(xPos + 5, yPos + boxSize - 4, sliderWidth + boxSize + 4, 5, 2);
    
    // draw slider
    fill(uiLightGray);
    stroke(uiDarkBorder);
    if (active) {
      fill(117, 218, 255);
      stroke(80, 80, 160);
    }
    rect(xPos + boxPos + 7, yPos - 2, boxSize, boxSize, 2);
  }
}


// ******
// Button
// ******
class Button extends UIComponent {
  int w = 100;
  int h = 21;
  
  Button(String n, int x, int y) {
    super(n, x, y);
  }
  
  void testClick() {
    if (mouseX >= xPos && mouseX <= xPos + w && mouseY >= yPos && mouseY <= yPos + h) {
      Setting s = settings.get(name);
      s.value = (int)(s.value + 1) % (int)(s.maxVal + 1);
    }
  }
  
  void draw() {
    fill(uiLightGray);
    stroke(uiDarkBorder);
    rect(xPos, yPos, w, h, 2);
    fill(uiTextBlack);
    textAlign(CENTER, TOP);
    text(name + "  " + (int)getSetting(name), xPos + w / 2, yPos + 2);
  }
}


// ********
// Timeline
// ********
class Timeline extends UIComponent {
  int w = 600;
  
  Timeline(String n, int x, int y) {
    super(n, x, y);
  }
  
  void draw() {
    fill(uiDarkGray);
    stroke(uiLightBorder);
    rect(xPos, yPos, 600, 8, 2);
    fill(uiLightGray);
    stroke(uiDarkBorder);
    int seqX = int(getSetting("sequencePosition") / getSetting("sequenceLength") * w);
    rect(xPos + seqX, yPos - 15, 8, 30);
  }
}
