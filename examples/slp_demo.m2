restart
needsPackage "MonodromySolver"
quadraticParameterHomotopy = method()
quadraticParameterHomotopy (Number, Number, GateSystem) := (a, b, F) -> (
    V := flatten entries vars F;
    W := flatten entries parameters F;
    A := matrix{apply(W, w->inputGate symbol A_w)};
    B := matrix{apply(W, w->inputGate symbol B_w)};
    t := inputGate symbol t;
    H := sub(gateMatrix F,matrix{W},(1-(t-t*(1-t)*a))*A+(t-t*(1-t)*b)*B);
    gateHomotopy(H,matrix{V},t,Parameters=>A|B)
    )

R = CC[x,y,a]
PS = polySystem {x^2+y^2-1, x+a*y, (a^2+1)*y^2-1}
F = gateSystem(squareUp(PS,2), drop(gens R,2)) 
PH = quadraticParameterHomotopy(F,random CC, random CC)
a0 = 0; a1 = 1;
H = specialize (PH, transpose matrix{{a0,a1}})
s'sols = { {{0,1}},{{0,-1}} }/point
time sols = trackHomotopy(H,s'sols)
assert areEqual(sols,{{ { -.707107, .707107}, SolutionStatus => Regular }, { {.707107, -.707107}, SolutionStatus => Regular }} / point)



-- ex 0: epsilon-local rigidity

-- ex 1: geiringer graphs

-- ex 2: ED degree

-- ex 3: vision

-- ex 4: degree of a parametrized variety

-- ex 5: Alt's problem
