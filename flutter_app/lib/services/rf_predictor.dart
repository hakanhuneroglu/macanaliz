import 'dart:math';

class RFPredictor {
  static Map<String, dynamic> predict(List<double> f) {
    if (f.isEmpty) {
      return {
        "ms": "MSX",
        "confidence": 50,
        "risk": "SARI",
        "score": "1-1",
      };
    }

    final avg = f.reduce((a, b) => a + b) / f.length;

    double p1 = 0, px = 0, p2 = 0;

    if (avg > 0.65) {
      p1 = avg * 0.8;
      px = (1 - avg) * 0.15;
      p2 = (1 - avg) * 0.05;
    } else if (avg < 0.35) {
      p2 = (1 - avg) * 0.8;
      px = (avg) * 0.1;
      p1 = (avg) * 0.1;
    } else {
      px = 0.6;
      p1 = (avg) * 0.3;
      p2 = (1 - avg) * 0.1;
    }

    double total = p1 + px + p2;
    p1 /= total;
    px /= total;
    p2 /= total;

    final map = {"MS1": p1, "MSX": px, "MS2": p2};

    String best = "MSX";
    double prob = px;

    map.forEach((k, v) {
      if (v > prob) {
        best = k;
        prob = v;
      }
    });

    final confidence = (prob * 100).round();

    String risk;
    if (confidence >= 70) {
      risk = "YESIL";
    } else if (confidence >= 40) {
      risk = "SARI";
    } else {
      risk = "KIRMIZI";
    }

    String score;
    if (best == "MS1") {
      score = confidence >= 60 ? "2-1" : "1-0";
    } else if (best == "MS2") {
      score = confidence >= 60 ? "1-2" : "0-1";
    } else {
      score = "1-1";
    }

    return {
      "ms": best,
      "confidence": confidence,
      "risk": risk,
      "score": score,
    };
  }
}
