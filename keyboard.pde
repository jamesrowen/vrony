void keyPressed() {
  // space
  if (keyCode == 32) {
    si.set("play", (si.get("play") + 1) % 2);
  }
  // C
  if (keyCode == 67) {
    si.set("colorMode", (si.get("colorMode") + 1) % 3);
  }
  // P
  if (keyCode == 80) {
    si.set("palette", (si.get("palette") + 1) % 3);
  }
  // S
  if (keyCode == 83) {
    showUI = !showUI;
  }
  // M
  if (keyCode == 77) {
    si.set("mode", (si.get("mode") + 1) % 2);
  }
}
