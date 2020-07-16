needs "../pl1p-basics/service-functions.m2"
needs "../pl1p-basics/tikzPL1P.m2"
needs "../degree-computation/runMonodromy.m2"
setDefault(tStepMin=>1e-8)
setDefault(maxCorrSteps=>2)

elapsedTime M = for i from 0 to 143493 list (i, getRecord(i,ProblemDirectory=>"../problems/"));

falseNegatives = value get "false-negatives"

practical = select(M,(i, H)->(
	    pl1p := H#"pl1p";
	    rkChk := last H#"rank check";	    
	    worldLines := first pl1p;
	    lineCounts := new HashTable from tally worldLines;
	    isMinimal := (first rkChk == last rkChk) or member(i, falseNegatives);
	    isPractical := all(keys lineCounts, k -> k < 0 or lineCounts#k < 2);
    	    isMinimal and isPractical
	    )
    	);
#practical
practicalIDs = first \ practical;
joes = apply(lines get "./joe-problems",s->value first separate(" ",s))
bad = select(joes,joeID->not member(joeID,practicalIDs))
badPL1P = getPL1P(first bad, "../problems/")
viewPL1P badPL1P -- 4LLL, 3PLL
needs "../problemBuilder/worldBuilder.m2"
rankCheck(badPL1P, ZZ/nextPrime 2020)


pl0ps = select(M,(i, H)->(
	    pl1p := H#"pl1p";
	    rkChk := last H#"rank check";	    
	    worldLines := first pl1p;
	    lineCounts := new HashTable from tally worldLines;
	    isMinimal := (first rkChk == last rkChk) or member(i, falseNegatives);
	    isPL0P := all(keys lineCounts, k -> k < 0 or lineCounts#k < 1);
    	    isMinimal and isPL0P
	    )
    	);
#pl0ps
pl0pIDs = first \ pl0ps;

-*
-- one day this will work
collectStats = pl1p -> (
    (world,views) = (first pl1p, last pl1p);
    nLines := #world;
    nFree := position(first pl1p,p->p>-1);
    if instance(nFree,Nothing) then nFree = 0;
    nPts := #last first views;
    T := tally first pl1p;
    worldPinCount := sum T; -- wrong if some lines are free
    viewPinCount := sum((last pl1p)/(v->sum last v)); -- wrong if some lines are free
    lnMatchCount := sum for i from 0 to nLines-1 list (
	(a,b,c):=(views#0#0#i,views#1#0#i,views#2#0#i);
	s := a+b+c;
	val := if s==1 then 3 else if s==2 then 2 else 1;
	val 
	);
    ptMatchCount := sum for i from 0 to nPts-1 list (
	(a,b,c)=(views#0#1#i,views#1#1#i,views#2#1#i);
	s := a+b+c;
	val := if s==1 then 3 else if s==2 then 2 else 1;
	val
	);
    completePtMatchCount := sum for i from 0 to nPts-1 list (
	(a,b,c)=(views#0#1#i,views#1#1#i,views#2#1#i);
	s := a+b+c;
	val := if s==3 then 1 else 0;
	val
	);
    toList (nLines,nFree,nPts,worldPinCount,viewPinCount,lnMatchCount,ptMatchCount,completePtMatchCount)
    )
