needs "./pl1p-basics/service-functions.m2"
needs "./pl1p-basics/tikzPL1P.m2"
needs "./degree-computation/runMonodromy.m2"

-*
 An initial rank-check of all ~143k problems (taking ~1 week) flagged 5707 of the 143494 candidate problems as non-minimal.
 The script run-checkRank.sh at top-level can be used to produce these records.
 Due to randomization and changing implementations, it is unlikely that the original result of the initial rank-check can be reproduced.
 However, reproducing the final tallies of Result 8 should not depend on the randomness.
 Several of the "false" cases above were "false-negatives", due to non-generic data over the chosen prime field.
 These were easy to filter out after a few more runs of the rank-check.
*-
load "./examples/false-negatives";
f = openOut "candidates/min.txt"
tally for k from 0 to 143493 list (
    (dimDomain, dimCodomain, dimImage) := last (getRecord k)#"rank check";
    assert areEqual(dimDomain, dimCodomain);
    isMinimal := areEqual(dimDomain, dimImage) or member(k, falseNegativeSet);
    if isMinimal then f << k << endl;
    isMinimal
    )
close f    

-- For degree computation, here is a specific example: the "Chicago problem", of degree 312.
ID=2394
tikzPL1P getPL1P ID
-- The next line assumes you can use the commands "evince" and "pdflatex" in a UNIX environment.
viewPL1P getPL1P ID

-*
Degree computation illustration.

We generate an "incomplete" monodromy run by truncating the number of solutions discovered at 300.
*-
setDefault(tStepMin=>1e-8)
setDefault(maxCorrSteps=>2)
elapsedTime runMonodromy(ID,"./",
    NumberOfEdges=>3,
    Target=>300,
    Verbose=>true,
    RandSeed => 0,
    ProblemDirectory=>"./problems/"
    )
-*
Example illustrating how to restart the previous run.
*-

runMonodromy(
    "./monodromy-result-pl1p-002394-target-0300", -- data from previous run
    ID, 
    Target=>500,
    RandSeed => 0,
    ProblemDirectory=>"./problems/"
    )


