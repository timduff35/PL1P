#include "pl1p.hpp" 
#include <stdio.h>
#include <sys/stat.h>

int main()
{
  char dir[10];
  std::vector<std::vector<int>> candidates = readCandidatesFromFile();
  for (int i=0; i<candidates.size(); ++i) {
    if (i%1000==0) {
      sprintf(dir, "%03d", i/1000);
      mkdir(dir,S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    }
    std::string filename = std::string(dir) + "/" + std::to_string(i) + ".pl1p";
    std::ifstream file_to_check(filename);
    bool exists = file_to_check.is_open();
    file_to_check.close();
    if (not exists) { 
      std::ofstream file;
      file.open(filename);
      file << "new HashTable from {\n";
      file << "\"signature\" => ";
      printVector(candidates[i], file);
      file << ",\n";
      file << "\"pl1p\" => ";
      parseToM2(createMinimalReducedCandidate(candidates[i]), file);
      file << "}\n";
      file.close();
    }
  }
  return 0;
}
