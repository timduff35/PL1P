#include "pl1p.hpp"
#include <stdio.h>
#include <fstream>
#include <sstream>
#include <set>
#include <sys/stat.h>


/* listIntSols(n, a)
    INPUT: 
      -) int n
      -) vector<int> a = (a1, ... , al)
    OUTPUT: 
      -) a vector of all nonnegative vector<int>s (k1, .., kl) such that
            a1 * k1 + ... + al * kl = n
         which is lexicographically sorted: a>a' iff a-a'>0
*/
std::vector<std::vector<int>> listIntSols(int n, std::vector<int> a) {
  std::vector<std::vector<int>> sols;
  if (n == 0) {
    sols = {std::vector<int>(a.size())};
  }
  else {
    if (a.size() == 1) {
      if (n % a[0] == 0) {
        sols = {{n/a[0]}};
      }
      else {
        sols = {};
      }
    }
    else {
      sols = {};
      std::vector<std::vector<int>> partialSols;
      int k = floor(n/a[0]);
      int a0 = a[0];
      a.erase(a.begin());
      for (int i = 0; i <= k; ++i) {
        partialSols = listIntSols(n-i*a0,a);
        if (partialSols.size() > 0) {
          for (int j = 0; j < partialSols.size(); ++j) {
            partialSols[j].insert(partialSols[j].begin(),1,i);
          };
          sols.insert(sols.end(), partialSols.begin(), partialSols.end());
        }
      }
    };
  };
  return(sols);
}

std::vector<int> rotateSolution (std::vector<int> v) {
  std::vector <int> result = {v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[10],v[8],v[9],v[11],v[16],v[17],v[13],v[12],v[15],v[14],v[20],v[18],v[19],v[23],v[21],v[22],v[26],v[24],v[25]};
  return result;
}

std::vector<int> reflectSolution (std::vector<int> v) {
  std::vector <int> result = {v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[10],v[9],v[11],v[13],v[12],v[16],v[17],v[14],v[15],v[18],v[20],v[19],v[21],v[23],v[22],v[24],v[26],v[25]};
  return result;
}

std::vector<std::vector<int>> listMinimalReducedCandidates () {
  std::vector<int> weights = {10,9,8,7,6,5,4,3,3,3,3,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1};
  std::vector<std::vector<int>> solutions = listIntSols(11,weights);

  std::cout << "computed all solutions\n";

  std::vector<std::vector<int>> result = {};
  std::vector<int> currentSol;
  std::vector<int> orbitSol;
  std::vector<std::vector<int>>::iterator p;
  int count = 0;
  while (!solutions.empty()) {
    if (count % 1000 == 0)
    	std::cout << count << "\n";
    count = count+1;
    currentSol = solutions.back();
    result.push_back(currentSol);    
    solutions.pop_back();
    orbitSol = rotateSolution(currentSol);
    p = std::find(solutions.begin(), solutions.end(), orbitSol);
    if (p != solutions.end()) {
	solutions.erase(p);
    }
    orbitSol = rotateSolution(orbitSol);
    p = std::find(solutions.begin(), solutions.end(), orbitSol);
    if (p != solutions.end()) {
	solutions.erase(p);
    }
    orbitSol = reflectSolution(currentSol);
    p = std::find(solutions.begin(), solutions.end(), orbitSol);
    if (p != solutions.end()) {
	solutions.erase(p);
    }
    orbitSol = rotateSolution(orbitSol);
    p = std::find(solutions.begin(), solutions.end(), orbitSol);
    if (p != solutions.end()) {
	solutions.erase(p);
    }
    orbitSol = rotateSolution(orbitSol);
    p = std::find(solutions.begin(), solutions.end(), orbitSol);
    if (p != solutions.end()) {
	solutions.erase(p);
    }
  }
  return result;
}

void printToFile (std::vector<std::vector<int>> v){
  std::ofstream file;
  file.open ("candidates.txt");
  int count = 0;
  for (auto const & x : v) {
    file << count << ":";
    for (auto const & n : x) {
	file << " " << n;
    }
    file << "\n";
    count = count + 1;
  }
  file.close();
} 

void printIndicesToFile (std::vector<int> v, const std::string& filename){
  std::ofstream file;
  file.open (filename);
  for (auto const & x : v) {
    file << " " << x << "\n";
  }
  file.close();
} 

std::vector<std::vector<int>> readCandidatesFromFile () {
  std::ifstream file("../candidates/original-candidates.txt");
  std::vector<std::vector<int>> cands = {};
  std::string line;
  int a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26;
  char c;
  while (std::getline(file, line)) {
    std::istringstream iss(line);
    if (!(iss >> a >> c >> a0 >> a1 >> a2 >> a3 >> a4 >> a5 >> a6 >> a7 >> a8 >> a9 >> a10 >> a11 >> a12 >> a13 >> a14 >> a15 >> a16 >> a17 >> a18 >> a19 >> a20 >> a21 >> a22 >> a23 >> a24 >> a25 >> a26)) { break; } // error 
    std::vector<int> parsedLine = {a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26};
    cands.push_back(parsedLine);
  }
  return cands;
}


std::ostream& operator<<(std::ostream& os, const LineIncidence& li )
{
  auto s = li.mPoints.to_string('-', 'o'); 
  std::reverse(s.begin(),s.end()); 
  os << s.substr(0,li.nPoints);
  return os;
}

std::ostream& operator<<(std::ostream& os, const IncidenceMatrix & im)
{
  os << "# points = " << im.nPoints << '\n';
  for(int l=0; l<im.mLines.size(); ++l) {
    os << im.mLines[l] << " " << l << '\n';
  }
  return os;
}

IncidenceMatrix::IncidenceMatrix(const Arrangement3D& h) : IncidenceMatrix(h.nP(),h.nL()) 
{
  int currentLine = h.nFL();
  int currentPoint = h.nPwithXpins(0);
  for (int x = 1; x <= h.maxPins(); ++x) 
	 for (int p = 0; p < h.nPwithXpins(x); ++p, ++currentPoint) 
	   for (int l = 0; l < x; ++l) 
	     pointOn(currentPoint,currentLine++);
       for (int i=0; i<nPoints; ++i)
	 for (int j=i+1; j<nPoints; ++j) {
	    pointOn(i,currentLine);
	    pointOn(j,currentLine++);
	 }	   
}

bool PL1P::occludeInPlace(int c, std::vector<int> pp, std::vector<int> ll) {
  for (auto const & p : pp) { 
    camera(c).occludePoint(p);
  } 
  for (auto const & l : ll)    
    camera(c).occludeLine(l); 
  return true;
}

int sum(std::vector<int> v) {
  int sum_of_elems = 0;
  for (auto& n : v)
    sum_of_elems += n;
  return sum_of_elems;
}

std::vector<int> nPointsWithPins(const IntSol& sol) {
  std::vector<int> result = {sol.nP00() + sum(sol.nP02()), sol.nP10() + sum(sol.nP11()) + sum(sol.nP12()) + sum(sol.nP13()), sol.nP20() + sum(sol.nP24()), sol.nP3(), sol.nP4(), sol.nP5(), sol.nP6(), sol.nP7()};
//cut of zeros at the end
  int pos = result.size();
  for (int i = result.size()-1; i >= 0; --i){
    if (result[i] == 0) {
	pos = pos-1;
    } else {
	i = -1;
    }
  }
  result.erase(result.begin()+pos,result.end());
  return result;
}


std::vector<std::vector<int>> occlusions(const IntSol& sol) {
  std::vector<std::vector<int>> occlPts = {{},{},{}};
  std::vector<std::vector<int>> occlLns = {{},{},{}};
//free lines are never occluded
  int currentLine = sol.nF();
  int currentPoint = sol.nP00();

  for (int cam = 0; cam < 3; ++cam) {
    for (int n = 0; n < sol.nP02()[cam]; ++n) {
	occlPts[cam].push_back(currentPoint);
	currentPoint = currentPoint+1;
    }
  }

  currentPoint = currentPoint+sol.nP10();
  currentLine = currentLine+sol.nP10();

  currentLine = currentLine+sum(sol.nP11());
  for (int cam = 0; cam < 3; ++cam) {
    for (int n = 0; n < sol.nP11()[cam]; ++n) {
	occlPts[cam].push_back(currentPoint);
	currentPoint = currentPoint+1;
    }
  }

  int count = 0;
  for (int camP = 0; camP < 3; ++camP) {
    for (int camL = 0; camL < 3; ++camL) {
      if (camP != camL) {
	for (int n = 0; n < sol.nP12()[count]; ++n){
	  occlPts[camP].push_back(currentPoint);
	  currentPoint = currentPoint+1;
	  occlLns[camL].push_back(currentLine);
	  currentLine = currentLine+1;
	}
	count = count+1;
      }
    }
  }

  for (int cam = 0; cam < 3; ++cam) {
    for (int n = 0; n < sol.nP13()[cam]; ++n) {
      occlLns[cam].push_back(currentLine);
      for (int otherCam = 0; otherCam < 3; ++otherCam) {
	if (otherCam != cam) {
	  occlPts[otherCam].push_back(currentPoint);
	}
      }
      currentPoint = currentPoint+1;
      currentLine = currentLine+1;
    }
  }

  currentPoint = currentPoint+sol.nP20();
  currentLine = currentLine+2*sol.nP20();

  for (int cam = 0; cam < 3; ++cam) {
    for (int n = 0; n < sol.nP24()[cam]; ++n) {
      for (int otherCam = 0; otherCam < 3; ++otherCam) {
	if (otherCam != cam) {
	  occlPts[otherCam].push_back(currentPoint);
	  occlLns[otherCam].push_back(currentLine);
	  currentLine = currentLine+1;
	}
      }
      currentPoint = currentPoint+1;
    }
  }  

  occlPts.insert(occlPts.end(), occlLns.begin(), occlLns.end());
  return occlPts;
}

PL1P createMinimalReducedCandidate(std::vector<int> ints) {
  IntSol sol(ints);
  Arrangement3D arr(sol.nF(), nPointsWithPins(sol));
  PL1P plp(3,arr);
  std::vector<std::vector<int>> occl = occlusions(sol);
  for (int i = 0; i < 3; ++i) {
    plp.occludeInPlace(i, occl[i], occl[i+3]);
  }
  return plp;
}

void printVector(std::vector<int> v, std::ostream& f) {
  if (v.size() == 0) f << "{}"; 
  else {
    f << "{";
    for (int i = 0; i < v.size()-1; ++i) {
      f << v[i] << ",";
    }  
    f << v[v.size()-1];
    f << "}";
  }
}

void printBitset(std::bitset<MAX_N_LINES> v, int limit, std::ostream& f) {
  if (limit > v.size()) std::cout << "printBitset: wrong limit!";
  else {
    f << "{";
    for (int i = 0; i < limit-1; ++i) {
      f << v[i] << ",";
    }  
    if (limit > 0) 
      f << v[limit-1];
    f << "}";
  }
}

void printBitset(std::bitset<MAX_N_POINTS> v, int limit, std::ostream& f) {
  if (limit > v.size()) std::cout << "printBitset: wrong limit!"; 
  else {
    f << "{";
    for (int i = 0; i < limit-1; ++i) {
      f << v[i] << ",";
    }  
    if (limit > 0) 
      f << v[limit-1];
    f << "}";
  }
}

void parseToM2(PL1P plp, std::ostream& f) {
  std::vector<int> incidences3D = {};
  for (int i = 0; i < plp.nFL(); ++i) {
    incidences3D.push_back(-1);
  }
  int currentPoint = plp.nPwithXpins(0);
  for (int x = 1; x <= plp.maxPins(); ++x) {
    for (int p = 0; p < plp.nPwithXpins(x); ++p, ++currentPoint) {
      for (int i = 0; i < x; ++i) {
        incidences3D.push_back(currentPoint);
      }
    }
  }

  f << "{\n  ";
  printVector(incidences3D, f);
  f << ",\n  {\n    {";
  printBitset(plp.camera(0).lines, plp.nL(), f);
  f << ",";
  printBitset(plp.camera(0).points, plp.nP(), f);
  f << "},\n    {";
  printBitset(plp.camera(1).lines, plp.nL(), f);
  f << ",";
  printBitset(plp.camera(1).points, plp.nP(), f);
  f << "},\n    {";
  printBitset(plp.camera(2).lines, plp.nL(), f);
  f << ",";
  printBitset(plp.camera(2).points, plp.nP(), f);
  f << "}\n  }\n}\n";

}

std::ostream& operator<<(std::ostream& os, const PL1P & plp) {
  os << "# cameras = " << plp.nCameras << '\n';
  IncidenceMatrix im(plp.graph);
  os << im;
  for(int c=0; c<plp.nCameras; ++c) {
    auto sP = plp.cameras[c].points.to_string('x', '.'); 
    std::reverse(sP.begin(),sP.end()); 
    auto sL = plp.cameras[c].lines.to_string('x', '.'); 
    std::reverse(sL.begin(),sL.end()); 
    os << c << " sees points ";
    os << sP.substr(0,plp.graph.nP());
    os << " sees lines ";
    os << sL.substr(0,plp.graph.nL());
    os << '\n';
  }
  /*
    std::vector<IncidenceMatrix> im(plp.nCameras,IncidenceMatrix(plp.graph));
  for(int c=0; c<plp.nCameras; ++c) 
    occludePoint ...
  os << "# points = " << plp.graph.nP() << '\n';
  for(int l=0; l<im.mLines.size(); ++l) {
    for(int c=0; c<plp.nCameras; ++c) 
      if (plp.isVisibleLine(c,l))
	os << im.mLines[l] << " "; 
    os << " " << l << '\n';
    }*/
  return os;
}

std::vector<int> indicesOfCompleteVisibilityCandidates(std::vector<std::vector<int>> candidates) {
  std::vector<int> result = {};
  std::vector<int> c;
  for (int i = 0; i<candidates.size(); ++i) {
    c = candidates[i];
    if (c[8]==0 && c[9]==0 && c[10]==0 && c[12]==0 && c[13]==0 && c[14]==0 && c[15]==0 && c[16]==0 && c[17]==0 && c[18]==0 && c[19]==0 && c[20]==0 && c[21]==0 && c[22]==0 && c[23]==0 && c[24]==0 && c[25]==0 && c[26]==0)
      result.push_back(i);
  }
  return result;
}


std::vector<int> indicedOfProblemWithoutIncidences(std::vector<std::vector<int>> candidates) {
  std::vector<int> result = {};
  std::vector<int> c;
  for (int i = 0; i<candidates.size(); ++i) {
    c = candidates[i];
    if (c[0]==0 && c[1]==0 && c[2]==0 && c[3]==0 && c[4]==0 && c[5]==0 && c[6]==0 && c[8]==0 && c[9]==0 && c[10]==0 && c[12]==0 && c[13]==0 && c[14]==0 && c[15]==0 && c[16]==0 && c[17]==0 && c[21]==0 && c[22]==0 && c[23]==0 && c[24]==0 && c[25]==0 && c[26]==0)
      result.push_back(i);
  }
  return result;
}

std::vector<int> indicesOfProblemWithoutAtMostOnePinPerPoint(std::vector<std::vector<int>> candidates) {
  std::vector<int> result = {};
  std::vector<int> c;
  for (int i = 0; i<candidates.size(); ++i) {
    c = candidates[i];
    if (c[0]==0 && c[1]==0 && c[2]==0 && c[3]==0 && c[4]==0 && c[5]==0 && c[24]==0 && c[25]==0 && c[26]==0)
      result.push_back(i);
  }
  return result;
}

std::vector<int> excludeCommonCameraminimalProblems(std::vector<std::vector<int>> candidates) {
  std::vector<int> result = {};
  std::vector<int> c;
  for (int i = 0; i<candidates.size(); ++i) {
    c = candidates[i];
    if (c[13]==0 && c[15]==0 && c[17]==0)
      result.push_back(i);
  }
  return result;
}

int findIndexOfCandidate(std::vector<int> c, std::vector<std::vector<int>> candidates) {
//returns -1 is "c" not present in the list "candidates"
  for (int i=0; i<candidates.size(); ++i) {
    if (c == candidates[i]) return i;
  }
  return -1;
}

bool isContained(std::vector<int> c, std::vector<std::vector<int>> L) {
  for (int i = 0; i < L.size(); ++i) {
    if (c == L[i]) return true;
  }
  return false;
}

bool isStrictlySmallerThan(std::vector<int> x, std::vector<int> y) {
  for (int i = 0; i < x.size(); ++i){
    if (x[i] > y[i]) return true;
    if (x[i] < y[i]) return false;
  }
  return false;
}
/*  swap(v)
    INPUT: 
      -) vector<int> v = (v1, ... , vl)
    OUTPUT: 
      -) vector<int> c = (c1, ..., cl)
         the lexicographically-largest vector obtainable by a single 'swap' from v
*/
std::vector<int> swap(std::vector<int> v){
  std::vector<int> c = v;
  c[12] = c[12]+c[13];
  c[14] = c[14]+c[15];
  c[16] = c[16]+c[17];
  c[13] = 0;
  c[15] = 0;
  c[17] = 0;
  return c;
}


std::vector<int> pivot(std::vector<int> c) {
//swap operation
  c[12] = c[12]+c[13];
  c[14] = c[14]+c[15];
  c[16] = c[16]+c[17];
  c[13] = 0;
  c[15] = 0;
  c[17] = 0;
//find best permutation
  std::vector<int> bestPerm = c;
  c = rotateSolution(c);
  if (isStrictlySmallerThan(c,bestPerm)) bestPerm = c;
  c = rotateSolution(c);
  if (isStrictlySmallerThan(c,bestPerm)) bestPerm = c;
  c = reflectSolution(c);
  if (isStrictlySmallerThan(c,bestPerm)) bestPerm = c;
  c = rotateSolution(c);
  if (isStrictlySmallerThan(c,bestPerm)) bestPerm = c;
  c = rotateSolution(c);
  if (isStrictlySmallerThan(c,bestPerm)) bestPerm = c;
  return bestPerm;
}

int findUniqueSwapPartner(int index, std::vector<std::vector<int>> candidates){
  std::vector<int> c = candidates[index];
  while(c[13]!=0 || c[15]!=0 || c[17]!=0) {
    c = pivot(c);
  }
  int finalIndex = findIndexOfCandidate(c,candidates);
//  if (finalIndex >= 0) return 1;
//  else return 0;
  return finalIndex;
}

// input: the index of a candidate and the vector of candidates processed by filter 3
// output: the indices of that candidate and the elements of its S_3 orbit in the candidate vector
std::vector<int> findEquivalentProblems(int startindex, std::vector<std::vector<int>> candidates){
//input: startindex in candidates.txt of a pl1p in swapCandidates.txt
  std::vector<int> c = candidates[startindex];
  int index = 0;
  std::vector<std::vector<int>> partners = {};
  std::vector<int> partnerIndices = {};
  partners.push_back(c);
  //test all permutations
  // each time we find a new "partner", record 
  c = swap(rotateSolution(c));

  if (!isContained(c,partners)) {
    index = findIndexOfCandidate(c,candidates);
    if (index >= 0) {
    partners.push_back(c);
    partnerIndices.push_back(index);
  }
  }
  c = swap(rotateSolution(c));
  if (!isContained(c,partners)) {
    index = findIndexOfCandidate(c,candidates);
    if (index >= 0) {
    partners.push_back(c);
    partnerIndices.push_back(index);
  }
  }
  c = swap(reflectSolution(c));
  if (!isContained(c,partners)) {
    index = findIndexOfCandidate(c,candidates);
    if (index >= 0) {
    partners.push_back(c);
    partnerIndices.push_back(index);
  }
  }
  c = swap(rotateSolution(c));
  if (!isContained(c,partners)) {
    index = findIndexOfCandidate(c,candidates);
    if (index >= 0) {
    partners.push_back(c);
    partnerIndices.push_back(index);
  }
  }
  c = swap(rotateSolution(c));
  if (!isContained(c,partners)) {
    index = findIndexOfCandidate(c,candidates);
    if (index >= 0) {
    partners.push_back(c);
    partnerIndices.push_back(index);
  }
  }
  return partnerIndices;
}

std::vector<int> listComplement(std::vector<int> L, int maxNumber) {
  std::vector<int> result = {};
  int listSize = L.size();
  int index = 0;
  for (int count=0; count<maxNumber; ++count) {
    if (index < listSize) {
      if (L[index] == count)
        index++;
      else 
	result.push_back(count);
    }
    else result.push_back(count);
  }
  return result;
}

std::vector<int> indicesOfJoesCandidates(std::vector<std::vector<int>> candidates) {
  std::vector<int> result = {};
  std::vector<int> c;
  for (int i = 0; i<candidates.size(); ++i) {
    c = candidates[i];
    if (c[0]==0 && c[1]==0 && c[2]==0 && c[3]==0 && c[4]==0 && c[5]==0 && c[6]==0 && c[8]==0 && c[9]==0 && c[10]==0 && c[18]==0 && c[19]==0 && c[20]==0 && c[24]==0 && c[25]==0 && c[26]==0 && c[21]==0 && c[22]==0 && c[16]==0 && c[17]==0)
      result.push_back(i);
    if (c[0]==0 && c[1]==0 && c[2]==0 && c[3]==0 && c[4]==0 && c[5]==0 && c[6]==0 && c[8]==0 && c[9]==0 && c[10]==0 && c[18]==0 && c[19]==0 && c[20]==0 && c[24]==0 && c[25]==0 && c[26]==0 && c[23]==0 && c[22]==0 && c[16]==0 && c[17]==0 && c[12]==0 && c[13]==0 && c[14]==0 && c[15]==0)
      result.push_back(i);
  }
  return result;
}

std::vector<int> joesNotation(std::vector<int> candidate) {
//PPP,LPP,PLP,LLL,LLP
  int ppp = candidate[7];
  int lll = candidate[11];
  int llp = candidate[23] + candidate[21];
  int lpp = candidate[12] + candidate[13];
  int plp = candidate[14] + candidate[15];
  return  {ppp,lpp,plp,lll,llp};
}

std::vector<std::vector<int>> findRepresentativesForJoesProblems (std::vector<std::vector<int>> candidates, std::vector<int> indices) {
  std::vector<std::vector<int>> foundProblems = {};
  std::vector<std::vector<int>> result = {};
  std::vector<int> n;
  std::vector<std::vector<int>>::iterator p;
  std::vector<int>::iterator it;
  for (int i = 0; i<indices.size(); ++i) {
    n = joesNotation(candidates[indices[i]]);    
    p = std::find(foundProblems.begin(), foundProblems.end(), n);
    if (p == foundProblems.end()) {
      foundProblems.push_back(n);
      it = n.begin();
      n.insert(it, indices[i]);
      result.push_back(n);
    }
  }
  return result;
}

int main()
{

/*
  THIS COMPUTES THE LIST OF ALL 143,494 CANIDATES.
  THIS COMPUTATION TAKES A FEW HOURS!

  std::vector<std::vector<int>> sols = listMinimalReducedCandidates();
  std::cout << "Number of candidates: " << sols.size();    
  printToFile(sols);
*/

  std::vector<std::vector<int>> candidates = readCandidatesFromFile();
//  std::cout << candidates.size() << "\n";

std::vector<int> ints = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0};
//  std::vector<int> ints = candidates[366];


  std::vector<int> indicesOfLessCandidates = excludeCommonCameraminimalProblems(candidates);
  printIndicesToFile(indicesOfLessCandidates, "../candidates/swapCandidates.txt");
//  std::vector<int> excludedCandidates = listComplement(indicesOfLessCandidates,candidates.size());
//  printIndicesToFile(excludedCandidates, "excludedCandidates.txt");
  
std::vector<int> partners = {};
int index = 0;
bool isRemoved = false;
std::set<int> setOfRemovedCandidates;
int minInds = 0;
int maxInds = indicesOfLessCandidates.size();
for (int i = minInds; i < maxInds; ++i){
  index = indicesOfLessCandidates[i];
  isRemoved = setOfRemovedCandidates.find(index) != setOfRemovedCandidates.end();
  if (!isRemoved) {
      partners = findEquivalentProblems(index,candidates);
      for(int j = 0; j<partners.size(); ++j){
	setOfRemovedCandidates.insert(partners[j]);
	std::cout << index << " : " << partners[j] << "\n";
      }
  }
}
//to be substracted from swapCandidates.txt
std::vector<int> vectorOfRemovedCandidates(setOfRemovedCandidates.begin(), setOfRemovedCandidates.end());
printIndicesToFile(vectorOfRemovedCandidates, "../candidates/extraRemovedCandidates.txt");
}

