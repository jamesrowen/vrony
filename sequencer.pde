import java.util.Map;

class Keyframe {
  float time;
  float value;
  
  Keyframe(float t, float v) {
    time = t;
    value = v;
  }
}

HashMap<String, ArrayList<Keyframe>> sequenceParams = new HashMap<String, ArrayList<Keyframe>>();

void setupSequencer() {
  sequenceParams.put("speed", new ArrayList<Keyframe>());
  sequenceParams.get("speed").add(new Keyframe(0, .2));
  sequenceParams.get("speed").add(new Keyframe(3, .7));
  sequenceParams.get("speed").add(new Keyframe(4, .1));
  sequenceParams.put("pointOpacity", new ArrayList<Keyframe>());
  sequenceParams.get("pointOpacity").add(new Keyframe(0, 0));
  sequenceParams.get("pointOpacity").add(new Keyframe(3, 1));
  sequenceParams.get("pointOpacity").add(new Keyframe(5, 0));
}

void tickSequence(float tick) {
  setSetting("sequencePosition", getSetting("sequencePosition") + tick);
  // go through each setting and calculate the current value
  for (Map.Entry<String, ArrayList<Keyframe>> setting : sequenceParams.entrySet()) {
    ArrayList<Keyframe> keyframes = setting.getValue();
    int index = 0;
    while (index < keyframes.size() && keyframes.get(index).time <= getSetting("sequencePosition")) {
      index++;
    }
    if (index < setting.getValue().size()) {
      Keyframe curr = keyframes.get(index);
      Keyframe prev = keyframes.get(index - 1);
      float x = (getSetting("sequencePosition") - prev.time) / (curr.time - prev.time);
      setSetting(setting.getKey(), lerp(prev.value, curr.value, x));
    }
  }
}
