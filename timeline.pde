class Timeline extends UIComponent {
  // timeline seek
  float seqDispStart = 0, seqDispLen = 10;
  int seekBarY = 0, seekBarHeight = 18;
  int seekHandleX = 0, seekHandleWidth = 14;
  boolean seekHandleActive = false;
  int dragStartX = 0, handleStartX = 0;
  
  // grid
  float gridStep = .5;
  int gridHeight = 0;
  int gridLabelStep = 2;
  int gridLabelX = 0, gridLabelY = 0, gridLabelHeight = 18;
  int gridLabelXOff = 4;
  
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
    gridHeight = sequenceParams.entrySet().size() * laneHeight;
  }
  
  void draw() {
    if (setting("sequencer") == 0) {
      return;
    }
    
    // panel background
    stroke(uiDarkBorder);
    fill(uiPanelBG);
    rect(xPos, yPos, nameBoxWidth + laneWidth, laneYOff + gridHeight, 2);
    
    drawSeekBar();
    drawGrid();
    drawAutomationLanes();
    
    // position marker
    if (param("sequencePosition") > seqDispStart && param("sequencePosition") < seqDispStart + seqDispLen) {
      fill(0);
      noStroke();
      int markerX = getTimelineX(param("sequencePosition"));
      rect(laneX + markerX, gridLabelY, 1, gridHeight + gridLabelHeight);
    }
  }
  
  void drawSeekBar() {
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
  }
  
  void drawGrid() {
    strokeWeight(thickBorder);
    // grid label background
    stroke(uiLightBorder);
    fill(uiLightBorder + 20);
    rect(laneX, gridLabelY, laneWidth - 1, gridLabelHeight);
    
    // lane backgrounds
    for (int i = 0; i < sequenceParams.size(); i++) {
      fill(200 + (i % 2) * 10);
      rect(laneX, laneYStart + i * laneHeight, laneWidth - 1, laneHeight);
    }
    strokeWeight(1);
    
    // grid lines and labels
    textAlign(LEFT, TOP);
    textSize(10);
    float curStep = ceil(seqDispStart / gridStep) * gridStep;
    while (curStep < seqDispStart + seqDispLen) {
      noStroke();
      // primary grid line
      if (curStep % gridLabelStep == 0) {
        fill(uiDarkBorder + 10);
        rect(laneX + getTimelineX(curStep), gridLabelY + 10, 1, gridLabelHeight - 10 + gridHeight);
        // grid number
        if ((getTimelineX(curStep) + gridLabelXOff + 15 <= laneWidth)) {
          fill(uiTextBlack);
          text(int(curStep), laneX + getTimelineX(curStep) + gridLabelXOff, gridLabelY + 5);
        }
      }
      // secondary grid line
      else {
        fill(uiLightBorder + 10, 128);
        rect(laneX + getTimelineX(curStep), gridLabelY + gridLabelHeight, 1, gridHeight);
      }
      curStep += gridStep;
    }
    textSize(uiTextSize);
  }
  
  void drawAutomationLanes() {
    int i = 0;
    textAlign(LEFT, TOP);
    for (Map.Entry<String, ArrayList<Keyframe>> seqParam : sequenceParams.entrySet()) {
      int laneTop = laneYStart + i * laneHeight;
      int laneBottom = laneTop + laneHeight;
      fill(uiKeyframe);
      strokeWeight(1.5);
      
      // find range of currently visible keyframes
      ArrayList<Keyframe> keyframes = seqParam.getValue();
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
      
      // draw visible keyframes
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
      
      // draw parameter name box
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
