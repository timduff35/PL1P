pad (ZZ, ZZ) := (n, j) -> (
    s := toString n;
    l:=length s;
    assert(j>=l);
    k:=j-l;
    concatenate(concatenate(k:"0"),s)
    )

getRecord = method(Options=>{ProblemDirectory=>null})
getRecord ZZ := o -> n -> (
    prob := pad(n,6);
    probDir := if instance(o.ProblemDirectory, Nothing) then (currentDirectory() | "problems/") else o.ProblemDirectory;
    probFileID := if (n>0) then substring(prob,0,3)| "/"| replace("^(0*)","",prob) else "000/0";
    f := openIn(
	probDir |
	probFileID | ".pl1p");
    H := value get f
    )

getPL1P = method()
getPL1P (ZZ, Thing) := (n, thePath) -> (
    assert(instance(thePath, Nothing) or instance(thePath, String));
    (getRecord(n, ProblemDirectory=>thePath))#"pl1p"
    )
getPL1P ZZ := n -> getPL1P(n, null)


-- queries for individual views
getVisLines = view -> first view
getVisPoints = view -> last view

-- pl1p queries
getLines = pl1p -> first pl1p
getViews = pl1p -> last pl1p
getViewLines = pl1p -> first \ getViews pl1p
getViewPoints = pl1p -> last \ getViews pl1p
getNumPoints = pl1p -> # getVisPoints first getViews pl1p
getNumLines = pl1p -> # getVisLines first getViews pl1p
getFreeLines = pl1p -> ( l := getLines pl1p; select(#l, i->l#i==-1) )
getPointsWithoutPins = pl1p -> select(toList(0 .. getNumPoints pl1p-1), p->not member(p,getLines pl1p))
getPointsWithPins = pl1p -> select(toList(0 .. getNumPoints pl1p-1), p->member(p,getLines pl1p)) -- !!! numbering of points in pl1p starts with 1

-- get pins through a point
getPins = (pl1p,p) -> ( l := getLines pl1p; select(#l, i->l#i==p) ) -- !!! numbering of points in pl1p starts with 1

checkPL1P = pl1p -> (
    ls := getLines pl1p;
    vs := getViews pl1p;
    n := getNumPoints pl1p;
    assert all(vs, v-># getVisPoints v == n);
    assert all(ls, l->instance(l,ZZ) and l>=-1 and l<n);
    assert(sort ls == ls);    
    -* UNCHECKED AT THE MOMENT:  
    BALANCEDness
    ADMISSIBILITY of visibility pattern  
    *-
    )

