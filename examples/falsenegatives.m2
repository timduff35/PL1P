setRandomSeed 0
needs "../pl1p-basics/service-functions.m2"
needs "../pl1p-basics/tikzPL1P.m2"
needs "../problemBuilder/worldBuilder.m2"
elapsedTime M = for i from 0 to 143493 list (i, getRecord(i,ProblemDirectory=>"../problems/"));

negatives = select(M,(i, H)->(
	    pl1p := H#"pl1p";
	    rkChk := last H#"rank check";	    
	    isMinimal := (first rkChk == last rkChk);
	    not isMinimal
	    )
    	);
#negatives
badIDs = first \ negatives;
falseNegatives = {}
trueNegatives = {}
p = nextPrime 2020^2
lim=length badIDs
for ID in take(badIDs,lim) do (
    badPL1P := getPL1P(ID,"../problems/");
    elapsedTime (a,b,c) := rankCheck(badPL1P, ZZ/p);
    << (a | "," | b | ", " | c) << endl;
    if (a==c) then falseNegatives = append(falseNegatives, ID) else trueNegatives = append(trueNegatives, ID);
    )
#falseNegatives/lim
trueNegatives

p = nextPrime(2*2020^2)
lim=length trueNegatives
for ID in take(trueNegatives,lim) do (
    badPL1P := getPL1P(ID,"../problems/");
    elapsedTime (a,b,c) := rankCheck(badPL1P, ZZ/p);
    << (a | "," | b | ", " | c) << endl;
    if (a==c) then falseNegatives = append(falseNegatives, ID);
    )
#negatives-(#trueNegatives+#falseNegatives)

tally apply(trueNegatives,i->(
	H := last M#i;
	dims := last H#"rank check";
	first dims - last dims
	)
    )

f = openOut "negatives"
f << "trueNegativeSet = "
f << trueNegatives
close f

falseNegatives = set (first \ negatives) - set(trueNegatives)
f = openOut "false-negatives"
f << "falseNegativeSet = "
f << falseNegatives
close f
