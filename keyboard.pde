void keyPressed() {
  // space
  if (keyCode == 32) {
    settings.get("play").advance();
  }
  // C
  if (keyCode == 67) {
    settings.get("colorMode").advance();
  }
  // P
  if (keyCode == 80) {
    settings.get("palette").advance();
  }
  // S
  if (keyCode == 83) {
    showUI = !showUI;
  }
  // M
  if (keyCode == 77) {
    settings.get("mode").advance();
  }
}
