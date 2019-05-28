class Timeline extends UIComponent {
  // colors
  int timelineGray = 170;
  int timelineGrayDiff = 10;
  
  // timeline seek
  float tlViewStart = 0, tlViewLength = 10;
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
  int laneWidth = 700, laneHeight = 34, laneYPad = 6;
  HashMap<String, ArrayList<KeyframeHandle>> kfHandles;
  
  Timeline(String n, int x, int y) {
    super(n, x, y);
    seekBarY = yPos + 2;
    gridLabelY = seekBarY + seekBarHeight;
    laneX = xPos + nameBoxWidth;
    laneYStart = yPos + laneYOff;
    gridHeight = sequenceParams.entrySet().size() * laneHeight;
    populateVisibleKeyframes();
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
    drawAutomationLines();
    drawKeyframeHandles();
    drawParamNames();
    
    // position marker
    if (param("sequencePosition") > tlViewStart && param("sequencePosition") < tlViewStart + tlViewLength) {
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
    fill(uiLightBorder + 10);
    rect(laneX, gridLabelY, laneWidth - 1, gridLabelHeight);
    
    // lane backgrounds
    for (int i = 0; i < sequenceParams.size(); i++) {
      fill(timelineGray + (i % 2) * timelineGrayDiff);
      rect(laneX, laneYStart + i * laneHeight, laneWidth - 1, laneHeight);
    }
    strokeWeight(1);
    
    // grid lines and labels
    textAlign(LEFT, TOP);
    textSize(10);
    float curStep = ceil(tlViewStart / gridStep) * gridStep;
    while (curStep < tlViewStart + tlViewLength) {
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
        fill(uiLightBorder + 10, 100);
        rect(laneX + getTimelineX(curStep), gridLabelY + gridLabelHeight, 1, gridHeight);
      }
      curStep += gridStep;
    }
    textSize(uiTextSize);
  }
  
  void drawAutomationLines() {
    fill(kfColor);
    strokeWeight(kfStrokeWeight);
    stroke(kfColor);
    
    for (Map.Entry<String, ArrayList<KeyframeHandle>> paramRow : kfHandles.entrySet()) {
      ArrayList<KeyframeHandle> keyframeRow = paramRow.getValue();
      
      // if no visible keyframes, draw line connecting nearest ones outside the viewport
      if (keyframeRow.size() <= 2) {
        int x1 = keyframeRow.get(0).xPos;
        int y1 = keyframeRow.get(0).yPos;
        // default assumes no keyframes past viewport
        int x2 = laneX + laneWidth;
        int y2 = y1;
        // update if there is one
        if (keyframeRow.get(1).xPos - laneX > -1) {
          x2 = keyframeRow.get(1).xPos;
          y2 = keyframeRow.get(1).yPos;
        }
        // truncate line to viewport
        y1 -= (x1 - laneX) / float(x2 - x1) * (y2 - y1);
        y2 -= (x2 - laneX - laneWidth) / float(x2 - x1) * (y2 - y1);
        line(laneX, y1, laneX + laneWidth, y2);
      }
      // loop through visible keyframes and draw lines between them
      else {
        for (int j = 1; j < keyframeRow.size() - 1; j++) {
          KeyframeHandle k0 = keyframeRow.get(j - 1);
          KeyframeHandle k1 = keyframeRow.get(j);
          int x0 = k0.xPos;
          int y0 = k0.yPos;
          // line connecting to previous keyframe
          if (k0.xPos < laneX) {
            y0 -= (x0 - laneX) / float(k1.xPos - x0) * (k1.yPos - y0);
            x0 = laneX;
          }
          line(x0, y0, k1.xPos, k1.yPos);
          
          // last visible keyframe
          if (j == keyframeRow.size() - 2) {
            // if final keyframe, extend flat line to end of viewport
            if (keyframeRow.get(j + 1).xPos - laneX == -1) {
              line(k1.xPos, k1.yPos, laneX + laneWidth, k1.yPos);
            }
            // if there is a further keyframe, extend line towards it
            else {
              KeyframeHandle k2 = keyframeRow.get(j + 1);
              int y2 = k2.yPos - int((k2.xPos - laneX - laneWidth) / float(k1.xPos - k2.xPos) * (k1.yPos - k2.yPos));
              line(k1.xPos, k1.yPos, laneX + laneWidth, y2);
            }
          }
        }
      }
    }
  }
  
  void drawKeyframeHandles() {
    fill(timelineGray + timelineGrayDiff / 2);
    strokeWeight(kfStrokeWeight);
    for (Map.Entry<String, ArrayList<KeyframeHandle>> paramRow : kfHandles.entrySet()) {
      for (int j = 1; j < paramRow.getValue().size() - 1; j++) {
          paramRow.getValue().get(j).draw();
      }
    }
    strokeWeight(1);
  }
  
  void drawParamNames() {
    textAlign(LEFT, TOP);
    stroke(uiLightBorder);
    strokeWeight(thickBorder);
    
    int i = 0;
    for (Map.Entry<String, ArrayList<KeyframeHandle>> paramRow : kfHandles.entrySet()) {
      int laneTop = laneYStart + i * laneHeight;
      // parameter name box
      fill(timelineGray + 20 + (i % 2) * timelineGrayDiff);
      rect(xPos + 1, laneTop, nameBoxWidth - 1, laneHeight);
      // name text
      fill(uiTextBlack);
      text(paramRow.getKey(), xPos + uiPadding, laneTop + 16);
      
      i++;
    }
    strokeWeight(1);
  }
  
  boolean testClick() {
    if (mouseX >= laneX + seekHandleX && mouseX <= laneX + seekHandleX + seekHandleWidth
      && mouseY >= seekBarY && mouseY <= seekBarY + seekBarHeight) {
      seekHandleActive = true;
      dragStartX = mouseX;
      handleStartX = seekHandleX;
      return true;
    }
    for (Map.Entry<String, ArrayList<KeyframeHandle>> kf : kfHandles.entrySet()) {
      for (KeyframeHandle h : kf.getValue()) {
        if (h.testClick()) {
          return true;
        }
      }
    }
    
    int laneTop = laneYStart;
    for (Map.Entry<String, ArrayList<Keyframe>> seqParam : sequenceParams.entrySet()) {
      if (mouseX > laneX && mouseX < laneX + laneWidth && mouseY >= laneTop + laneYPad
        && mouseY <= laneTop + laneHeight - laneYPad) {
        int index = 0;
        while (seqParam.getValue().get(index).time < getSeqTime(mouseX)) {
          index++;
        }
        seqParam.getValue().add(index, new Keyframe(getSeqTime(mouseX), getSeqVal(mouseY, laneTop) * getSetting(seqParam.getKey()).maxVal));
        populateVisibleKeyframes();
        return true;
      }
      laneTop += laneHeight;
    }
    return false;
  }
  
  void doDrag() {
    if (seekHandleActive) {
      int maxPos = laneWidth - 8 - seekHandleWidth;
      seekHandleX = min(max(handleStartX + mouseX - dragStartX, 0), maxPos);
      tlViewStart = lerp(0, param("sequenceLength") - tlViewLength, seekHandleX / float(maxPos));
      populateVisibleKeyframes();
    }
    for (Map.Entry<String, ArrayList<KeyframeHandle>> kf : kfHandles.entrySet()) {
      for (KeyframeHandle h : kf.getValue()) {
        h.doDrag();
      }
    }
  }
  
  void doRelease() {
    seekHandleActive = false;
    for (Map.Entry<String, ArrayList<KeyframeHandle>> kf : kfHandles.entrySet()) {
      for (KeyframeHandle h : kf.getValue()) {
        h.doRelease();
      }
    }
  }
  
  void populateVisibleKeyframes() {
    kfHandles = new HashMap<String, ArrayList<KeyframeHandle>>();
    int laneBottom = laneYStart + laneHeight;
    
    for (Map.Entry<String, ArrayList<Keyframe>> seqParam : sequenceParams.entrySet()) {
      ArrayList<KeyframeHandle> temp = new ArrayList<KeyframeHandle>();
      
      // find range of currently visible keyframes
      ArrayList<Keyframe> keyframes = seqParam.getValue();
      int firstVisibleKF = 0, lastVisibleKF = 0;
      while (firstVisibleKF < keyframes.size() && keyframes.get(firstVisibleKF).time < tlViewStart) {
        firstVisibleKF++;
      }
      lastVisibleKF = firstVisibleKF;
      while (lastVisibleKF < keyframes.size() && keyframes.get(lastVisibleKF).time < tlViewStart + tlViewLength) {
        lastVisibleKF++;
      }
      firstVisibleKF--;
      
      // include the keyframes just before and after the visible range (for drawing lines to them).
      // if either does not exist, set a sentinel keyframe with position (-1 ,-1)
      for (int i = firstVisibleKF; i < lastVisibleKF + 1; i++) {
        int kfX = -1, kfY = -1;
        if (i > -1 && i < keyframes.size()) {
          kfX = getTimelineX(keyframes.get(i).time);
          kfY = getTimelineY(keyframes.get(i).value / getSetting(seqParam.getKey()).maxVal);
        }
        
        temp.add(new KeyframeHandle(seqParam.getKey(), i, laneX + kfX, laneBottom - kfY, 
          laneBottom - laneHeight + laneYPad, laneBottom - laneYPad));
      }
      kfHandles.put(seqParam.getKey(), temp);
      
      laneBottom += laneHeight;
    }
  }
  
  int getTimelineX(float time) {
    return int((time - tlViewStart) / tlViewLength * laneWidth);
  }
  
  int getTimelineY(float value) {
    return int(value * (laneHeight - laneYPad * 2)) + laneYPad;
  }
  
  float getSeqTime(int screenX) {
    return (screenX - laneX) / float(laneWidth) * tlViewLength + tlViewStart; 
  }
  
  float getSeqVal(int screenY, int laneTop) {
    return 1 - (screenY - laneTop - laneYPad) / float(laneHeight - laneYPad * 2);
  }
}

// ************************
// KeyframeHandle
// ************************
class KeyframeHandle extends UIComponent {
  String paramName;
  int keyframeIndex;
  int minY, maxY;
  boolean active = false;
  int radius = 5;
  int dragStartY = 0, handleStartY = 0;
  
  KeyframeHandle(String p, int i, int x, int y, int miY, int maY) {
    super(p + i, x, y);
    paramName = p;
    keyframeIndex = i;
    minY = miY;
    maxY = maY;
  }
  
  void draw() {
    if (active) {
      stroke(uiLightBlue);
    }
    else {
      stroke(kfColor);
    }
    circle(xPos, yPos, radius);
  }
  
  boolean testClick() {
    if (mouseX >= xPos - radius && mouseX <= xPos + radius
      && mouseY >= yPos - radius && mouseY <= yPos + radius) {
      active = true;
      dragStartY = mouseY;
      handleStartY = yPos;
      return true;
    }
    return false;
  }
  
  void doDrag() {
    if (active) {
      yPos = min(max(handleStartY + mouseY - dragStartY, minY), maxY);
      float yPct = 1 - (yPos - minY) / float(maxY - minY);
      sequenceParams.get(paramName).get(keyframeIndex).value = yPct * getSetting(paramName).maxVal;
    }
  }
  
  void doRelease() {
    active = false;
  }
}
