restart
needs "./pl1p-basics/service-functions.m2"
needs "./pl1p-basics/tikzPL1P.m2"
needs "./degree-computation/runMonodromy.m2"

setDefault(tStepMin=>1e-8)
setDefault(maxCorrSteps=>2)

-- "Chicago problem", of degree 312.
ID=2394
tikzPL1P getPL1P ID
-- The next line assumes you can use the command "evince" in a UNIX environment.
viewPL1P getPL1P ID

-*
Using only 2 edges, we generate an "incomplete" monodromy run by truncating the number of solutions discovered at 300.
*-

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

