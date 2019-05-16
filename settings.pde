class Setting {
  int type;
  float value;
  float minVal;
  float maxVal;
  float defaultVal;
  boolean sequenced;
  
  Setting(int t, float min, float max, float d, boolean s) {
    type = t;
    minVal = min;
    maxVal = max;
    value = defaultVal = d;
    sequenced = s;
  }
  
  void advance() {
    if (type == 0) {
      println("cannot advance float-type setting");
    }
    else {
      value = (int)(value + 1) % (int)(maxVal + 1);
    }
  }
}

HashMap<String, Setting> settingsMap = new HashMap<String, Setting>();

void setupSettings() {
  // basics
  settingsMap.put("mode", new Setting(1, 0, 1, 1, true));
  settingsMap.put("play", new Setting(1, 0, 1, 1, false));
  
  // color
  settingsMap.put("colorMode", new Setting(1, 0, 2, 1, true));
  settingsMap.put("palette", new Setting(1, 0, 2, 0, true));
  settingsMap.put("numColors", new Setting(1, 0, 4, 3, true));
  
  // all modes
  settingsMap.put("speed", new Setting(0, 0, 1, .2, true));
  settingsMap.put("pointOpacity", new Setting(0, 0, 1, 0, true));
  settingsMap.put("borderOpacity", new Setting(0, 0, 1, 1, true));
  settingsMap.put("numRings", new Setting(0, 2, 30, 16, true));
  settingsMap.put("ringSize", new Setting(0, 1, 80, 40.9, true));
  settingsMap.put("ringSpokes", new Setting(0, 3, 40, 24, true));
  settingsMap.put("ringTwist", new Setting(0, 0, .2, 0, true));
  settingsMap.put("alternate", new Setting(1, 0, 1, 1, true));
  
  // concentric mode
  settingsMap.put("perturbAmount", new Setting(0, 0, 100, 20, true));
  settingsMap.put("perturbSpeed", new Setting(0, 2, 40, 5, true));
  settingsMap.put("perturbWrap", new Setting(0, 0, 100, 5, true));
  
  // gear mode
  settingsMap.put("wheelSize", new Setting(0, 100, 400, 250, true));
  settingsMap.put("wheelSpokes", new Setting(0, 1, 40, 10, true));
  settingsMap.put("wheelSpeed", new Setting(0, 0, 10, 1, true));
  settingsMap.put("lissajousX", new Setting(0, 1, 4, 1, true));
  settingsMap.put("lissajousY", new Setting(0, 1, 4, 1, true));
  
  //sequencer
  settingsMap.put("sequencer", new Setting(1, 0, 1, 1, false));
  settingsMap.put("sequencePlay", new Setting(1, 0, 1, 0, false));
  settingsMap.put("sequencePosition", new Setting(0, 0, 100000, 0, true));
  settingsMap.put("sequenceLength", new Setting(0, 0, 100000, 10, true));
}

float param(String name) {
  return settingsMap.get(name).value;
}

int setting(String name) {
  return (int)settingsMap.get(name).value;
}

Setting getSetting(String name) {
  return settingsMap.get(name);
}

void setSetting(String name, float val) {
  settingsMap.get(name).value = val;
}
