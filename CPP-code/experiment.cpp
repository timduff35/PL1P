#include "pl1p.hpp" 
int main()
{
/*
  THIS COMPUTES THE LIST OF ALL 143,494 CANIDATES.
  THIS COMPUTATION TAKES A FEW HOURS!

  std::vector<std::vector<int>> sols = listMinimalReducedCandidates();
  std::cout << "Number of candidates: " << sols.size();    
  printToFile(sols);
*/

/*
  std::vector<std::vector<int>> candidates = readCandidatesFromFile();
  std::cout << candidates.size() << "\n";

//std::vector<int> ints = {1,0,0,0,0,2,0,5,0,0,0,2,1,1,0,3,0,0,0,2,3,0,2,0,0,0,3};
  std::vector<int> ints = candidates[42];
  std::cout << "candidate:";
  for (auto const & n : ints)
	std::cout << " " << n;
  std::cout << "\n";
  PL1P plp = createMinimalReducedCandidate(ints);
  std::cout << plp;
  parseToM2(plp);
*/
  
 std::vector<std::vector<int>> candidates = readCandidatesFromFile();
 for (int i=0; i<candidates.size(); ++i) {
   if (i%100 == 0) std::cout << "\n" << i/100 << " : ";
   if (i%10 == 0) std::cout << i%100 / 10;
   else std::cout << ".";
   std::cout << std::flush;
   parseToM2(createMinimalReducedCandidate(candidates[i]),null_stream);
 }
 return 0;
}
