ArrayList<UIComponent> uiComponents = new ArrayList<UIComponent>();

int uiXOff = 8;

void setupUI() {
  textSize(14);
  int x0 = 155;
  int y0 = 12;
  int spacing = 30;
  int bSpacing = 110;
  int by = 460;
  uiComponents.add(new Slider("speed", 0, 1, x0, y0));
  uiComponents.add(new Slider("pointOpacity", 0, 1, x0, y0 + spacing * 1));
  uiComponents.add(new Slider("borderOpacity", 0, 1, x0, y0 + spacing * 2));
  uiComponents.add(new Slider("numRings", 2, 30, x0, y0 + spacing * 3));
  uiComponents.add(new Slider("ringSpokes", 3, 40, x0, y0 + spacing * 4));
  uiComponents.add(new Slider("ringSize", 1, 80, x0, y0 + spacing * 5));
  uiComponents.add(new Slider("ringTwist", 0, .2, x0, y0 + spacing * 6));
  uiComponents.add(new Slider("wheelSpokes", 1, 40, x0, y0 + spacing * 7));
  uiComponents.add(new Slider("wheelSize", 100, 400, x0, y0 + spacing * 8));
  uiComponents.add(new Slider("wheelSpeed", 0, 10, x0, y0 + spacing * 9));
  uiComponents.add(new Slider("lissajousX", 1, 4, x0, y0 + spacing * 10));
  uiComponents.add(new Slider("lissajousY", 1, 4, x0, y0 + spacing * 11));
  uiComponents.add(new Slider("perturbAmount", 0, 100, x0, y0 + spacing * 12));
  uiComponents.add(new Slider("perturbSpeed", 2, 40, x0, y0 + spacing * 13));
  uiComponents.add(new Slider("perturbWrap", 0, 100, x0, y0 + spacing * 14));
  uiComponents.add(new Button("play", 2, uiXOff, by));
  uiComponents.add(new Button("mode", 2, uiXOff + bSpacing, by));
  uiComponents.add(new Button("alternate", 2, uiXOff + bSpacing * 2, by));
  uiComponents.add(new Button("colorMode", 3, uiXOff, by + 25));
  uiComponents.add(new Button("palette", 3, uiXOff + bSpacing, by + 25));
  uiComponents.add(new Button("numColors", 5, uiXOff + bSpacing * 2, by + 25));
  // sequencer
  int seqX = 400;
  uiComponents.add(new Button("sequencePlay", 2, seqX, y0));
}

void drawUI() {
  if (showUI) {
    stroke(0, 0, 0);
    fill(190, 210);
    rect(4, 4, 335, 540, 2);
    fill(0);
    textAlign(LEFT, BOTTOM);
    text("keyCode: " + keyCode, uiXOff, height - 10);
    text("sequencePos: " + s.get("sequencePosition"), uiXOff, height - 24);
    
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
  
  float minVal, maxVal;
  
  Slider(String n, float mi, float ma, int x, int y) {
    super(n, x, y);
    minVal = mi;
    maxVal = ma;
    boxPos = int((s.get(name) - minVal) / (maxVal - minVal) * sliderWidth);
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
      s.set(name, lerp(minVal, maxVal, boxPos / float(sliderWidth)));
    }
  }
  
  void doRelease() {
    active = false;
  }
  
  void draw() {
    // update position if changed elsewhere (keyboard, automation)
    boxPos = int((s.get(name) - minVal) / (maxVal - minVal) * sliderWidth);
    
    // draw text
    fill(0);
    textAlign(RIGHT, TOP);
    text(name + "  " + nf(s.get(name), 0, 1), xPos, yPos);
    textAlign(LEFT, BOTTOM);
    
    // draw track
    fill(190);
    stroke(100);
    rect(xPos + 5, yPos + boxSize - 4, sliderWidth + boxSize + 4, 5, 2);
    
    // draw slider
    fill(240);
    stroke(80);
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
  int numStates = 0;
  int state = 0;
  
  Button(String n, int num, int x, int y) {
    super(n, x, y);
    state = si.get(name);
    numStates = num;
  }
  
  void testClick() {
    if (mouseX >= xPos && mouseX <= xPos + w && mouseY >= yPos && mouseY <= yPos + h) {
      si.set(name, (si.get(name) + 1) % numStates);
    }
  }
  
  void draw() {
    state = si.get(name);
    
    fill(240);
    stroke(80);
    rect(xPos, yPos, w, h, 2);
    fill(0);
    textAlign(CENTER, TOP);
    text(name + "  " + state, xPos + w / 2, yPos + 2);
  }
}
