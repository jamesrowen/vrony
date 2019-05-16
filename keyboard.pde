void keyPressed() {
  // space
  if (keyCode == 32) {
    getSetting("play").advance();
  }
  // S
  if (keyCode == 83) {
    showUI = !showUI;
  }
}
