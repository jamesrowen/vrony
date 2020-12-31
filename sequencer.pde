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
  sequenceParams.get("speed").add(new Keyframe(0, .6));
  sequenceParams.get("speed").add(new Keyframe(4, .2));
  sequenceParams.get("speed").add(new Keyframe(6, .08));
  sequenceParams.get("speed").add(new Keyframe(10, .6));
  sequenceParams.put("pointOpacity", new ArrayList<Keyframe>());
  sequenceParams.get("pointOpacity").add(new Keyframe(0, 0));
  sequenceParams.get("pointOpacity").add(new Keyframe(1, 0));
  sequenceParams.get("pointOpacity").add(new Keyframe(2, 1));
  sequenceParams.get("pointOpacity").add(new Keyframe(3, 0));
  sequenceParams.get("pointOpacity").add(new Keyframe(16, .2));
  sequenceParams.put("ringSize", new ArrayList<Keyframe>());
  sequenceParams.get("ringSize").add(new Keyframe(0, 10));
  sequenceParams.get("ringSize").add(new Keyframe(4, 70));
  sequenceParams.get("ringSize").add(new Keyframe(6, 80));
  sequenceParams.get("ringSize").add(new Keyframe(18, 10));
  sequenceParams.put("numRings", new ArrayList<Keyframe>());
  sequenceParams.get("numRings").add(new Keyframe(0, 16));
  sequenceParams.get("numRings").add(new Keyframe(2, 12));
  sequenceParams.get("numRings").add(new Keyframe(4, 16));
  sequenceParams.get("numRings").add(new Keyframe(19, 16));
  sequenceParams.put("borderBrightness", new ArrayList<Keyframe>());
  sequenceParams.get("borderBrightness").add(new Keyframe(0, 0));
}

void tickSequence(float tick) {
  setSetting("sequencePosition", (param("sequencePosition") + tick) % param("sequenceLength"));
  // go through each setting and calculate the current value
  for (Map.Entry<String, ArrayList<Keyframe>> setting : sequenceParams.entrySet()) {
    ArrayList<Keyframe> keyframes = setting.getValue();
    // get current keyframe
    int index = 0;
    while (index < keyframes.size() && keyframes.get(index).time <= param("sequencePosition")) {
      index++;
    }
    if (index < setting.getValue().size()) {
      Keyframe curr = keyframes.get(index);
      Keyframe prev = keyframes.get(index - 1);
      float x = (param("sequencePosition") - prev.time) / (curr.time - prev.time);
      setSetting(setting.getKey(), lerp(prev.value, curr.value, x));
    }
    // if past last keyframe, use that value
    else {
      setSetting(setting.getKey(), keyframes.get(index - 1).value);
    }
  }
}
