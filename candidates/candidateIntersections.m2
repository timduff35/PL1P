needs "../pl1p-basics/service-functions.m2"
needs "../pl1p-basics/tikzPL1P.m2"

elapsedTime M = for i from 0 to 143493 list (i, getRecord(i,ProblemDirectory=>"../problems/"));

falseNegatives = value get "../examples/false-negatives";

minimalIndices = first \ select(M,(i, H)->(
	    pl1p := H#"pl1p";
	    rkChk := last H#"rank check";	    
	    worldLines := first pl1p;
	    lineCounts := new HashTable from tally worldLines;
	    isMinimal := (first rkChk == last rkChk) or member(i, falseNegatives);
    	    isMinimal
	    )
    	);

p1l1p = first \ select(M,(i, H)->(
	    pl1p := H#"pl1p";
	    rkChk := last H#"rank check";	    
	    worldLines := first pl1p;
	    lineCounts := new HashTable from tally worldLines;
	    isMinimal := (first rkChk == last rkChk) or member(i, falseNegatives);
	    isPractical := all(keys lineCounts, k -> k < 0 or lineCounts#k < 2);
    	    isMinimal and isPractical
	    )
    	);


-- swap candidates which are minimal
f = value \ lines get "swapCandidates.txt";
g = minimalIndices;
h = value \ lines get "./extraRemovedCandidates.txt";
elapsedTime F =set(f);
elapsedTime G =set(g);
H = set(h);
#F
#(F*G)
elapsedTime camMin = (F*G-H); -- ~ 400 s
P= set p1l1p;
#(F*P-H)


-*
j = value \ lines get "joe-problems"

# camMin
camMinFile = openOut "camMin.txt"
for c in camMin do camMinFile << c << endl
close camMinFile

needs "~/Downloads/problemlist-updated.m2"
elapsedTime plistNew =flatten apply(camMin,ID -> select(1, plist, p -> ID == first p));
#plistNew
*-

e = value \ lines get "excludedCandidates.txt";

f = openOut "minimalCands.txt"
for m in minimalIndices do f << m << endl
close f
