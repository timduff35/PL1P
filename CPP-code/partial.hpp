#include <iostream>
#include <bitset>
#include <vector>
#include <algorithm>
 
const auto MAX_N_POINTS = 11;
const auto MAX_N_LINES = 111;
class LineIncidence {
  int nPoints;
  std::bitset<MAX_N_POINTS> mPoints; // i-th bit indicates whether i-th point is on the line
public:
  LineIncidence() {}
  LineIncidence(int p) : nPoints(p) {}
  friend std::ostream& operator<<(std::ostream& os, const LineIncidence& li); 
  void pointOn(std::size_t i) { mPoints.set(i); }
};
	
class HairyClique {
  int nPoints;
  int nFreeLines;
  std::vector<int> nPointsWithPins;
public:
  HairyClique(int f, const std::vector<int>& nPP) : nPoints(0), nFreeLines(f), nPointsWithPins(nPP) {
    for (auto const & p : nPointsWithPins) nPoints += p;
  }
  int nP() const { return nPoints; }
  int nFL() const { return nFreeLines; }
  int maxPins() const { return nPointsWithPins.size(); }
  int nPwithXpins(int x) const { return nPointsWithPins[x]; }
  int nL() const { 
    int n = nP();
    int pinLines = 0;
    for (int pins = 1; pins < nPointsWithPins.size(); ++pins)
      pinLines += pins*nPointsWithPins[pins];
    return nFreeLines + pinLines + n*(n-1)/2; 
  }
};
 
class IncidenceMatrix {
  int nPoints;
  std::vector<LineIncidence> mLines;	
public:
  IncidenceMatrix(int p, int l) : nPoints(p), mLines(0) { 
    for(int i=0; i<l; ++i) mLines.push_back(LineIncidence(p)); 
  }
  friend std::ostream& operator<<(std::ostream& os, const IncidenceMatrix & im);
  IncidenceMatrix(const HairyClique&);
  void pointOn(int p, int l) { mLines[l].pointOn(p); }
};

class VisibilityPattern {
public:
  std::bitset<MAX_N_POINTS> points;
  std::bitset<MAX_N_LINES> lines; 
  VisibilityPattern() { points.set(); lines.set(); } // all visible by default
  void occludePoint(int i) { points.reset(i); } 
  void occludeLine(int i) { lines.reset(i); } 
};

class PLP {
  int nCameras;
  HairyClique graph;
  std::vector<VisibilityPattern> cameras;
public:
  PLP(int nC, const HairyClique & hc) : nCameras(nC), graph(hc), cameras(nC) {}
  VisibilityPattern& camera(int i) { return cameras[i]; }
  bool occludeInPlace(int c, std::vector<int> pp, std::vector<int> ll);
  friend std::ostream& operator<<(std::ostream& os, const PLP & plp);
}; 
