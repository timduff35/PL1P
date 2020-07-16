load "../problemBuilder/worldBuilder.m2"
findDir = i -> (
    dir := toString (i // 1000); 
    while #dir < 3 do dir = "0" | dir;
    dir
    ) 

files = select(readDirectory ".", f->match(".pl1p", f))

for filename in files do (
    record := new MutableHashTable from value get filename;
    if not record#?"rank check" then (
    	<< "processing " << filename << endl;
    	record#"rank check" = elapsedTiming rankCheck record#"pl1p";
    	filename << toExternalString new HashTable from record;
    	filename << close;
    	);
    )
end -----------------------------------------------------

restart
load "checkPL1P.m2"

