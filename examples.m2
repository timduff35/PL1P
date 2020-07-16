restart
needs "./pl1p-basics/service-functions.m2"
--needs "./pl1p-basics/tikzPL1P.m2"
needs "./degree-computation/runMonodromy.m2"

setDefault(tStepMin=>1e-8)
setDefault(maxCorrSteps=>2)

-*
using only 2 edges, we generate an "incomplete" monodromy run
*-
ID=4
elapsedTime runMonodromy(ID,"./",
    NumberOfEdges=>2,
    Target=>300,
    Verbose=>true,
    RandSeed => 0,
--    FilterPost => false,
    ProblemDirectory=>"./problems/"
    )
-*
-- restarting the previous run.
-- _most_ of the same options supported by restarting
*-

runMonodromy(
    "./monodromy-result-pl1p-000004-target-0300", -- data from previous run
    ID, 
    Target=>500,
    RandSeed => 0,
    ProblemDirectory=>"./problems/"
    )
