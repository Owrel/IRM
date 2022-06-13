node(X,Y) :- init(object(node,N),value(_,(X,Y))).
shelf(S,(X,Y)) :- init(object(shelf,S), value(at,(X,Y))).
start(R,(X,Y),0) :- init(object(robot,R), value(at,(X,Y))).
robot(R) :- init(object(robot,R), _).

#show robot/1.
#show node/2.
#show shelf/2.
#show start/3.

