conflict_zone(X,Y) :- step(R,_,X,Y), step(R',_,X,Y), R!=R', not end(_,X,Y), not init(_,X,Y).
free_zone(X,Y) :- step(_,_,X,Y), not conflict_zone(X,Y).