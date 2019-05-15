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

void setupSequence() {
  sequenceParams.put("speed", new ArrayList<Keyframe>());
  sequenceParams.get("speed").add(new Keyframe(0, .2));
  sequenceParams.get("speed").add(new Keyframe(3, .7));
  sequenceParams.get("speed").add(new Keyframe(4, .1));
  sequenceParams.put("pointOpacity", new ArrayList<Keyframe>());
  sequenceParams.get("pointOpacity").add(new Keyframe(0, 0));
  sequenceParams.get("pointOpacity").add(new Keyframe(4, 1));
  sequenceParams.get("pointOpacity").add(new Keyframe(5, 0));
}

void tickSequence(float tick) {
  s.set("sequencePosition", s.get("sequencePosition") + tick);
  // go through each setting and calculate the current value
  for (Map.Entry<String, ArrayList<Keyframe>> setting : sequenceParams.entrySet()) {
    int index = 0;
    while (index < setting.getValue().size() && setting.getValue().get(index).time < s.get("sequencePosition")) {
      index++;
    }
    if (index < setting.getValue().size()) {
      Keyframe curr = setting.getValue().get(index);
      Keyframe prev = setting.getValue().get(index - 1);
      float x = (s.get("sequencePosition") - prev.time) / (curr.time - prev.time);
      s.set(setting.getKey(), lerp(prev.value, curr.value, x));
    }
  }
}
