FloatDict s = new FloatDict();
IntDict si = new IntDict();

void setupSettings() {
  s.set("speed", .2);
  s.set("pointOpacity", 0);
  s.set("borderOpacity", 1);
  s.set("numRings", 16);
  s.set("ringSize", 40.9);
  s.set("ringSpokes", 24);
  s.set("ringTwist", 0);
  
  // concentric mode
  s.set("perturbAmount", 20);
  s.set("perturbSpeed", 5);
  s.set("perturbWrap", 5);
  
  // gear mode
  s.set("wheelSize", 250);
  s.set("wheelSpokes", 10);
  s.set("wheelSpeed", 1);
  s.set("lissajousX", 1);
  s.set("lissajousY", 1);
  
  //sequencer
  s.set("sequencePosition", 0);
  
  // integer settings (cyclical)
  si.set("mode", 1);
  si.set("colorMode", 1);
  si.set("palette", 0);
  si.set("numColors", 3);
  si.set("alternate", 1);
  si.set("play", 1);
  // sequencer
  si.set("sequencer", 1);
  si.set("sequencePlay", 0);
}

class Setting {
  String name;
  int type;
  float minVal;
  float maxVal;
  float defaultVal;
}
