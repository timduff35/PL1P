needs "../pl1p-basics/service-functions.m2"
needs "../pl1p-basics/tikzPL1P.m2"
setDefault(tStepMin=>1e-8)
setDefault(maxCorrSteps=>2)
needs "../degree-computation/runMonodromy.m2"
joes = apply(lines get "./joe-problems",s->value first separate(" ",s))
for ID in joes do elapsedTime runMonodromy(ID,"./",
--    Target=>250, 
    ProblemDirectory=>"../problems/"
    )
