#include <math.h>
#include <sstream>
#include <fstream>
#include <iostream>
#include <bitset>
#include <vector>
#include <algorithm>
 
const auto MAX_N_POINTS = 110;
const auto MAX_N_LINES = 220;
class LineIncidence {
  int nPoints;
  std::bitset<MAX_N_POINTS> mPoints; // i-th bit indicates whether i-th point is on the line
public:
  LineIncidence() {}
  LineIncidence(int p) : nPoints(p) {}
  friend std::ostream& operator<<(std::ostream& os, const LineIncidence& li); 
  void pointOn(std::size_t i) { mPoints.set(i); }
};



/*
This is created from a vector with 27 entries which describe how many free lines and how many types of points with pins exist in a PL1P.
So one of the entries is "f", the number of free lines.
The other 26 entries count the different types of points with pins. 
"p3" to "p7" count the number of points with 3,...,7 pins, respectively.
"p00", "p10" and "p20" count the number of points with 0,1,2 pins which are completely visible by all 3 cameras.
The other 18 entries have 3 indices i, j and k (so the look like "pijk").
These count the number of points with i pins, 
which have a difference of j parameters in comparison to complete visibility,
where k enumerates the different ordering of the 3 cameras.
Using this notation, the input vector with 27 entries looks as follows:
p7,p6,p5,p4,p3,p20,p10,p00,p110,p111,p112,f,p120,p121,p122,p123,p124,p125,p020,p021,p022,p130,p131,p132,p240,p241,p242
*/
class IntSol {
  int f;
  int p7;
  int p6;
  int p5;
  int p4;
  int p3;
  int p20;
  std::vector<int> p24;
  int p10;
  std::vector<int> p11;
  std::vector<int> p12;
  std::vector<int> p13;
  int p00;
  std::vector<int> p02;
public:
  IntSol(const std::vector<int>& ints) : f(ints[11]), p7(ints[0]), p6(ints[1]), p5(ints[2]), p4(ints[3]), p3(ints[4]), p20(ints[5]), p10(ints[6]), p00(ints[7]), p24({ints[24], ints[25], ints[26]}), p11({ints[8], ints[9], ints[10]}), p12({ints[12], ints[13], ints[14], ints[15], ints[16], ints[17]}), p13({ints[21], ints[22], ints[23]}), p02({ints[18], ints[19], ints[20]}) {}
  int nF() const { return f;}
  int nP7() const { return p7;}
  int nP6() const { return p6;}
  int nP5() const { return p5;}
  int nP4() const { return p4;}
  int nP3() const { return p3;}
  int nP20() const { return p20;}
  std::vector<int> nP24() const { return p24;}
  int nP10() const { return p10;}
  std::vector<int> nP11() const { return p11;}
  std::vector<int> nP12() const { return p12;}
  std::vector<int> nP13() const { return p13;}
  int nP00() const { return p00;}
  std::vector<int> nP02() const { return p02;}
};
	
class Arrangement3D {
  int nPoints;
  int nFreeLines;
  std::vector<int> nPointsWithPins;
public:
  Arrangement3D(int f, const std::vector<int>& nPP) : nPoints(0), nFreeLines(f), nPointsWithPins(nPP) {
    for (auto const & p : nPointsWithPins) nPoints += p;
  }
  int nP() const { return nPoints; }
  int nFL() const { return nFreeLines; }
  int maxPins() const { return nPointsWithPins.size()-1; }
  int nPwithXpins(int x) const { return nPointsWithPins[x]; }
  int nL() const { 
    int n = nP();
    int pinLines = 0;
    for (int pins = 1; pins < nPointsWithPins.size(); ++pins)
      pinLines += pins*nPointsWithPins[pins];
    return nFreeLines + pinLines; 
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
  IncidenceMatrix(const Arrangement3D&);
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

class PL1P {
  int nCameras;
  Arrangement3D graph;
  std::vector<VisibilityPattern> cameras;
public:
  PL1P(int nC, const Arrangement3D & hc) : nCameras(nC), graph(hc), cameras(nC) {}
  VisibilityPattern& camera(int i) { return cameras[i]; }
  bool occludeInPlace(int c, std::vector<int> pp, std::vector<int> ll);
  friend std::ostream& operator<<(std::ostream& os, const PL1P & plp);
  int nP() const { return graph.nP(); }
  int nL() const { return graph.nL(); }
  int nFL() const { return graph.nFL(); }
  int maxPins() const { return graph.maxPins(); }
  int nPwithXpins(int x) const { return graph.nPwithXpins(x); }
}; 

std::vector<std::vector<int>> readCandidatesFromFile ();

PL1P createMinimalReducedCandidate(std::vector<int> ints);

void parseToM2(PL1P plp, std::ostream& f);

void printVector(std::vector<int> v, std::ostream& f);

// null stream for debugging
class NullBuffer;
extern std::ostream null_stream;
 

