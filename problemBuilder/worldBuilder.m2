debug needsPackage "SLPexpressions"
needs "./common.m2"

-*
-- handling gates between runs: how much of this code still needed?
*-

-- canonical charts on P2
P2chart0 = M -> (oneGate/M_(0,0))*M^{1,2}
P2chart1 = M -> (oneGate/M_(1,0))*M^{0,2}
P2chart2 = M -> (oneGate/M_(2,0))*M^{0,1}

parametrizeWorld = (pl1p, FF) -> (
    resetGates();
    installGates {x_2,y_2,z_2,x_3,y_3,z_3,t_(2,1),t_(2,2),t_(3,1),t_(3,2),t_(3,3)};
    cameras = {
    	gateMatrix(id_(FF^3)|matrix{{0},{0},{0}}),
    	cay2R(x_2,y_2,z_2)|matrix{{t_(2,1)},{t_(2,2)},{1_FF}},
    	cay2R(x_3,y_3,z_3)|matrix{{t_(3,1)},{t_(3,2)},{t_(3,3)+0_FF}}
    	};
    n := getNumPoints pl1p;
    worldPoints := apply(n, i->transpose matrix{installGates{X_{i,0},X_{i,1},X_{i,2}} | {oneGate}});         
    ls := getLines pl1p;
    worldLines := apply(#ls, i->
	(if (ls#i<0) then -- point A on the line 
	transpose matrix{installGates{A_{i,0},A_{i,1}} | {zeroGate, oneGate}}
	else worldPoints#(ls#i)) | transpose matrix{installGates{B_{i,0},B_{i,1}} | {oneGate, zeroGate}} 
	);      	  
    (worldPoints,worldLines,cameras)
    )


makePhi = method()
-* IN : description of PL1P, a list of GateMatrices for cameras
   OUT: GateMatrix for the forward map Phi

parameters of the domain (transpose each matrix below):    
  [*,*,*,1] for each world point
  [[*,*,1,0],
   [*,*,0,1]] for each free line (perceived as two points on the line)
  [*,*,1,0] for each pin (perceived as a point on the pin)
*-      
makePhi (List, Ring) := (pl1p,FF) -> (
    -- we can make the next few lines marginally more efficient
    (worldPoints,worldLines,cameras) := parametrizeWorld(pl1p,FF);
    allLines := getLines pl1p;
    v := getViews pl1p;
    (n, l) := (getNumPoints pl1p, getNumLines pl1p);
    firstPin := position(getLines pl1p|{0}, i -> i > -1);
    phi := new MutableList from {}; -- list of (lists of) Gates (coordinates in some chart on the codomain) 
    lastPhi = 0;
    scan(#cameras, j->(
	c := cameras#j;
	(ls, ps) := (v#j#0, v#j#1); -- visibility pattern for camera j
	for i from 0 to firstPin-1 do if (ls#i==1) then (	    
	    projLine := c*worldLines#i;
	    --<< "size of free line is " << size projLine << endl;
	    phi#lastPhi = flatten entries P2chart0 transpose pl3 projLine;
	    lastPhi = lastPhi + 1;
	    );
	for i from firstPin to l-1 do if (ls#i==1) then (	    
	    projLine := c*worldLines#i;
	    --<< "size of pinned line is " << size projLine << endl;
	    phi#lastPhi = if ps#(allLines#i)==1 
	    then (P2chart0 transpose pl3 projLine)_(0,0)-- grab one of the coordinates
	    else flatten entries P2chart0 transpose pl3 projLine; -- grab two: this pin is a free line
	    lastPhi = lastPhi + 1;
	    );
	for i from 0 to n-1 do if (ps#i==1) then (
	    projPoint := c*worldPoints#i;
	    --<< "size of image point is " << size projPoint << endl;
	    phi#lastPhi = flatten entries P2chart2 projPoint;
	    lastPhi = lastPhi + 1;
	    );
	));
    transpose matrix{flatten toList phi}
    )

makePhiGraphFamily = (pl1p,FF) -> (
    Phi := makePhi(pl1p, FF);
    c := numrows Phi;
    x0 := mutableMatrix random(FF^c, FF^1);
    varGates := toList installedGates;
    varGateMatrix := matrix{varGates};
    installGates((for i from 0 to c-1 list a_i)|(for i from 0 to c-1 list b_i));
    paramGates := toList drop(installedGates,c);
    paramGateMatrix := gateMatrix{paramGates};
    E := gateSystem(varGateMatrix,Phi); -- this is potential trouble
    y0 := evaluate(E,transpose matrix x0);
    a0 := random(FF^c, FF^1);
    x0 = matrix x0;
    y0 = transpose matrix y0;
    b0 := transpose matrix{for i from 0 to c-1 list y0_(i,0)*a0_(i,0)};
    F := transpose matrix{for i from 0 to c-1 list a_i*Phi_(i,0)-b_i};
    G := gateSystem(paramGateMatrix,varGateMatrix,F);
    p0 := a0 || b0;
    (G, point p0, {point x0})
    )

rankCheck = method(Options=>{Threshold=>1e-5})    
rankCheck (List,Ring) := o -> (pl1p,FF) -> (
    Phi := makePhi(pl1p,FF);
    inGates := matrix {toList installedGates};
    J := diff(inGates, Phi);
    E := makeSLProgram(inGates,matrix{flatten entries J}); -- this is potential trouble
    Mout := matrix(evaluate(E,random(FF^(#installedGates),FF^1)),#installedGates,#installedGates);
    r := if instance(FF,InexactField) then numericalRank(Mout,Threshold=>o.Threshold) else rank Mout;
    --<< "minimal is " << (#installedGates == r) << endl;
    --<< "inputs, outputs, rank of Jacobian" << endl;
    append(size J,r)
    )    


end--

restart
needs "worldBuilder.m2"

-*
-- "Seattle"
pl1p = {
    {-1,-1,-1,-1}
    ,
    {
    {{1,1,1,1},{1}},
    {{1,1,1,1},{1}},
    {{1,1,1,1},{1}}
    }
} 
*-

-- "Cleeveland"
pl1p = {
    {-1},
    {
	{{1},{1,1,1}},
    	{{1},{1,1,1}},
    	{{1},{1,1,1}}
    }
}
elapsedTime (G,p0,sols) = makePhiGraphFamily(pl1p,CC_53);
needsPackage "MonodromySolver"
monodromySolve(G,p0,sols,Verbose=>true)


FF=ZZ/nextPrime 2019
Phi = makePhi(pl1p,FF);
constants Phi
rankCheck(pl1p,FF)
rankCheck(pl1p,CC_53)


NAGtrace 3
norm evaluate(G,point gammify p0,first sols)
errorDepth = 2
parametricSegmentHomotopy G
elapsedTime (V,np)=

errorDepth = 2





x0=random(CC^(numcols Phi),CC^1)


polySystem(Phi-params)


elapsedTime rankCheck pl1p -- expect 0 small singular values


-- the ultimate hedgehog
pl1p = {
    {0,0,0,0,0,0,0,0}
    ,
    {
    {{1,1,1,1,1,1,1,1},{1}},
    {{1,1,1,1,1,1,1,1},{1}},
    {{1,1,1,1,1,1,1,1},{1}}
    }
}    
elapsedTime rankCheck pl1p -- expect 2 small singular values

-- the penultimate hedgehog (1016_6)
pl1p = {
    {-1,0,0,0,0,0,0}
    ,
    {
    {{1,1,1,1,1,1,1},{1}},
    {{1,1,1,1,1,1,1},{1}},
    {{1,1,1,1,1,1,1},{1}}
    }
}    
elapsedTime rankCheck pl1p -- expect 1 small singular value

-- cleveland
pl1p = {
    {-1}
    ,
    {
    {{1},{1,1,1}},
    {{1},{1,1,1}},
    {{1},{1,1,1}}
    }
}    
elapsedTime rankCheck pl1p -- expect 0 small singular values




-- chicago
pl1p = {
    {0,1}
    ,
    {
    {{1,1},{1,1,1}},
    {{1,1},{1,1,1}},
    {{1,1},{1,1,1}}
    }
}    
elapsedTime rankCheck pl1p -- expect 0 small singular values



--kathlen example
-- created from {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1}
-- p7=1, p242=1, all else 0
-- so 1 pt with 7 pins, 1 pt w 2 pins

pl1p = {
    {0,0,1,1,1,1,1,1,1}
    ,
    {
    {{0,1,1,1,1,1,1,1,1},{0,1}},
    {{1,0,1,1,1,1,1,1,1},{0,1}},
    {{1,1,1,1,1,1,1,1,1},{1,1}}
    }
}    

elapsedTime rankCheck pl1p -- 2 DOF, non-minimal?

