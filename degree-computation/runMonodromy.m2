needs "../pl1p-basics/tikzPL1P.m2"
needs "../problemBuilder/worldBuilder.m2"
needs "../problemBuilder/eliminatedBuilder.m2"
needs "../problemBuilder/common.m2"
debug needsPackage "MonodromySolver"

MONODROMYOPTIONS = new OptionTable from {
    -- "null" typically indicates default monodromySolver option
	Formulation=>"eliminated",
	Verbose=>false,
	Target=>infinity,
	ProblemDirectory=>"../problems/",
	BatchSize => infinity,
	NumberOfRepeats=>10,
	SquaringAttempts=>3,
	NumberOfEdges=>4,
	NumberOfNodes=>2,
	FilterBatch=>false,
	FilterPost=>true,
	FilterRankTol=>5e-3,
	RandSeed=>null
	}


-- endpoint randomization for world formulation
gammifyWorld = method()
gammifyWorld Point := p -> gammify(matrix p)
gammifyWorld Matrix := p -> (
    if numrows matrix p == 1 then p = transpose p;
    n := sub((numrows matrix p)/2,ZZ);
    D := diagonalMatrix(for i from 1 to n list random CC);
    (D*p^{0..n-1}) || (D*p^{n..2*n-1})
    )

-- endpoint randomization for eliminated formulation
gammifyElim = (y, Dpl1p) -> (
    indGammas := for v from 0 to 2 list new HashTable from apply((getIndepLines Dpl1p)#v, l -> l=>random CC);
    indDiagEntries := apply(indGammas,g->flatten apply(sort keys g, k -> toList(3:(g#k))));
    depDiagEntries := for v from 0 to 2 list flatten apply((getDepLines Dpl1p)#v, l -> {conjugate indGammas#v#(l#1#0),conjugate indGammas#v#(l#1#1)});
    lineDiag := flatten(indDiagEntries)|flatten(depDiagEntries)|flatten flatten for i from 1 to #flatten getGhosts Dpl1p list toList(3:random CC);
    tChartdiag := toList((3*(m-1)+1):random(CC)); -- t chart gamma
    qChartDiags := flatten for i from 0 to m-2 list toList(5:random(CC));
    y' := diagonalMatrix(lineDiag|tChartdiag|qChartDiags)*colshape y;
    y'
    )

-- main function for computing degrees    
-- returns either a HomotopyGraph or false (indicating failure to squareDown)
degreePL1P = method(Options=>MONODROMYOPTIONS)
degreePL1P ZZ := o -> n -> (
    pl1p := getPL1P(n,o.ProblemDirectory);
    (GS, p0, sols) := (
	if (o.Formulation == "world") then makePhiGraphFamily(pl1p,CC_53) 
	else if (o.Formulation == "eliminated") then (
	    (F, y0, c0, Dpl1p, cameraMatrixEvaluators, CoLmatrices, CoPmatrices) := eliminatedBuilder(pl1p, CC_53);
	    squared := false;
	    attempts := 0;
	    while (not squared and attempts < o.SquaringAttempts) do (
	    	F' := squareDown(y0, c0, F, Verbose=>o.Verbose);
	    	squared = (14 == numFunctions F');
		if not squared then (y0, c0) = fabricateYC(Dpl1p, CC_53, cameraMatrixEvaluators);
		attempts = attempts + 1;
		);
	    if squared then (F', y0, {c0}) else (F, y0, {c0})
	    )
    else error "formulation key not recognized"
    );
    FILTER := if (o.Formulation == "world" or (o.FilterBatch or o.FilterPost) == false) then null else (
	-- matrix evaluators: used for rank filter
	inputMatrix := (vars F) | (parameters F);
	PE := apply(#CoPmatrices,i->(
		G := CoPmatrices#i;
		(makeSLProgram(inputMatrix,G),
		    mutableMatrix(CC_53,numrows G,numcols G)
		    )
    		)
	    );
	LE := apply(#CoLmatrices,i->(
		G := CoLmatrices#i;
		(makeSLProgram(inputMatrix,G),
		    mutableMatrix(CC_53,numrows G,numcols G)
		    )
    		)
	    );
	ranks := (x, p) -> (
    	    a := PE/( m -> (
	    	    evaluate(first m, mutableMatrix(x||p), last m);
	    	    numericalRank(matrix last m, Threshold=> o.FilterRankTol)
	    	    )
	    	);
    	    b := LE/( m -> (
	    	    evaluate(first m, mutableMatrix(x||p), last m);
	    	    numericalRank(matrix last m, Threshold => o.FilterRankTol)
	    	    )
	    	);
   	    (a, b)
   	    );
	filterRank := (p,x) -> (
    	    -- false iff residual small
    	    (cop,col) := ranks(x,p);
    	    not(all(cop,x->x==3) and all(col,x->x==2))
    	    );
	filterRank
	);
    if (numFunctions GS == numVariables GS) then (
    	(SELECT, POT) := if instance(o.Target, ZZ) then (selectBestEdgeAndDirection, potentialE) else (selectBestEdgeAndDirection, potentialLowerBound);
	-- small batches (not advised) need more repeats...
	REP := if (o.BatchSize < infinity) then 10+floor(100/o.BatchSize) else o.NumberOfRepeats;
    	randomizer := if (o.Formulation == "eliminated") then (y -> gammifyElim(y, Dpl1p)) else (y -> gammifyWorld y);
    	V := first monodromySolve(GS, p0, sols, Verbose=>o.Verbose, Randomizer=>randomizer,
	    TargetSolutionCount => if instance(o.Target,ZZ) then o.Target else null,
	    BatchSize => o.BatchSize, NumberOfNodes => o.NumberOfNodes, NumberOfEdges => o.NumberOfEdges,
	    NumberOfRepeats=>REP, SelectEdgeAndDirection=>SELECT, Potential=>POT, FilterCondition=> if o.FilterBatch then FILTER else null);
	G := V.Graph;
	badIndices := if o.FilterPost then apply(toList G.Vertices, v -> positions(points v.PartialSols, x -> FILTER(transpose matrix v.BasePoint, transpose matrix x))) else {{},{}};
	(G, badIndices)
	) else false
)

-*
FILE FORMAT:
  either: 
  #sols0, #sols1, areEqual(previous 2 numbers), target, max(previous 2) >= target?
  p0
  sols(p0)
  p1
  sols(p1)
  for all edges p0-p1:
    endpoint0
    endpoint1
    Hashtable of correspondences sols(p0) => sols(p1)
  these data + all relevant evaluators are sufficient to recover the graph if there are 2 nodes
  note: my previous attempt to use "serialize" package produced larger files (eg. 150kb vs 450kb for 100 solutions)
*-
writeMonodromyResult = method(Options=>{WriteGraph=>true, Target=>infinity})
writeMonodromyResult (String, Boolean) := o -> (filename, failed) -> (
    f := openOut filename;
    f << "failed" << endl;
    close f;
    )
writeMonodromyResult (String, Sequence) := o -> (filename, MR) -> (
    (G, badIndices) := MR;
    V0 := first G.Vertices;
    V1 := last G.Vertices;
    -- todo: add post-processing protocol (are all constraints satisfied, are solutions separated
    p0 := coordinates V0.BasePoint;
    p1 := coordinates V1.BasePoint;
    sols0 := (coordinates \ points V0.PartialSols);
    sols1 := (coordinates \ points V1.PartialSols);
    f := openOut filename;
    (m ,n) := (#sols0, #sols1);
    f << m << "," << n << "," << (m == n) << "," << toString(o.Target) << "," << (max(m, n) >= o.Target) << endl;
    if o.WriteGraph then (
    	f << "p0 = " << toExternalString p0 << endl;
    	f << "sols0=" << toExternalString sols0 << endl;
    	f << "p1=" << toExternalString p1 << endl;
    	f << "sols1=" << toExternalString sols1 << endl;
	i := 0;
	f << "dirEdges={";
	edges := toList V0.Edges;
	k := length edges;
    	scan(edges, E -> (
	        f << "(";	
    	    	f << toExternalString E#gamma1 << ",";
    	    	f << toExternalString E#gamma2 << ",";
    	    	f << toExternalString(new HashTable from E#Correspondence12) << ")";
		if (i < k-1) then (
		    f << ", ";
		    i=i+1;
		    );
	    	)
    	    );
	f << "}" << endl;
	f << "badIndices=" << toExternalString badIndices;
	);    
    close f
    )

-- restart monodromy from output file
refreshMonodromy = method(Options=>MONODROMYOPTIONS)
refreshMonodromy (ZZ, String) := o -> (n, inFilePath) -> ( 
    pl1p := getPL1P(n, o.ProblemDirectory);
    if (o.Formulation == "world") then error("not implemented");
    f := lines get inFilePath;
    value \ drop(f,1);
    (F, y0, c0, Dpl1p, cameraMatrixEvaluators, CoLmatrices, CoPmatrices) := eliminatedBuilder(pl1p, CC_53);
    Fsq := squareDown(point{p0}, point{first sols0}, F);
    G := homotopyGraph(Fsq, Equivalencer => (y -> y), Randomizer => (y -> gammifyElim(y, Dpl1p)), Verbose => MONODROMYOPTIONS.Verbose);
    goodSols0 := for i from 0 to #sols0-1 list if not member(i, badIndices#0) then point{sols0#i};
    goodSols1 := for i from 0 to #sols1-1 list if not member(i, badIndices#1) then point{sols1#i};
    n1 := addNode(G, point{p0}, pointArray(goodSols0));
    n2 := addNode(G, point{p1}, pointArray(goodSols1));
    for i from 0 to o.NumberOfEdges do addEdge(G,n1,n2);
    targetSolCount := o.Target;
    USEtrackHomotopy = true;
    setTrackTime(G, 0.0);
    FILTER := if ((o.FilterBatch or o.FilterPost) == false) then null else (
	-- matrix evaluators: used for rank filter
	inputMatrix := (vars F) | (parameters F);
	PE := apply(#CoPmatrices,i->(
		G := CoPmatrices#i;
		(makeSLProgram(inputMatrix,G),
		    mutableMatrix(CC_53,numrows G,numcols G)
		    )
    		)
	    );
	LE := apply(#CoLmatrices,i->(
		G := CoLmatrices#i;
		(makeSLProgram(inputMatrix,G),
		    mutableMatrix(CC_53,numrows G,numcols G)
		    )
    		)
	    );
	ranks := (x, p) -> (
    	    a := PE/( m -> (
	    	    evaluate(first m, mutableMatrix(x||p), last m);
	    	    numericalRank(matrix last m, Threshold=> o.FilterRankTol)
	    	    )
	    	);
    	    b := LE/( m -> (
	    	    evaluate(first m, mutableMatrix(x||p), last m);
	    	    numericalRank(matrix last m, Threshold => o.FilterRankTol)
	    	    )
	    	);
   	    (a, b)
   	    );
	filterRank := (p,x) -> (
    	    -- false iff residual small
    	    (cop,col) := ranks(x,p);
    	    not(all(cop,x->x==3) and all(col,x->x==2))
    	    );
	filterRank
	);
    if (numFunctions Fsq == numVariables Fsq) then (
    	V := first coreMonodromySolve(
    	    G,
    	    first G.Vertices, 
    	    Verbose=>true, 
    	    StoppingCriterion => (
	    	(n, G) -> (max toList apply(G.Vertices, v -> length v.PartialSols) >= targetSolCount or n >= o.NumberOfRepeats)
	    	),
    	    SelectEdgeAndDirection => selectRandomEdgeAndDirection,
    	    BatchSize => infinity,
    	    "new tracking routine" => true
    	    );
	Gnew := V.Graph;
	badIndices := if o.FilterPost then apply(toList Gnew.Vertices, v -> positions(points v.PartialSols, x -> FILTER(transpose matrix v.BasePoint, transpose matrix x))) else {{},{}};
	(Gnew, badIndices)
	) else false
    )


-- iterface to degreePL1P which writes file
runMonodromy = method(Options=>MONODROMYOPTIONS)
runMonodromy (String, ZZ, String) := o -> (inFilePath, n, outFileDir) -> (
    if instance(o.RandSeed, ZZ) then setRandomSeed o.RandSeed;
    monodromyResult := (
	if (fileExists inFilePath) then refreshMonodromy(n, inFilePath, o)
	else degreePL1P(n, o)
    	);    	    
    targID := if instance(o.Target, ZZ) then pad(o.Target, 4) else "0000";
    filename := outFileDir | "monodromy-result-pl1p-" | pad(n, 6) | "-target-" | targID;
    writeMonodromyResult(filename, monodromyResult, WriteGraph=>true, Target=>o.Target);
    )
runMonodromy (ZZ, String) := o -> (n, outFileDir) -> runMonodromy("", n, outFileDir, o)
runMonodromy (String, ZZ) := o -> (inFilePath, n) -> runMonodromy(inFilePath, n, "./", o)
runMonodromy ZZ := o -> n -> runMonodromy(n, "./", o)

end--
restart
setRandomSeed 0
pid = 990 -- "DesMoines", degree 522
-- eliminated builder _fails_ with default settings due to contamination
-- one option is filtering. the other is to choose more conservative settings.
-- experimenting with the latter seems to improve this example
needs "runMonodromy.m2"
runMonodromy(pid,Verbose=>true)
--viewPL1P pl1p
setDefault(tStepMin=>1e-7)
setDefault(maxCorrSteps=>2)


-- how does world compare to elminated with conservative settings?
setRandomSeed 0
pid = 990 -- "DesMoines", degree 522
-- eliminated builder _fails_ with default settings due to contamination
-- one option is filtering. the other is to choose more conservative settings.
-- experimenting with the latter seems to improve this example
setDefault(tStepMin=>1e-7)
setDefault(maxCorrSteps=>2)
elapsedTime degreePL1P(pid,Formulation=>"eliminated",ProblemDirectory=>"../problems/") -- 150s
G = (first oo).Graph
needsPackage "Serialization"
help Serialization
keys G

debug needsPackage "MonodromySolver"

reviveGraph = method()
reviveGraph (String, GateSystem) := ("filename", F) -> (
    G := new HomotopyGraph from

serializeMonodromy = method()
serializeMonodromy (String, List, HomotopyGraph) := (fileName, pl1p, G) -> (
    f := openOut fileName;
    
    

serialize G

-- compared to
setDefault(tStepMin=>1e-6)
setDefault(maxCorrSteps=>3)
elapsedTime degreePL1P(pid,Formulation=>"world",ProblemDirectory=>"../problems/") -- 300 s
setDefault(tStepMin=>1e-8)
setDefault(maxCorrSteps=>1)
elapsedTime degreePL1P(pid,Formulation=>"eliminated",ProblemDirectory=>"../problems/") -- 388s

-- how long to get to 100?
setRandomSeed 0
setDefault(tStepMin=>1e-7)
setDefault(maxCorrSteps=>2)
elapsedTime degreePL1P(990,Formulation=>"eliminated",ProblemDirectory=>"../problems/",TargetSolutionCount=>100) -- 12s
setDefault(tStepMin=>1e-6)
setDefault(maxCorrSteps=>3)
elapsedTime degreePL1P(990,Formulation=>"world",ProblemDirectory=>"../problems/",TargetSolutionCount=>100) -- 23s

viewPL1P getPL1P(8727, "../problems/")

-- minimal: PL0P problem IDs
pl0ps = {6721, 6723, 6724, 6766, 6778, 6779, 6784, 7023, 7024, 7044, 8725, 8727, 8728, 8789, 8790, 8795, 8796, 9573, 9574, 9594, 9595, 9659, 15459, 15460, 15467, 15634, 46728, 46740, 46741, 46746, 46979, 46980, 46985, 46986, 47006, 49211, 49212, 49232, 49233, 49297, 49302, 63247, 63248, 63255, 63422, 63427, 63830, 131133, 131138, 131166, 132013}


setRandomSeed 0
degreePL1P 6721
-*
  node1: 7186                                                                                                   
  node2: 7180                                                                                                   
*-
       
------------------------------------------------------------------
-- Sols > 10k?
degreePL1P 89993
