// *****************
// Keyframe
// *****************
class Keyframe {
  String setting;
  float startTime, endTime;
  float endVal;
  
  Keyframe(String s, float sT, float eT, float eV) {
    setting = s;
    startTime = sT;
    endTime = eT;
    endVal = eT;
  }
}

ArrayList<Keyframe> sequence = new ArrayList<Keyframe>();
