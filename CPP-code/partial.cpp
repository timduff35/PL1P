#include "partial.hpp"

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

IncidenceMatrix::IncidenceMatrix(const HairyClique& h) : IncidenceMatrix(h.nP(),h.nL()) 
{
  int currentLine = h.nFL();
  int currentPoint = h.nPwithXpins(0);
  for (int x = 1; x < h.maxPins(); ++x) 
	 for (int p = 0; p < h.nPwithXpins(x); ++p, ++currentPoint) 
	   for (int l = 0; l < x; ++l) 
	     pointOn(currentPoint,currentLine++);
       for (int i=0; i<nPoints; ++i)
	 for (int j=i+1; j<nPoints; ++j) {
	    pointOn(i,currentLine);
	    pointOn(j,currentLine++);
	 }	   
}

bool PLP::occludeInPlace(int c, std::vector<int> pp, std::vector<int> ll) {
  // test if occlusion is legit
  // return true: occlusion is performed in place 
  // returns false: the state of PLP is undefined
  for (auto const & p : pp) { 
    // std::cout << "occluding " << p <<  " in  camera " << c << '\n';
    camera(c).occludePoint(p);
  } 
  for (auto const & l : ll)    
    camera(c).occludeLine(l); 
  return true;
}

std::ostream& operator<<(std::ostream& os, const PLP & plp) {
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

int main()
{
  std::vector<int> pointsWithXpins = {2,3,0,1}; 
  HairyClique h(2,pointsWithXpins);
  IncidenceMatrix im(h);
  std::cout << im;

  PLP plp(3,h);
  std::cout << "created plp\n";

  plp.occludeInPlace(0,{1,2,3},{2,4,6,20});
  plp.occludeInPlace(1,{2,4,5},{1,2,4,6});
  plp.occludeInPlace(2,{3,4,5},{12,14,16});
  std::cout << plp;

  return 0;	
}
