needs "../pl1p-basics/service-functions.m2"
needs "../pl1p-basics/tikzPL1P.m2"

plps = new HashTable from {
"exa1" => {{0,0}, {
        {{1,1},{1}},
        {{1,0},{0}},
        {{0,1},{0}}
        }},
"all-elements" => getPL1P 6778,
"symmetric-pl0p" => getPL1P 46747,
"89993" => getPL1P 89993,
"89993-augmented" => (
    p := getPL1P 89993;
    c := getViews p;
    {{-1} | getLines p, -- add a free line
    	{
	    {{1}|c#0#0,c#0#1}, -- visible
    	    {{1}|c#1#0,c#1#1}, -- visible 
    	    {{0}|c#2#0,c#2#1} -- invisible
	    }}     	
    ),
"joe-with-dangling-pin" => getPL1P 6723
}
end 

restart
needs "examples/presentation-examples.m2"
-*
scan(keys plps, p->(print p; viewPL1P plps#p))
*-

-- create tex tikz code to include
for p in keys plps do (
    f := openOut(p|".tex");
    tikzPL1P(plps#p, File=>f);
    close f
    )
 