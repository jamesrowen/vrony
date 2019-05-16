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

HashMap<String, Setting> settings = new HashMap<String, Setting>();

void setupSettings() {
  // basics
  settings.put("mode", new Setting(1, 0, 1, 1, true));
  settings.put("play", new Setting(1, 0, 1, 1, false));
  
  // color
  settings.put("colorMode", new Setting(1, 0, 2, 1, true));
  settings.put("palette", new Setting(1, 0, 2, 0, true));
  settings.put("numColors", new Setting(1, 0, 4, 3, true));
  
  // all modes
  settings.put("speed", new Setting(0, 0, 1, .2, true));
  settings.put("pointOpacity", new Setting(0, 0, 1, 0, true));
  settings.put("borderOpacity", new Setting(0, 0, 1, 1, true));
  settings.put("numRings", new Setting(0, 2, 30, 16, true));
  settings.put("ringSize", new Setting(0, 1, 80, 40.9, true));
  settings.put("ringSpokes", new Setting(0, 3, 40, 24, true));
  settings.put("ringTwist", new Setting(0, 0, .2, 0, true));
  settings.put("alternate", new Setting(1, 0, 1, 1, true));
  
  // concentric mode
  settings.put("perturbAmount", new Setting(0, 0, 100, 20, true));
  settings.put("perturbSpeed", new Setting(0, 2, 40, 5, true));
  settings.put("perturbWrap", new Setting(0, 0, 100, 5, true));
  
  // gear mode
  settings.put("wheelSize", new Setting(0, 100, 400, 250, true));
  settings.put("wheelSpokes", new Setting(0, 1, 40, 10, true));
  settings.put("wheelSpeed", new Setting(0, 0, 10, 1, true));
  settings.put("lissajousX", new Setting(0, 1, 4, 1, true));
  settings.put("lissajousY", new Setting(0, 1, 4, 1, true));
  
  //sequencer
  settings.put("sequencer", new Setting(1, 0, 1, 1, false));
  settings.put("sequencePlay", new Setting(1, 0, 1, 0, false));
  settings.put("sequencePosition", new Setting(0, 0, 100000, 0, true));
  settings.put("sequenceLength", new Setting(0, 0, 100000, 10, true));
}

float getSetting(String name) {
  return settings.get(name).value;
}

void setSetting(String name, float val) {
  settings.get(name).value = val;
}
