# Point-line minimal problems with partial visibility
# Code organization

## Dataset

* unpack `all-PL1Ps.tar.gz` into `/problems' and the Macaulay2 code should work
* problem indices relevant for various experiments are in `/candidates'
* data can be re-created by enumerating candidate problems in C++ (takes a few hours) and checking minimality for each problem with `run-checkRank.sh` (takes days.)

## Summary of `cpp-code/`
* pl1p.cpp : main function enumerates reduced, balanced problems with the procedure described in the supplementary
* create-records.cpp : creates directories 000, 001, etc. and populates them with records to process
 
Compile (e.g.)
```g++ -std=c++11 pl1p.cpp create-records.cpp -o ../go```

## M2 basic PL1P code is in `pl1p-basics`
* service functions: e.g., exctract info from the pl1p encoding
* tikz: produce graphs for pl1p, e.g. viewPL1P lets one view a PDF of it 
 
## M2 Problem Builders
* have their own subdirectory
* rank check implemented in "worldBuilder.m2"
* degree implemented in "worldBuilder.m2" and "eliminatedBuilder.m2"
* to check that all is working: run `examples.m2`
