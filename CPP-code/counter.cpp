#include <iostream>
#include <vector>
#include <math.h>

using namespace std;

//given non-negative integers n, a_0 >= ... >= a_k
//this lists all integer solutions (x_0,...,x_k)
//satisfying n = a_0 x_0 + ... + a_k x_k
vector<vector<int>> listIntSols(int n, vector<int> a) {
  vector<vector<int>> sols;
  if (n == 0) {
    sols = {vector<int>(a.size())};
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
      vector<vector<int>> partialSols;
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

int main () {
  vector<vector<int>> solutions;
//  vector<int> weights = {10,9,8,7,6,5,4,3,3,2,2,1,1,1};
  vector<int> weights = {10,9,8,7,6,5,4,3,3,3,3,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1};
  for (auto const & w : weights) {
    cout << w;
      };
  cout << endl;
  solutions = listIntSols(11,weights);
  int c = 0;
  for (auto const & s : solutions) {
    cout << c << " : ";
    c++;
    for (auto const & x : s)
      cout << x << " ";
    cout << endl;
  };

}
