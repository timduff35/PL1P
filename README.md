Data and Code accompanying the article [Point-line minimal problems with partial visibility](https://www.ecva.net/papers/eccv_2020/papers_ECCV/papers/123710171.pdf) (Duff, Kohn, Leykin Pajdla, ECCV 2020.)

# Data 

## Summary of Data

1.  One 11 MB tar file [all-PL1Ps.tar.gz](https://github.com/timduff35/PL1P/blob/master/all-PL1Ps.tar.gz) containing the results of an initial rank check, produced by the script [run-checkRank.sh](https://github.com/timduff35/PL1P/blob/master/run-checkRank.sh)
2.  Problem indices relevant for various experiments are in the subdirectory `/candidates'. For example, Result 8 in the paper refers to the [74545 problem indices here](https://github.com/timduff35/PL1P/tree/master/candidates/camMin.txt) and the [140616 problem indices here](https://github.com/timduff35/PL1P/tree/master/candidates/min.txt).
3. Data produced for degree computations were saved on CIIRC CTU cluster. See [examples.m2](https://github.com/timduff35/PL1P/blob/master/examples.m2) for an example, including syntax for re-starting computations.


## Getting started

First, clone the repository, then unpack `all-PL1Ps.tar.gz` into the subdirectory `/problems'.
```
mkdir pl1p
git clone git@github.com:timduff35/PL1P.git pl1p
cd pl1p/problems
tar -xvf ../all-PL1Ps.tar.gz
```

The last line, which may take a minute or two, populates 144 subdirectories of the directory problems.
These subdirectories are named 000/, 001/, ..., 143/.
Directories 000 through 142 contain 100 "problem files" each.
Directory 143 contains 94 problem files.
This gives a grand total of 143494 candidates for the reduced minimal problems, as described in Section 7 of the paper.

A problem file "ABC.pl1p" in directory "DEF/" corresponds to a problem ID "ABCDEF" in the indical data described above.

## Example problem file

The example below, derived from the file `7.pl1p', records a Macaulay2 hash table with the results of the rank check for that problem, and an encoding of the points, lines, and their incidences.

```
new HashTable from {"rank check" => new Time from {.31927930930000001p53e1,(34,34,34)}, "signature" => {0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0}, "pl1p" => {{1,2,2,2,2,2,2},{{{0,1,1,1,1,1,1},{0,1,1}},{{1,1,1,1,1,1,1},{1,0,1}},{{1,1,1,1,1,1,1},{1,0,1}}}}}
```

Various pieces of Macaulay2 code should now work.
See [examples.m2](https://github.com/timduff35/PL1P/blob/master/examples.m2) for justification of various problem counts appearing in Section 7 of the paper.

# Code

## Reproducing results

The C++ code that generates problem candidates should only take a few hours on a laptop.
The [shell script](https://github.com/timduff35/PL1P/blob/master/run-checkRank.sh) that generated the initial rank check data took several days the last time it was run.

## Summary of `cpp-code/`
* pl1p.cpp : main function enumerates reduced, balanced problems with the procedure described in the supplementary
* create-records.cpp : creates directories 000, 001, etc. and populates them with records to process
 
Compile command
```g++ -std=c++11 pl1p.cpp create-records.cpp -o ../go```

## M2 basic PL1P code is in `pl1p-basics`
* service functions: e.g., exctract info from the pl1p encoding
* tikz: produce graphs for pl1p, e.g. viewPL1P lets one view a PDF of it 
 
## M2 Problem Builders
* have their own subdirectory
* rank check implemented in "worldBuilder.m2"
* degree implemented in "worldBuilder.m2" and "eliminatedBuilder.m2"
* to check that all is working: run `examples.m2`
