conflict_zone(X,Y) :- position(R,(X,Y),_), position(R',(X,Y),_), R!=R', not shelf(_,(X,Y)), not start(_,(X,Y),0).
wait_zone(X,Y) :- position(_,(X,Y),_), not conflict_zone(X,Y).