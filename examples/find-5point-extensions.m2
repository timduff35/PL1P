-- run in the top directory
needs "pl1p-basics/service-functions.m2"
needs "pl1p-basics/tikzPL1P.m2"
falseNegatives = value get "examples/false-negatives"
getExtensions = method(Options=>{Registration=>false}) 
getExtensions List := opts -> M -> select(#M, i->(
	p := M_i#"pl1p";
	rkChk := last M_i#"rank check";	    
	v := toSequence getViews p;   
	li := getLines p;
	n := getNumPoints p;
	any(subsets(3,2), s->(
		(i,j) := toSequence s;
		vpi := getVisPoints v_i; 
		vpj := getVisPoints v_j;
		common := apply(vpi,vpj,(a,b)->a*b);
		sum common == 5
		and ( not opts.Registration or (
		    	getVisLines v_i == getVisLines v_j 
			and
			all(n,p->common#p==1 or vpi#p==0 or 	
		    	    -- a not-common point visible in camera i
		    	    -- has to have a pin visible in camera j  
		    	    any(select(#li,l->li_l==p), l->(getVisLines v_j)#l==1)
		    	    )
			and 
			all(n,p->common#p==1 or vpj#p==0 or 
		    	    -- a not-common point visible in camera j
		    	    -- has to have a pin visible in camera i 
		    	    any(select(#li,l->li_l==p), l->(getVisLines v_i)#l==1)
		    	    )		
			))
		and 
		(first rkChk == last rkChk or member(i, falseNegatives))
		)) 
	))

writeTable = (filename, IDlist, numDiagramsPerRow) -> ( 
    f := openOut filename;
    f << "\\begin{tabular}{|";
    for i from 1 to numDiagramsPerRow do f << "c|";
    f << "}" << endl;
    f << "\\hline " << endl;
    count := 0;
    for ID in IDlist do (
	count = count + 1;
	tikzPL1P(getPL1P ID, File=>f, Vertical=>true);
	f << if count % numDiagramsPerRow == 0 then "\\\\\n\\hline\n" else "\n&\n";
	);
    if count % numDiagramsPerRow != 0 then (
    	for i from 1 to numDiagramsPerRow-(count%numDiagramsPerRow)-1 do f << "&";
	f << "\\\\\n\\hline\n" << endl;
	);
    f << "\\end{tabular}";
    close f
    )

end
restart
elapsedTime M = for i from 0 to 143493 list getRecord(i,ProblemDirectory=>"problems/");
load "examples/find-5point-extensions.m2"
extensions = getExtensions M
#extensions -- 6300
terminal = value \ lines get "candidates/camMin.txt";
terminalExtensions = set extensions * set terminal 
#terminalExtensions
registrationProblems = getExtensions(M,Registration=>true)
#registrationProblems -- 61
defect = set registrationProblems - (set registrationProblems * set terminal)

writeTable("examples/registration-problems-table.tex", registrationProblems,13)

-*
scan(toList defect, i->(p := M_i#"pl1p"; print p; viewPL1P p))
*-

     