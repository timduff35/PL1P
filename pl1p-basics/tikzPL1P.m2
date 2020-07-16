needs "./service-functions.m2"
tikzPL1P = method(Options=>{File=>stdio,Vertical=>false})
tikzPL1P List := o -> pl1p -> (
    out := o#File; 
    out <<  "%%% begin PL1P %%%\n";
    checkPL1P pl1p;
    viewNum := 0;
    if o.Vertical then out << "\\begin{tabular}{c}" << endl;
    for view in getViews pl1p do (
    	shade := "[opacity=0.2]"; 
    	drawVisPoint := i -> ("\\draw" | if (getVisPoints view)#i>0 then "" else shade);
    	drawVisLine := i -> ("\\draw" | if (getVisLines view)#i>0 then "" else shade);
    	out << "\\resizebox{0.1\\textwidth}{!}{" << endl;
    	out <<  "\\begin{tikzpicture}[thick]" << endl;
    	ptsNOpins := getPointsWithoutPins pl1p;
    	freeLines := getFreeLines pl1p;
    	radius := 0.25;
    	a0 := 0;
    	irrational := 13+pi;
    	if #ptsNOpins > 0 then (
	    ptRad := if #ptsNOpins > 7 then 1.7*radius else radius;
    	    angle := 360./#ptsNOpins;
    	    scan(#ptsNOpins, i-> out <<  drawVisPoint ptsNOpins#i << " (" << a0 + i*angle << ":" << ptRad << ") node {};" << endl);
	    radius = radius + 0.5;
	    );
    	ptsWITHpins := getPointsWithPins pl1p;
    	if #ptsWITHpins > 0 then (
	    a0 = a0 + irrational;
    	    angle = 360./#ptsWITHpins;
	    scan(#ptsWITHpins, i-> (
	    	    out <<  drawVisPoint ptsWITHpins#i << " (" << a0 + i*angle << ":" << radius << ") node {};" << endl;
	    	    p := ptsWITHpins#i;
	    	    pins := getPins(pl1p,p);
    	    	    spread'angle := min(0.9*angle,90);
	    	    pin'angle := spread'angle/#pins;  
	    	    scan(#pins, j-> 
			out <<  drawVisLine pins#j << " (" << a0+i*angle << ":" << radius << ")" 
			<< "-- (" << a0 + i*angle - spread'angle/2 + pin'angle*j << ":" << radius + 0.5 << ") node[ghost] {}; " << endl
			)
	    	    ));
	    radius = radius + 1;
    	    );
    	if #freeLines > 0 then (
	    a0 = a0 + irrational;
    	    angle = 360./#freeLines;
	    rightAng := if (#freeLines == 1) then min(angle,90) else angle;
    	    scan(#freeLines, i-> 
	    	out <<  drawVisLine freeLines#i << " (" << a0 + i*angle << ":" << radius << ") node[ghost] {} "  
	    	<< "-- (" << a0 + (i+0.5)*rightAng << ":" << radius << ") node[ghost] {};" << endl
	    	);    
	    );
    	out <<  "\\end{tikzpicture}" << endl;
    	out << "}" << endl;
    	if (viewNum < 2) then (if o.Vertical then out << "\\\\"; viewNum = viewNum + 1);
    	);
    if o.Vertical then out << "\\end{tabular}" << endl;
    out <<  "%%% end PL1P %%%\n"
    )   

viewPL1P = method(Options=>{Vertical=>false})
viewPL1P List := o -> pl1p -> (
    filename := temporaryFileName ();
    print filename;
    out := openOut (filename | ".tex");
    out << 
///
\documentclass{minimal}
\usepackage{graphicx}
\usepackage[paperwidth=5in,paperheight=2.5in,margin=0.5in]{geometry}
\usepackage{tikz}
% Define style for nodes
\tikzstyle{every node}=[circle, draw, fill=black,
                        inner sep=0pt, minimum width=6pt]
\tikzstyle{ghost}=[circle, draw, fill=white, opacity=0,
                        inner sep=0pt, minimum width=4pt]
///
;
    out << "\\begin{document}";
    tikzPL1P(pl1p,File=>out,Vertical=>o.Vertical); 
    out << "\\end{document}";      
    close out;
    run ("cd `dirname "|filename|"`; pdflatex "|filename|".tex > /dev/null; evince "|filename|".pdf");
    )

end-----------------------------------------------------------------------------

-* old way:
run "M2 --no-prompts --stop --no-debug --silent -q > 89993.tex << !
load \"tikzPL1P.m2\"; tikzPL1P getPL1P 89993
!"
*-

restart
load "tikzPL1P.m2"
pl1p=getPL1P(8728,"./../problems/")
viewPL1P(pl1p,Vertical=>true)
f = openOut "tes"
tikzPL1P(pl1p,File=>f)
close f

restart
load "tikzPL1P.m2"
no = 89993;
f = openOut(toString no | ".tex");
tikzPL1P(getPL1P(no, "../problems/"), File=>f)
close f

restart
load "tikzPL1P.m2"
viewPL1P(getPL1P(89993,"./../problems/"),Vertical=>true)
<< "\nthe ultimate hedgehog (partially seen) \n\n"
pl1p = {
    {0,0,0,0,0,0,0,0}
    ,
    {
    {{1,0,1,0,1,1,1,1},{1}},
    {{1,1,0,1,0,0,1,1},{1}},
    {{1,1,1,1,1,1,0,0},{0}}
    }
}    
tikzPL1P pl1p

<< "\ncleveland\n\n"
pl1p = {
    {-1}
    ,
    {
    {{1},{1,1,1}},
    {{1},{1,1,1}},
    {{1},{1,1,1}}
    }
}    
tikzPL1P pl1p


<< "\nchicago\n\n"
pl1p = {
    {0,1}
    ,
    {
    {{1,1},{1,1,1}},
    {{1,1},{1,1,1}},
    {{1,1},{1,1,1}}
    }
}    
tikzPL1P pl1p
viewPL1P pl1p


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
viewPL1P pl1p

