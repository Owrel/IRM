%#const horizon=1.

position(R,(X,Y),0):-start(R,(X,Y),0), R == robot.

horizon(horizon).

time(1..H):- horizon(H).

direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(DX,DY),(X+DX,Y+DY)) :- node(X,Y), direction((DX,DY)), node(X+DX,Y+DY).

{ move(R,D,T) : direction(D) } 1 :- robot(R), time(T), R ==robot.

% - move/3 ----------------------------------------------------------------------
position(R,C,T) :- move(R,D,T), position(R,C',T-1),     nextto(C',D,C).
                :- move(R,D,T), position(R,C ,T-1), not nextto(C ,D,_).

% - inertia ---------------------------------------------------------------------
position(R,C,T) :- position(R,C,T-1), not move(R,_,T), robot(R), time(T).

% - reaching for goal -----------------------------------------------------------
processed(R,S) :- assigned(R,S),robot(R), shelf(S,C), position(R,C,H), 
    horizon(H).
processed(R)   :- processed(R,S).
:- assigned(R,S), not processed(R), robot == R.

#show position/3.
