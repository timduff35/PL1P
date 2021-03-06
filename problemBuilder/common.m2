-- IMPORTS 
debug needsPackage "NumericalAlgebraicGeometry"
debug SLPexpressions
debug needsPackage "Core"

needs "../pl1p-basics/service-functions.m2"

-- Gate handling for both builders: how much of this code is still needed?
installedGates = new MutableList from {}
lastGate = 0
resetGates = () -> (
    scan(installedGates, g-> (
	    str = toString(g.Name);
--	    str := toString g;
	    value(str|" = symbol " | str)
	    ));
    installedGates = new MutableList from {};
    lastGate = 0;
    )	
installGate = sym -> (
    str := toString sym;
    g := value(str | " = inputGate " | str);
    installedGates#lastGate = g;
    lastGate = lastGate + 1;
    g
    )
installGates = G -> apply(G, s -> installGate s)


-- FUNCTIONS

size GateMatrix := M -> (numrows M, numcols M)
size Matrix := M -> (numrows M, numcols M)

-- plucker vector for a 3*2 matrix
pl3 = M -> matrix{{det2 M^{1,2},det2 M^{2,0},det2 M^{0,1}}}

--random diagonal matrix
randDiag = n -> diagonalMatrix for i from 1 to n list random FF

dehomogenize = method(Options=>{})
dehomogenize (Matrix, ZZ) := o -> (v, n) -> (
    --assumes column vector
    (1/v_(n, 0))*v^(toList splice(0..n-1,n+1..numrows v-1))
    )
dehomogenize Matrix := o -> v -> dehomogenize(v, numrows v -1)

summary = L -> (
    n := #L;
    H := sort L;
    Q1 := (1/2) * (H#(floor((n-1)/3))+H#(ceiling((n-1)/3)));
    med := (1/2) * (H#(floor((n-1)/2))+H#(ceiling((n-1)/2)));
    Q3 := (1/2) * (H#(floor(2*(n-1)/3))+H#(ceiling(2*(n-1)/3)));
    mean := (sum L)/n;
    var := sum(L/(x-> (x - mean)^2))/(n-1);
    << "Min: " << toString(min L) << endl;
    << "1Q: " << toString(Q1) << endl;
    << "Med: " << toString(med) << endl;
    << "Avg: " << toString(sub(mean,RR)) << endl;
    << "3Q: " << toString(Q3) << endl;
    << "Max: " << toString(max L) << endl;
    << "Std Dev: " << toString(sqrt(var)) << endl;
    )    

-- random element in the kernel of M
randKernel = method(Options=>{Tolerance=>1e-4})
randKernel (Matrix, Type) := o -> (M, FF) -> (
    if instance(FF, InexactFieldFamily) then error "please give precision explicitly";
    K := if char FF > 0 
    then gens ker M
    else numericalKernel(M, Tolerance => o.Tolerance);
    K*random(FF^(numcols K), FF^1)
    )
randKernel Matrix := o -> M -> randKernel(M, ring M)



-- fold along rows
rfold = L -> if (#L ==0) then random(FF^0,FF^0) else fold(L, (a,b) -> a||b)

-- fold along cols
cfold = L -> fold(L, (a,b) -> a|b)


-- write starting parameters and solutions to file
writeStartSys = method(Options=>{Filename=>"startSys"})
writeStartSys (Matrix, List) := o -> (M, sols) -> writeStartSys(point M, sols, o)
writeStartSys (Point, List) := o -> (p, sols) -> (
   assert(instance(o.Filename,String));
   f := openOut o.Filename;
   f << "Parameter values: " << endl;
   f << toExternalString p << endl;
   f << "Solutions : " << endl;
   for s in sols do f << toExternalString s << endl;
   close f;
   )

readStartSys = filename -> (
    l := separate("\n", get filename);
    p0 := value l#1;
    sols := for i from 3 to #l-2 list value l#i;
    (transpose matrix p0, sols/matrix/transpose)
    )

-- for testing the contents of a start system file
startSysTester = (p,sols) -> (
    if char FF > 0 then "this works for CC only";
    p0 := (transpose matrix V.BasePoint);
    p1 := random(CC^(#dataParams),CC^1);
    P01 = p0||p1;
    Pspec01 := specialize(PH,P0);
    target01 := trackHomotopy(Pspec01, sols);
    Pspec10 := (gammify p1)|(gammify p0);
    trackHomotopy(Pspec10, target01)
    )
    

adjugate = method()
adjugate Thing := M -> (
    n := numcols M;
    assert(n == numrows M);
    matrix table(n,n,(i,j)->((-1)^(i+j))*det submatrix'(M,{j},{i}))
    )

-- not printing to high precision -- deprecated?
sol2String = p -> replace("\\{|\\}","",toString p.Coordinates)

-- produces gates for "small" determinants"
det2 = M -> M_(0,0)*M_(1,1)-M_(1,0)*M_(0,1)
det3 = M -> M_(0,0)*det2(M_{1,2}^{1,2})-M_(0,1)*det2(M_{0,2}^{1,2})+M_(0,2)*det2(M_{0,1}^{1,2})
det4 = M -> M_(0,0)*det3(M_{1,2,3}^{1,2,3})-M_(0,1)*det3(M_{0,2,3}^{1,2,3})+M_(0,2)*det3(M_{0,1,3}^{1,2,3})-M_(0,3)*det3(M_{0,1,2}^{1,2,3})

laplaceDet = M -> (
    (m, n) := size M;
    if (m=!=n) then error("not square matrix")
    else if (m>5) then error("no Laplace for matrices larger than 4x4")
    else if (m==2) then det2 M
    else if (m==3) then det3 M
    else -* m==4 *- det4 M
    )

-- jacobian of GateMatrix wrt. a list of inputGates
jacobian (GateMatrix, List) := (F,inGates) -> fold(apply(inGates,g->diff(g,F)),(a,b)->a|b)

-- get rotation matrix from cayley parameters
cay2R = method(Options=>{Normalized=>false})
cay2R (Thing,Thing,Thing) := o -> (x,y,z) -> (
     M := matrix{
    {1+x*x-(y*y+z*z), 2*(x*y-z), 2*(x*z+y)},
    {2*(x*y+z), 1+y^2-(x*x+z*z), 2*(y*z-x)},
    {2*(x*z-y), 2*(y*z+x), 1 +z*z -(x*x+y*y)}
	};
    if o.Normalized then (1/(1+x^2+y^2+z^2)) * M else M
    )
cay2R List := o -> L -> cay2R(L#0, L#1, L#2, o)

-- get Cayley parameters from rotation matrix
R2Cay = method(Options=>{UnNormalize=>false})
R2Cay Matrix := o -> R -> (
    assert(numcols R == 3);
    assert(numrows R == 3);
    S := (R-id_(FF^3))*(R+id_(FF^3))^-1;
    (S_(2,1), S_(0,2), S_(1,0))
    )

-*/// TEST
restart
needs "common.m2"
(x, y, z) = (random RR, random RR, random RR)
R = cay2R(x, y, z)
(x',y',z') = R2Cay R
R = cay2R(x', y', z')
R2Cay R
///*-

-- get rotation matrix from quaternion parameters
Q2R = method(Options=>{Normalized=>false, Field=>FF})
Q2R (Thing,Thing,Thing, Thing) := o -> (w,x,y,z) -> (
    M := matrix{
    {w*w+x*x-(y*y+z*z), 2*(x*y-w*z), 2*(x*z+w*y)},
    {2*(x*y+w*z), w^2+y^2-(x*x+z*z), 2*(y*z-w*x)},
    {2*(x*z-w*y), 2*(y*z+w*x), w^2 +z*z -(x*x+y*y)}
	};
    if o.Normalized then (1/(w^2+x^2+y^2+z^2)) * M else M
    )
Q2R List := o -> L -> Q2R(L#0, L#1, L#2, L#3, o)

-- get Cayley parameters from rotation matrix
R2Q = method(Options=>{UnNormalize=>false,Field=>FF})
R2Q Matrix := o -> R -> (
    if char FF > 0 then "this works for CC only";
    assert(numcols R == 3);
    assert(numrows R == 3);
    c := (R_(2,1) - R_(1,2));
    b := (R_(0,2) - R_(2,0));
    a := (R_(1,0) - R_(0,1));
    w := (1/2)*sqrt(R_(0,0)+R_(1,1)+R_(2,2)+1);
    x := 1/(4*w) * c;
    y := 1/(4*w) * b;
    z := 1/(4*w) * a;
--    << w^2+x^2+y^2+z^2 << endl;
    (w, x, y, z)
    )

-- cross product of col vectors -- takes Matrice or GateMatrix pair
crossProduct = (y,q) -> matrix{{y_(1,0)*q_(2,0)-y_(2,0)*q_(1,0)},{y_(2,0)*q_(0,0)-y_(0,0)*q_(2,0)},{y_(0,0)*q_(1,0)-y_(1,0)*q_(0,0)}}

--
randomLineThroughPoints = (P, FF) -> ( 
    m := numrows P; -- m = dim + 1
    n := numcols P; -- n = number of points
    assert(m>=3 and m<=4);
    K := numericalKernel(transpose P,1e-6);
    --assert(numcols K == m-n); -- true if points are distinct
    transpose(K * random(FF^(numcols K),FF^(m-2)))
    )




-- convenience functions for minors
minors (GateMatrix, ZZ, Sequence, Boolean) := o ->  (M, k, S, laplace) -> (
    (Sm, Sn) := (first S, last S);
    (m,n) := (numrows M, numcols M);
    assert(k<=min(m,n));
    assert(all(Sm,s->#s==k));
    assert(all(Sn,s->#s==k));
    flatten apply(Sm,sm->apply(Sn, sn -> 
	    if (laplace) then laplaceDet submatrix(M,sm,sn)
	    else det submatrix(M,sm,sn)
	    ))
    )

allMinors = method(Options=>{Laplace=>false})
allMinors (GateMatrix, ZZ) := o -> (M, k) -> (
    (m, n ) := (numrows M, numcols M);
    s := (subsets(0..m-1,k),subsets(0..n-1,k));
    minors(M, k, s, o.Laplace)
    )

maxMinors = method(Options=>{Laplace=>false})
maxMinors GateMatrix := o -> M -> allMinors(M,min(numrows M, numcols M), Laplace=>o.Laplace)

-- this seems to work
complexQR = M -> (
    A := mutableMatrix M;
    k := ring A;
    Q := mutableMatrix(k,0,0,Dense=>true);
    R := mutableMatrix(k,0,0,Dense=>true);
    rawQR(raw A, raw Q, raw R, true);
    --assert(areEqual(Q*R,A)); -- idk if it will work every time!
    (matrix Q,matrix R)
    )

leverageScores = M -> (
    Q = first complexQR M;
    rsort apply(numrows Q,i->(norm(2,Q^{i}),i))
    )




leverageScoreRowSelector = J0 -> (
    sortedRows := (leverageScores J0)/last;
    r := rowSelector J0^(sortedRows);
    sort(r/(i->sortedRows#i))
    )

log10 = x -> log(x)/log(10)

argCC = z -> atan((imaginaryPart z)/(realPart z))

-- complex number whose real and imag parts are standard normal
gaussCC = () -> (
    (u1,u2):=(random RR,random RR);
    sqrt(-2*log(u1))*cos(2*pi*u2)+ii*sqrt(-2*log(u1))*sin(2*pi*u2)
    )

-- random sample drawn from normal distriution N(mu, var^2)
rNorm = (mu,var) -> mu+var*(realPart gaussCC())_CC

-- random sample from (n-1)-sphere with radius r
sphere = (n,r) -> (
    l:=apply(n,i->rNorm(0,1));
    matrix{r/norm(2,l)*l}
    )

-- assumes "u" of unit length
householder=method()
householder (Matrix,ZZ) := (u,n) -> (
    if (numrows u > 1) then error("householder takes a row vector");
    R:=ring u;
    k:=numcols u;
    id_(R^(n-k))++(id_(R^k)-2*(transpose u)*u)
    )
householder (List,ZZ) := (u,n) -> householder(matrix {u},n)

randomOn = n -> diagonalMatrix(toList((n-1):1_RR)|{(-1)^(random 2)}) * fold(reverse apply(2..n,i->householder(sphere(i,1),n)),(a,b)->a*b)

randomCameraNormalized = () -> (
    R := randomOn 3;
    t := matrix{{random FF},{random FF},{random FF}};
--    t := transpose matrix{sphere(3,1)};
    tnorm := (1 / t_(2,0))* t;
    (R|tnorm)
    )

randomCameraNormalizedCayley = () -> (
    R := cay2R(random FF, random FF, random FF, Normalized=>true);
    t := matrix{{random FF},{random FF},{random FF}};
--    t := transpose matrix{sphere(3,1)};
    tnorm := (1 / t_(2,0))* t;
    (R|tnorm)
    )


randomCamera = () -> (
    R := randomOn 3;
    t := transpose matrix{sphere(3,1)};
    (R|t)
    )

ranks = method(Options=>{})
ranks (Matrix, Matrix) := o -> (x, p) -> (
    a := PE/( m -> (
	    evaluate(first m, mutableMatrix(x||p), last m);
	    numericalRank matrix last m
	    )
	    );
    b := LE/( m -> (
	    evaluate(first m, mutableMatrix(x||p), last m);
	    numericalRank matrix last m
	    )
	    );
   (a, b)
   )

rankCheck = method(Options=>{Hard=>true})
rankCheck (Matrix, Matrix) := o -> (x, p) -> (
   (a, b) := ranks(x, p);
   if (o.Hard) then (all(a,x->x==3) and all(b,x->x==2))
     else (all(a,x->x<=3) and all(b,x->x<=2))
   )

cpMatrix = t -> matrix{{0,-t_(2,0),t_(1,0)},{t_(2,0),0,-t_(0,0)},{-t_(1,0),t_(0,0),0}}

essential = (R,t) -> R * cpMatrix t

pCompose = method()
pCompose (MutableHashTable, MutableHashTable) := (H1, H2) -> (
    new MutableHashTable from apply(keys H1,k-> if H2#?(H1#k) then k=> H2#(H1#k))
    )

writePermutations = (L, filename) -> (
    perms := L/(P->P/(i->i+1)); -- increment letters by 1 for GAP
    file := openOut (currentFileDirectory | filename);
    for i from 0 to #perms-1 do file << "p" << i << ":= PermList(" << toString(new Array from perms#i) << ");" << endl;
    file << "G:=Group(";
    for i from 0 to #perms-2 do file << "p" << i << ", ";
    file << "p" << #perms-1 << ");";
    close file;
    )

-- "join" of two GateSystems (take all functions from both)
GateSystem || GateSystem := (P, Q) -> (
    allVars := unique( (flatten entries vars P) | (flatten entries vars Q) );
    allParams := unique( (flatten entries parameters P) | (flatten entries parameters Q) );
    gateSystem(
	gateMatrix{allParams},
	gateMatrix{allVars},
    	(gateMatrix P)||(gateMatrix Q)
	)
    )

-- sum of two GateSystems
GateSystem + GateSystem := (P, Q) -> (
    if (numFunctions P =!= numFunctions Q) then error "can only add GateSystems of the same shape";
    H := P || Q;
    gateSystem(parameters H, vars H, gateMatrix P + gateMatrix Q)
    )

-- take some functions from the GateSystem
GateSystem ^ List := (P, inds) -> gateSystem(parameters P, vars P, (gateMatrix P)^inds)

-- append some slices to a given GateSystem
sliceSystem = method(Options => {Affine => 0, Homog => 0})
sliceSystem (GateMatrix, GateSystem) := o -> (X, F) -> (
    if (o.Affine <= 0 and o.Homog <= 0) then error("you did not do the slice");
    F || foldVert for i from 0 to o.Affine + o.Homog - 1 list (
	m := if i < o.Affine then numcols X + 1 else numcols X;
	X' := if i < o.Affine then transpose(X | gateMatrix{{1_CC}}) else transpose X;
    	sliceParams := gateMatrix{for i from 0 to m-1 list (
	    	ret := SS_sliceCounter;
	    	sliceCounter = sliceCounter + 1;
	    	ret)};
    	gateSystem(sliceParams, vars F, sliceParams * X')
	)
    )
sliceSystem GateSystem := o -> F -> sliceSystem(vars F, F, o)

-- sub new values for variables
sub (GateMatrix, GateSystem) := (X, F) -> gateSystem(parameters F, X, sub(gateMatrix F, vars F, X))    

-- implementation of evaluateJacobian (I think overriding abstract method)
evaluateJacobian (Point, Point, GateSystem) := (y0, c0, F) -> (
    J := diff(vars F, gateMatrix F);
    (M, N) := (numrows J, numcols J);
    JGS := gateSystem(parameters F, vars F, transpose matrix{flatten entries J});
    matrix(transpose evaluate(JGS, y0, c0),M,N)
    )

-- helpers for rowSelector
orthoProjectQR = (M,L) -> (
    (Q,R)=complexQR L;
--    Q := (SVD L)#1;
    Q*conjugate transpose Q *M
    )

-- orthonormal basis for col(L) using SVD
ONB = L -> (
    (S,U,Vt) := SVD L;
    r := # select(S,s->not areEqual(s,0));
    U_{0..r-1}
    )

-- component of col(L) that is perpendicular to M
perp = method(Options=>{UseSVD=>true})
perp (Matrix, Matrix) := o -> (M, L) -> if areEqual(norm L, 0) then M else (
    Lortho := if o.UseSVD then ONB L else first complexQR L; -- QR seems buggy
    Lperp := M-Lortho*conjugate transpose Lortho * M;
    if o.UseSVD then ONB Lperp else first complexQR Lperp
    )

rowSelector = method(Options=>{BlockSize=>1,UseSVD=>true,Verbose=>false})
rowSelector (Point, Point, GateSystem) := o -> (y0, c0, F) -> (
    blockSize := o.BlockSize;
    numBlocks = ceiling((numFunctions F)/blockSize);
    numIters=0;
    L := matrix{for i from 1 to 14 list 0_CC}; -- initial "basis" for row space
    r := 0;
    goodRows := {};
    diffIndices := {};
    while (r < 14 and numIters < numBlocks) do (
    	diffIndices = for j from numIters*blockSize to min((numIters+1)*blockSize,numFunctions F)-1 list j;
	if o.Verbose then << "processing rows " << first diffIndices << " thru " << last diffIndices << endl;
    	newRows := evaluateJacobian(y0,c0,F^diffIndices);
    	for j from 0 to numrows newRows - 1 do (
	    tmp := transpose perp(transpose newRows^{j}, transpose L);
	    if not areEqual(0, norm tmp) then (
		if o.Verbose then << "added row " << blockSize*numIters+j << endl;
	    	if areEqual(norm L^{0}, 0) then L = tmp else L = L || tmp;
	    	goodRows = append(goodRows, blockSize*numIters+j);
		);
    	    );
    	r = numericalRank L;
    	numIters = numIters+1;
	);
    if o.Verbose then << "the rows selected are " << goodRows << endl;
    goodRows
    )

squareDown = method(Options=>{BlockSize=>1, Verbose=>false})
squareDown (Point, Point, GateSystem) := o -> (y0, c0, F) -> F^(rowSelector(y0, c0, F, BlockSize => o.BlockSize, Verbose=>o.Verbose))
