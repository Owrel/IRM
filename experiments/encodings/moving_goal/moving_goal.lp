node(1..5,1..5).

time(0..2).

robot(1).

goal(1,1,1).
init(2,2,1).
direction((1,0)).
direction((-1,0)).
direction((0,1)).
direction((0,-1)).

{path((X,Y),(X+DX,Y+DY),R,0) : robot(R), init(X,Y,R), node(X+DX,Y+DY), direction((DX,DY))}=1.
{move((DX,DY),R,T): direction((DX,DY))}=1 :- time(T),  robot(R).
path((X,Y),(X+DX,Y+DY),R,T) :- path(_,(X,Y),N,T-1), move((DX,DY),R,T), node(X+DX,Y+DY).

:- move(_,R,T), not path(_,_,R,T).

goalReached(R,T) :- path(_,(X,Y),R,T), goal(X,Y,R).
:- not goalReached(R,_), robot(R).

#show path/4.
#show goalReached/2.