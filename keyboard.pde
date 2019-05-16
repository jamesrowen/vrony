void keyPressed() {
  // space
  if (keyCode == 32) {
    getSetting("play").advance();
  }
  // C
  if (keyCode == 67) {
    getSetting("colorMode").advance();
  }
  // P
  if (keyCode == 80) {
    getSetting("palette").advance();
  }
  // S
  if (keyCode == 83) {
    showUI = !showUI;
  }
  // M
  if (keyCode == 77) {
    getSetting("mode").advance();
  }
}
