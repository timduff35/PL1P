restart
needs "runMonodromy.m2"

pl1p = getPL1P 8727 -- looks like it is from Cleveland
viewPL1P pl1p

setRandomSeed 0
degreePL1P 8727
-*
  node1: 368                                                                                                    
  node2: 367                                                                                                    
*-

setRandomSeed 1
degreePL1P 8727
-*
 node1: 1                                                                                                      
 node2: 0                                                                                                      
*-

setRandomSeed 2
degreePL1P 8727
-*
 node1: 368                                                                                                    
 node2: 360                                                                                                    
*-  