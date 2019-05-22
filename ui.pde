ArrayList<UIComponent> uiComponents = new ArrayList<UIComponent>();

// ui colors
int uiTextBlack = 0;
int uiDarkBorder = 120;
int uiLightBorder = 135;
int uiDarkGray = 210;
int uiLightGray = 240;
color uiLightBlue = color(117, 218, 255);
color uiPanelBG = color(220, 250);
color uiKeyframe = color(255, 0, 0);

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
  // timeline seek
  float seqDispStart = 0, seqDispLen = 10;
  int seekBarY = 0, seekBarHeight = 18;
  int seekHandleX = 0, seekHandleWidth = 14;
  boolean seekHandleActive = false;
  int dragStartX = 0, handleStartX = 0;
  
  // grid numbers
  int gridLabelX = 0, gridLabelY = 0, gridLabelHeight = 18;
  int gridLabelXOff = 4;
  int gridLabelStep = 1;
  float gridStep = .5;
  
  // automation lanes
  int nameBoxWidth = 120;
  int laneX = 0, laneYStart = 0;
  int laneYOff = seekBarHeight + gridLabelHeight + 2;
  int laneWidth = 700, laneHeight = 34, laneYPad = 8;
  
  Timeline(String n, int x, int y) {
    super(n, x, y);
    seekBarY = yPos + 2;
    gridLabelY = seekBarY + seekBarHeight;
    laneX = xPos + nameBoxWidth;
    laneYStart = yPos + laneYOff;
  }
  
  void draw() {
    if (setting("sequencer") == 0) {
      return;
    }
    int numParams = sequenceParams.entrySet().size();
    
    // panel background
    stroke(uiDarkBorder);
    fill(uiPanelBG);
    rect(xPos, yPos, nameBoxWidth + laneWidth, laneYOff + numParams * laneHeight, 2);
    
    // seek bar track
    strokeWeight(thickBorder);
    fill(uiDarkGray - 30);
    stroke(uiLightBorder);
    rect(laneX, seekBarY, laneWidth - 1, seekBarHeight, 2);
    strokeWeight(1);
    // seek handle
    fill(uiLightGray - 10);
    if (seekHandleActive) {
      fill(uiLightBlue);
    }
    noStroke();
    rect(laneX + 4 + seekHandleX, seekBarY + 4, seekHandleWidth, seekBarHeight - 7, 2);
    
    // lane backgrounds
    for (int i = 0; i < sequenceParams.size(); i++) {
      // lane background
      stroke(uiLightBorder);
      strokeWeight(thickBorder);
      fill(200 + (i % 2) * 10);
      rect(laneX, laneYStart + i * laneHeight, laneWidth - 1, laneHeight);
      strokeWeight(1);
    }
    
    // grid label background
    strokeWeight(thickBorder);
    fill(uiLightBorder + 20);
    rect(laneX, gridLabelY, laneWidth - 1, gridLabelHeight);
    strokeWeight(1);
    
    // grid lines and numbers
    textAlign(LEFT, TOP);
    textSize(10);
    float curStep = ceil(seqDispStart / gridStep) * gridStep;
    while (curStep < seqDispStart + seqDispLen) {
      noStroke();
      // main grid line
      if (curStep % gridLabelStep == 0) {
        fill(uiDarkBorder + 10);
        rect(laneX + getTimelineX(curStep), gridLabelY + 10, 1, gridLabelHeight - 10 + numParams * laneHeight);
        // grid number
        if ((getTimelineX(curStep) + gridLabelXOff + 15 <= laneWidth)) {
          fill(uiTextBlack);
          text(int(curStep), laneX + getTimelineX(curStep) + gridLabelXOff, gridLabelY + 5);
        }
      }
      // secondary grid line
      else {
        fill(uiLightBorder + 10, 128);
        rect(laneX + getTimelineX(curStep), gridLabelY + gridLabelHeight, 1, numParams * laneHeight);
      }
      curStep += gridStep;
    }
    textSize(uiTextSize);
    
    // automation lanes
    int i = 0;
    textAlign(LEFT, TOP);
    for (Map.Entry<String, ArrayList<Keyframe>> seqParam : sequenceParams.entrySet()) {
      int laneTop = laneYStart + i * laneHeight;
      int laneBottom = laneTop + laneHeight;
      
      // keyframe lines and dots
      fill(uiKeyframe);
      strokeWeight(1.5);
      ArrayList<Keyframe> keyframes = seqParam.getValue();
      
      // find range of currently visible keyframes
      int firstVisibleKF = 0, lastVisibleKF = 0;
      while (firstVisibleKF < keyframes.size() && keyframes.get(firstVisibleKF).time < seqDispStart) {
        firstVisibleKF++;
      }
      lastVisibleKF = firstVisibleKF;
      while (lastVisibleKF < keyframes.size() && keyframes.get(lastVisibleKF).time < seqDispStart + seqDispLen) {
        lastVisibleKF++;
      }
      lastVisibleKF--;
      
      // if no keyframes visible, interpolate between two nearest
      if (firstVisibleKF > lastVisibleKF) {
        stroke(uiKeyframe);
        int x1 = getTimelineX(keyframes.get(lastVisibleKF).time);
        int y1 = getTimelineY(keyframes.get(lastVisibleKF).value / getSetting(seqParam.getKey()).maxVal);
        int x2 = laneWidth;
        int y2 = y1;
        if (firstVisibleKF < keyframes.size()) {
          x2 = getTimelineX(keyframes.get(firstVisibleKF).time);
          y2 = getTimelineY(keyframes.get(firstVisibleKF).value / getSetting(seqParam.getKey()).maxVal);
        }
        y1 -= x1 / float(x2 - x1) * (y2 - y1);
        y2 -= (x2 - laneWidth) / float(x2 - x1) * (y2 - y1);
        
        line(laneX, laneBottom - y1, laneX + laneWidth, laneBottom - y2);
        
      }
      
      for (int j = firstVisibleKF; j < lastVisibleKF + 1; j++) {
        int x1 = getTimelineX(keyframes.get(j).time);
        int y1 = getTimelineY(keyframes.get(j).value / getSetting(seqParam.getKey()).maxVal);
        
        // keyframe dot
        noStroke();
        circle(laneX + x1, laneBottom - y1, 5);
        
        // line connecting to previous keyframe
        stroke(uiKeyframe);
        if (j > 0) {
          int x0 = getTimelineX(keyframes.get(j - 1).time);
          int y0 = getTimelineY(keyframes.get(j - 1).value / getSetting(seqParam.getKey()).maxVal);
          // if previous keyframe is off-screen, truncate line
          if (j == firstVisibleKF) {
            y0 -= x0 / float(x1 - x0) * (y1 - y0);
            x0 = 0;
          }
          line(laneX + x1, laneBottom - y1, laneX + x0, laneBottom - y0);
        }
          
        // if final keyframe, extend flat line to end of timeline
        if (j == keyframes.size() - 1) {
          line(laneX + x1, laneBottom - y1, laneX + laneWidth, laneBottom - y1);
        }
        // if there is a further keyframe off-screen, extend toward it
        else if (j == lastVisibleKF) {
          int x2 = getTimelineX(keyframes.get(j + 1).time);
          int y2 = getTimelineY(keyframes.get(j + 1).value / getSetting(seqParam.getKey()).maxVal);
          y2 -= (x2 - laneWidth) / float(x1 - x2) * (y1 - y2);
          x2 = laneWidth;
          
          line(laneX + x1, laneBottom - y1, laneX + x2, laneBottom - y2);
        }
      }
      
      // name background
      stroke(uiLightBorder);
      strokeWeight(thickBorder);
      fill(200 + (i % 2) * 10);
      rect(xPos + 1, laneTop, nameBoxWidth - 1, laneHeight);
      strokeWeight(1);
      // name text
      fill(uiTextBlack);
      text(seqParam.getKey(), xPos + uiPadding, laneTop + 16);
      
      i++;
    }
    
    // position marker
    if (param("sequencePosition") > seqDispStart && param("sequencePosition") < seqDispStart + seqDispLen) {
      fill(0);
      noStroke();
      int markerX = getTimelineX(param("sequencePosition"));
      rect(laneX + markerX, gridLabelY, 1, numParams * laneHeight + gridLabelHeight);
    }
  }
  
  void testClick() {
    if (mouseX >= laneX + seekHandleX && mouseX <= laneX + seekHandleX + seekHandleWidth
      && mouseY >= seekBarY && mouseY <= seekBarY + seekBarHeight) {
      seekHandleActive = true;
      dragStartX = mouseX;
      handleStartX = seekHandleX;
    }
  }
  
  void doDrag() {
    if (seekHandleActive) {
      int maxPos = laneWidth - 8 - seekHandleWidth;
      seekHandleX = min(max(handleStartX + mouseX - dragStartX, 0), maxPos);
      seqDispStart = lerp(0, param("sequenceLength") - seqDispLen, seekHandleX / float(maxPos));
    }
  }
  
  void doRelease() {
    seekHandleActive = false;
  }
  
  int getTimelineX(float time) {
    return int((time - seqDispStart) / seqDispLen * laneWidth);
  }
  
  int getTimelineY(float value) {
    return int(value * (laneHeight - laneYPad * 2)) + laneYPad;
  }
}
