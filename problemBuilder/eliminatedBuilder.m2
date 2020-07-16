-- IMPORTS
needsPackage "MonodromySolver"

-- GLOBALS
kTol=1e-4
m=3
COFACTOR = true -- computes determinants by LAPLACE expansion
JACOBIAN = true -- runs row selection algorithm for square subsystem

--helper function: find lines passing through point p in 3-space
linesThroughPoint = (p,pl1p) -> (
	result := for l from 1 to nLines list if (pl1p#0#(l-1) == (p-1)) then l;
	delete(,result)
)

--helper function: check if point p is visible in view c
isVisiblePoint = (p,c, pl1p) -> (
	if ( (getViews pl1p)#c#1#p == 1 ) then return true else return false;
)

--helper function: check if line l is visible in view c
isVisibleLine = (l,c, pl1p) -> (
	if ( (getViews pl1p)#c#0#l == 1 ) then true else false
)


--helper function: check if line l is visible in view c and passes through point p
visibleLinesThroughPoint = (p,c,pl1p) -> select(getPins(pl1p, p), l -> isVisibleLine(l,c,pl1p))

--helper function: compute how many ghost lines are needed for point p in view c
--add ghost lines until all points in all 3 views are the intersection of at least two lines
ghostLinesNeeded = (p,c,pl1p) -> (
	--check if point p is visible in view c
	if not isVisiblePoint(p,c,pl1p) then return 0;
	L = visibleLinesThroughPoint(p,c,pl1p);
	if (#L > 1) then return 0;
	2-#L
)


--helper function: group all visible lines in view c into independent and dependent lines
--dependent lines are those that pass through a point which is already the intersection of two lines
distinguishDependentAndIndependentLines = pl1p -> (
    fl := getFreeLines pl1p;
    apply(getViews pl1p, view -> (
    	    viewLines := first view;
	    viewPoints := last view;
	    indep := select(fl, l -> viewLines#l == 1); 
	    dep = {};
	    numPoints := getNumPoints pl1p;
	    scan(0..numPoints-1, p -> (
		    L := select(getPins(pl1p, p), q -> viewLines#q == 1);
		    Lindep := take(L,2);
		    Ldep := apply(drop(L,2), l -> {l, Lindep});
		    indep = indep|Lindep;
		    dep = dep | Ldep;
		    )
    	    	);
	    {indep,dep}
	    )
	)
    )



colshape = method()
colshape Point := p -> colshape matrix p
colshape Matrix := m -> if (numcols m == 1) then m else if (numrows m == 1) then transpose m else error "not a vector"

-- annoying class I used to make the builder in this file callable
DecoratedPL1P = new Type of HashTable
decorate = pl1p -> (
    partitionedVisLines := distinguishDependentAndIndependentLines pl1p;
    nPoints := getNumPoints pl1p;
    new DecoratedPL1P from {
    	"pl1p" => pl1p,
	"visible lines" => getVisLines pl1p,
    	"independent lines" => first \ partitionedVisLines,
    	"dependent lines" => last \ partitionedVisLines,
    	"ghost lines" => apply(length getViews pl1p, c -> flatten apply(nPoints, p -> apply(ghostLinesNeeded(p,c, pl1p), i -> {p,i} )))
	}
    )
getpl1p = Dpl1p -> Dpl1p#"pl1p"
getIndepLines = Dpl1p -> Dpl1p#"independent lines"
getDepLines = Dpl1p -> Dpl1p#"dependent lines"
getGhosts = Dpl1p -> Dpl1p#"ghost lines"

-- fabricate world and image data    
fabricateYC = (Dpl1p, FF, cameraMatrixEvaluators) -> (
    pl1p := getpl1p Dpl1p;
    independentLines := getIndepLines Dpl1p;
    dependentLines := getDepLines Dpl1p;
    ghostLines := getGhosts Dpl1p;
    nPoints := getNumPoints pl1p;
    nLines := getNumLines pl1p;
--    visibleLines := apply(getViews pl1p, v -> getVisLines v);
    worldPoints := random(FF^4,FF^nPoints);
    visPattern := first pl1p;
    worldHelperPoints := for i from 0 to nLines-1 list (
	if visPattern#i == -1 then random(FF^4,FF^2)
	else random(FF^4,FF^1)|worldPoints_{visPattern#i}
	);
    sampleCameraParameters := for i from 1 to 14 list sub(random FF,FF);
    c := matrix{sampleCameraParameters};
    sampleC := apply(cameraMatrixEvaluators, cam -> matrix(evaluate(cam, c),3,4));
    imgData := apply(sampleC, cam-> (cam * worldPoints, cam * worldHelperPoints));
    -- get parameters defining visible (independent + dependent) and ghost lines
    landA := for v from 0 to 2 list(
	indLines := new HashTable from apply(independentLines#v,l->l=>(numericalKernel(transpose imgData#v#1#l, kTol)));
	depLines := apply(dependentLines#v,l->(
		k := numericalKernel(transpose imgData#v#1#(l#0), kTol);
		solve(indLines#(l#1#0)|indLines#(l#1#1),k,ClosestFit=> true)
		)
	    );
	(
	    if (#indLines == 0) then random(FF^0,FF^1) else rfold(apply(sort keys indLines,k->indLines#k))
	    , 
	    if (#depLines == 0) then random(FF^0,FF^1) else rfold(depLines)
	    )
	);
    yVis := rfold(landA/first) || rfold(landA/last);
    yGhostEntries := flatten for m from 0 to 2 list for g in ghostLines#m list randKernel transpose (imgData#m#0)_{first g};
    -- get parameters for charts on domains defining Rs and ts
    ytChart := randKernel(c_(toList(8..13))|matrix{{1_FF}});
    yqChart := randKernel(c_(toList(0..3))|matrix{{1_FF}}) || randKernel(c_(toList(4..7))|matrix{{1_FF}});
    yLines := if (#yGhostEntries == 0) then yVis else yVis || rfold yGhostEntries;
    y := yLines || ytChart || yqChart;
    (point y, point transpose c)    
    )


eliminatedBuilder = (pl1p, FF) -> (
    -- clear these reserved symbols
    w := symbol w;
    x := symbol x;
    y := symbol y;
    z := symbol z;
    t := symbol t;
    l := symbol l;
    a := symbol a;
    g := symbol g;
    ct := symbol ct;
    cq := symbol cq;
    nPoints := # last last last pl1p;
    nLines := # first pl1p;
    Dpl1p := decorate pl1p;
--    visibleLines := getVisLines Dpl1p;
    independentLines := getIndepLines Dpl1p;
    dependentLines := getDepLines Dpl1p;
    ghostLines := getGhosts Dpl1p;
    varMatrix := matrix{
	declareVariable \ (
	    (flatten (for i from 2 to m list {w_i,x_i,y_i,z_i}))|
    	    (flatten (for i from 2 to m list {t_(i,1),t_(i,2),t_(i,3)}))
	    )
	};
    cameraVars := flatten entries varMatrix;
    centerVars := drop(cameraVars,4*(m-1));
    qVars := take(cameraVars,4*(m-1));
    paramMatrix := matrix{
	declareVariable \ (
    	    (flatten for c from 0 to m-1 list flatten for ll in independentLines#c list flatten for k from 1 to 3 list l_(c,ll,k)) | 
    	    (flatten for c from 0 to m-1 list flatten for ll in (dependentLines#c)/first list flatten for k from 1 to 2 list a_(c,ll,k)) | 
    	    (flatten for c from 0 to m-1 list flatten for L in ghostLines#c list flatten for k from 1 to 3 list g_(c,L#0,L#1,k)) |
    	    (flatten (for i from 2 to m list {ct_(i,1), ct_(i,2), ct_(i,3)}) | {ct_0}) |
	    flatten (for i from 2 to m list for j from 0 to 4 list cq_(i,j))
	    )
	};
    chartParams := take(flatten entries paramMatrix,-(1+8*(m-1)));
    tchartParams := take(chartParams,3*(m-1)+1);
    qchartParams := drop(chartParams,3*(m-1)+1);
    completelyVisibleLines := select(getNumLines pl1p, l -> all(getViewLines pl1p, vl -> vl#l == 1));
    R := {gateMatrix(id_(FF^3))} | for i from 2 to m list Q2R(w_i,x_i,y_i,z_i);
    T := {gateMatrix{{0},{0},{0}}} | for i from 2 to m list (w_i^2+x_i^2+y_i^2+z_i^2)*transpose matrix{{t_(i,1),t_(i,2),t_(i,3)}};
    cameraMatrices := apply(R,T,(r,t)->r|t);
    -- two helper functions: visiblePlane and ghostPlane
    --given a line ll and a camera c, compute the pullback plane
    visiblePlane := (ll,c,pl1p) -> (
	if not isVisibleLine(ll,c,pl1p) then (
	    << "line " << ll << ", cam " << c;	
	    error "I'm not a visible line";
	    );
	line := {};
	if member(ll,independentLines#c) then line = matrix{{l_(c,ll,1),l_(c,ll,2),l_(c,ll,3)}}
	else (
	    L := select(dependentLines#c, L -> member(ll,L));
	    if not (#L == 1) then (
		<< "line " << ll << ", cam " << c;
		error "I'm not the dependent at a unique point"
		);
	    L = first L;
	    line = a_(c,L#0,1)*matrix{{l_(c,L#1#0,1),l_(c,L#1#0,2),l_(c,L#1#0,3)}}+a_(c,L#0,2)*matrix{{l_(c,L#1#1,1),l_(c,L#1#1,2),l_(c,L#1#1,3)}};
	    );
    	line*cameraMatrices#c
	);
    --given a point p and a camera c, compute the pullback planes of all ghost lines through p in c
    ghostPlanes = (p,c) -> (
	ghosts := select(ghostLines#c, L -> p == first L);
	ghosts = apply(ghosts, L -> matrix{{g_(c,L#0,L#1,1),g_(c,L#0,L#1,2),g_(c,L#0,L#1,3)}});
	ghosts = apply(ghosts, L -> L*cameraMatrices#(c));
	ghosts
	);
     -- matrices whose rank deficicency encodes a common world line
     CoLmatrices := for ll in completelyVisibleLines list (
	 rfold for c from 0 to m-1 list visiblePlane(ll,c,pl1p)
	 );
     -- matrices whose rank deficicency encodes a common point on incident world lines (+ any ghost lines necessary to define the point)
     CoPmatrices := for p from 0 to nPoints-1 list (
	 rfold( 
	     (flatten for c from 0 to m-1 list for ll in visibleLinesThroughPoint(p,c,pl1p) list visiblePlane(ll,c,pl1p))|
	     (flatten for c from 0 to m-1 list ghostPlanes(p,c)) 
	     )
	 );
     -- create equations
     tChart := matrix{tchartParams}*transpose (matrix{centerVars}|matrix{{1_FF}});
     qCharts := rfold for i from 0 to m-2 list (
	 matrix{take(qchartParams,{5*i,5*i+4})}*
    	 transpose (matrix{take(qVars,{4*i,4*i+3})}|matrix{{1_FF}})
    	 );
     charts := tChart||qCharts;
     funs = charts || transpose gateMatrix{flatten(
    	     CoLmatrices/(M -> allMinors(M, 3, Laplace=>COFACTOR)) |
    	     CoPmatrices/(M -> maxMinors(M, Laplace=>COFACTOR))
    	     )
    	 };
     F := gateSystem(paramMatrix,varMatrix,funs);
     cameraMatrixEvaluators := cameraMatrices/(m -> gateSystem(matrix{cameraVars}, transpose matrix{flatten entries m}));
     (y0, c0) := fabricateYC(Dpl1p, FF, cameraMatrixEvaluators);
     (F, y0, c0, Dpl1p, cameraMatrixEvaluators, CoLmatrices, CoPmatrices)
     )
end--

restart
needs "../pl1p-basics/service-functions.m2"
needs "common.m2"
needs "../pl1p-basics/tikzPL1P.m2"

FF=CC_53;
load "eliminatedBuilder.m2";
for i from 0 to 100 do (
    << i << endl;
    rec = getRecord(i,ProblemDirectory=>"../problems/");
    isMinimal = (# unique(rec#"rank check"#1) == 1);
    pl1p = rec#"pl1p";    
    (F, y0,c0) = take(eliminatedBuilder(pl1p, CC_53),3);
    if isMinimal then elapsedTime F'=squareDown(y0,c0,F);
    assert areEqual(norm evaluate(F,y0,c0),0);
    )

-*
0
1
2
3
4
     -- 0.642378 seconds elapsed
5
6
     -- 0.826947 seconds elapsed
7
     -- 0.801454 seconds elapsed
8
     -- 0.801732 seconds elapsed
9
     -- 0.808719 seconds elapsed
10
     -- 0.809417 seconds elapsed
11
     -- 0.905214 seconds elapsed
12
     -- 0.807074 seconds elapsed
13
     -- 0.799403 seconds elapsed
14
     -- 1.15484 seconds elapsed
15
     -- 1.16205 seconds elapsed
16
     -- 1.16048 seconds elapsed
17
     -- 0.702454 seconds elapsed
18
     -- 0.570866 seconds elapsed
19
     -- 0.506096 seconds elapsed
20
     -- 0.501599 seconds elapsed
21
     -- 0.509934 seconds elapsed
22
     -- 0.503218 seconds elapsed
23
     -- 0.493594 seconds elapsed
24
     -- 0.493604 seconds elapsed
25
     -- 0.5966 seconds elapsed
26
     -- 0.597899 seconds elapsed
27
     -- 0.599297 seconds elapsed
28
     -- 0.597755 seconds elapsed
29
     -- 0.599122 seconds elapsed
30
     -- 0.597968 seconds elapsed
31
32
     -- 0.505978 seconds elapsed
33
     -- 0.612346 seconds elapsed
34
     -- 0.506435 seconds elapsed
35
     -- 0.510079 seconds elapsed
36
     -- 0.50816 seconds elapsed
37
     -- 0.490891 seconds elapsed
38
     -- 0.495173 seconds elapsed
39
     -- 0.49988 seconds elapsed
40
     -- 0.506725 seconds elapsed
41
     -- 0.519796 seconds elapsed
42
     -- 0.509801 seconds elapsed
43
     -- 0.504709 seconds elapsed
44
     -- 0.512461 seconds elapsed
45
     -- 0.506496 seconds elapsed
46
     -- 0.512658 seconds elapsed
47
     -- 0.619703 seconds elapsed
48
     -- 0.511986 seconds elapsed
49
     -- 0.515912 seconds elapsed
50
     -- 0.508829 seconds elapsed
51
     -- 0.510822 seconds elapsed
52
     -- 0.612949 seconds elapsed
53
     -- 0.51119 seconds elapsed
54
     -- 0.50988 seconds elapsed
55
     -- 0.621503 seconds elapsed
56
     -- 0.527047 seconds elapsed
57
58
     -- 0.494154 seconds elapsed
59
     -- 0.602096 seconds elapsed
60
61
     -- 0.501406 seconds elapsed
62
     -- 0.495836 seconds elapsed
63
     -- 0.495706 seconds elapsed
64
     -- 0.498174 seconds elapsed
65
     -- 0.498431 seconds elapsed
66
     -- 0.496512 seconds elapsed
67
     -- 0.498838 seconds elapsed
68
     -- 0.501946 seconds elapsed
69
     -- 0.595637 seconds elapsed
70
     -- 0.901705 seconds elapsed
71
     -- 0.894061 seconds elapsed
72
     -- 0.895118 seconds elapsed
73
     -- 0.514679 seconds elapsed
74
     -- 0.505512 seconds elapsed
75
     -- 0.572925 seconds elapsed
76
     -- 0.668139 seconds elapsed
77
     -- 0.670884 seconds elapsed
78
     -- 0.676815 seconds elapsed
79
     -- 0.481192 seconds elapsed
80
     -- 0.449316 seconds elapsed
81
     -- 0.449907 seconds elapsed
82
     -- 0.443568 seconds elapsed
83
     -- 0.447689 seconds elapsed
84
     -- 0.542295 seconds elapsed
85
     -- 0.54186 seconds elapsed
86
     -- 0.545844 seconds elapsed
87
     -- 0.536829 seconds elapsed
88
89
     -- 0.536657 seconds elapsed
90
     -- 0.537885 seconds elapsed
91
     -- 0.539518 seconds elapsed
92
     -- 0.542935 seconds elapsed
93
     -- 0.635618 seconds elapsed
94
     -- 0.633174 seconds elapsed
95
     -- 0.629937 seconds elapsed
96
     -- 0.631022 seconds elapsed
97
     -- 0.631959 seconds elapsed
98
     -- 0.542068 seconds elapsed
99
     -- 0.530151 seconds elapsed
100
     -- 0.532884 seconds elapsed
*-

load "eliminatedBuilder.m2";
i=18
rec = getRecord(i,ProblemDirectory=>"../problems/");
isMinimal = (# unique(rec#"rank check"#1) == 1);
pl1p = rec#"pl1p";    
elapsedTime (F, y0,c0,Dpl1p) = eliminatedBuilder(pl1p, CC_53);

elapsedTime monodromySolve(squareDown(y0,c0,F), y0, {c0},Verbose=>true,Randomizer=>gammifyElim)


-- square subsystem from F
F'=squareDown(y0,c0,F);
X = vars F'
PH = parametricSegmentHomotopy F';
-- HxHt
cCode(transpose(PH.GateHomotopy#"Hx"|PH.GateHomotopy#"Ht"),X|gateMatrix{{PH.GateHomotopy#"T"}|flatten entries PH#Parameters})
-- HxH
cCode(transpose(PH.GateHomotopy#"Hx"|PH.GateHomotopy#"H"),gateMatrix{X|{PH.GateHomotopy#"T"}|flatten entries PH#Parameters})




nvars = #varInGates -- should change variable name
inGates=declareVariable \ (
    varInGates|

-- variable groups
cameraVars = take(inGates,nvars)


-- parameter groups
dataParams = drop(inGates,nvars)






-- rotation and projection matrices

-- camera evaluator used for fabrication routine
C = cameraMatrices/(P->makeSLProgram(varMatrix, P))





<< " number of polynomials is " << numFunctions F << endl
-- filter path jumps during monodromy when using a square subsystem
filterEval = (p,x) -> (
    -- false iff residual small
    resid := norm evaluate(F,x||p);
--    << "residual: " << resid << endl;
    (resid > 4e-4)
    )



filterRankCoP = (p,x) -> (
    -- false iff residual small
    a := PE/( m -> (
	    evaluate(first m, mutableMatrix(x||p), last m);
	    numericalRank matrix last m
	    )
	    );
    not all(a,x->x==3)
    )


rankCheck = method(Options=>{Hard=>true})
rankCheck (Matrix, Matrix) := o -> (x, p) -> (
   (a, b) := ranks(x, p);
   if (o.Hard) then (all(a,x->x==3) and all(b,x->x==2))
     else (all(a,x->x<=3) and all(b,x->x<=2))
   )
