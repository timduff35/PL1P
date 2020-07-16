-- run in problemBuilder directory
restart
FF = ZZ/911
-*
FF = CC_53
*-

-- this should have 160 solutions
pl1p = {{},
    {
    	{{}, {1, 1, 1, 0, 0}}, 
	{{}, {1, 1, 1, 1, 1}}, 
     	{{}, {1, 1, 1, 1, 1}}
     }
    }

COFACTOR = true
JACOBIAN = true
--needs "eliminatedBuilder.m2"

errorDepth = 0
(y,c) = fabricateYC(pl1p, FF)

SF = gateSystem(paramMatrix, varMatrix, F)
evaluate(SF,transpose y, transpose c)
 
-- char FF == 0  
if (instance(Jpivots, Symbol) and JACOBIAN) then (
    -- better to have this precomputed
    << "differentiating" << endl;
    elapsedTime J = diff(varMatrix,F);
    (M,N) = size J;
    elapsedTime JGS = gateSystem(paramMatrix, varMatrix, transpose matrix{flatten entries J});
    elapsedTime J0 = matrix(transpose evaluate(JGS,transpose y,transpose c),M,N);
    elapsedTime Jpivots = rowSelector(J0,Threshold=>1e-5);
    elapsedTime S = first SVD J0^Jpivots;
    )
elapsedTime GS=gateSystem(paramMatrix,varMatrix,F^Jpivots);
monodromySolve(GS, 
    point y, {point c},Verbose=>true)

-- char FF > 0 
R = FF[x_1..x_(numrows c)]
I = ideal evaluate(SF,transpose y, vars R);
time GB = groebnerBasis(I,Strategy=>"F4"); -- eats 33G very fast... 

