needs "../pl1p-basics/service-functions.m2"
needs "../pl1p-basics/tikzPL1P.m2"
needs "../degree-computation/runMonodromy.m2"
setDefault(tStepMin=>1e-8)
--defaultPrecision = 80
setDefault(maxCorrSteps=>2)
setDefault(CorrectorTolerance=>1e-7)
pl0pIDs={6722, 6724, 6725, 6767, 6779, 6780, 6785, 7024, 7025, 7045, 8726, 8728, 8729, 8790, 8791, 8796, 8797, 9574, 9575, 9595, 9596, 9660, 15460, 15461, 15468, 15635, 46729, 46741, 46742, 46747, 46980, 46981, 46986, 46987, 47007, 49212, 49213, 49233, 49234, 49298, 49303, 63248, 63249, 63256, 63423, 63428, 63831, 131134, 131139, 131167, 132014}
firstLinepl0ps = apply(pl0pIDs, ID -> (
	first lines get(
	    "./pl0p-monodromy-results/monodromy-result-pl1p-" | toString(pad(ID,6))| "-target-0000"
	    )
	)
)
end--

for ID in pl0pIDs do elapsedTime runMonodromy(ID,"./pl0p-monodromy-results/",
--    Target=>250, 
    ProblemDirectory=>"../problems/"
    )

restart
needs "pl0p.m2"

degs = apply(pl0pIDs, firstLinepl0ps, (ID, firstLine) -> (
	data := value \ separate(",", firstLine);
	(ID, {data#0, data#1})
	)
)

f = openOut "pl0p-table.tex"	
f << "\\begin{tabular}{|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|}" << endl
f << "\\hline " << endl
for i from 0 to 2 do (
    for d from 17*i to 17*(i+1)-1 do (
	    ID := first(degs#d);
--	    f << "\\begin{resizebox}{!}{0.1\\textwidth}{" << endl;
	    tikzPL1P(getPL1P(ID,"../problems/"), File=>f);
	    f << "}" << endl;
	    if (d%17 == 16) then f << "\\\\" else f << "&" << endl;
	    );
--	f << "\\hline " << endl;
	for d from 17*i to 17*(i+1)-1 do (
	    deg := first last(degs#d);
	    f << deg;
	    if (d%17 == 16) then f << "\\\\" else f << "&";
	);
    	f << "\\hline " << endl;
    )
f << "\\hline" << endl
f << "\\end{tabular}"
close f


rerunIDs = first \ select(
    apply(pl0pIDs, firstLinepl0ps, (ID, firstLine) -> (
	    data := value \ separate(",", firstLine);
	    (ID, {data#0, data#1})
	    )
    	),
    p -> (
	(first last p =!= last last p) or
	((first last p)%8 =!= 0) or
	(first last p < 100)
    )
)

for ID in rerunIDs do elapsedTime runMonodromy(ID, "./pl0p-monodromy-results/",
--    Target=>250, 
    Filter => false,
    ProblemDirectory=>"../problems/",
    Verbose=>true,
    Formulation=>"world",
    NumberOfNodes => 5
    )

runMonodromy(first rerunIDs, "./pl0p-monodromy-results/",
--    NumberOfNodes => 3, NumberOfEdges => 2,
    Formulation=>"world",
    Verbose=>true,
--    Filter=>true,
     ProblemDirectory=>"../problems/"
    )


nonconsensus = {
    6779,
    6780,
    8790,
    8790,
    8796,
    8797,
    9574,
    46729
    }