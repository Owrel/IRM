%%%%%%%%%%%%%%%%%%%%
%Daniel Schreitter
%%%%%%%%%%%%%%%%%%%%%%
node(X,Y) :- init(object(node, N),value(at, (X,Y))).
maxsStep(T):-moves(R,_,_,T),not moves(R,_,_,T+1).
maxStep(T):- T = #max{X : maxsStep(X)}.
robot(R) :- init(object(robot, R), _).


% set robot starting position
at(X,Y,R,0) :- init(object(robot, R), value(at, (X,Y))).

moves(R, DX, DY, T) :- occurs(object(robot, R), action(move, (DX,DY)),T).
{nat( X+DX, Y+DY,R, T)}1 :- nat( X, Y,R, T-1), moves(R, DX, DY, T).

nat(X,Y,R,0) :- init(object(robot, R), value(at, (X,Y))).

%collison in another layer?
collison(R1,R2,T,X,Y ):-nat(X,Y,R1,T),nat(X,Y,R2,T), R1 < R2.
collison(R1,R2,T +1,X1,Y1):-nat(X1,Y1,R1,T),nat(X2,Y2,R2,T), R1 < R2,
nat(X2,Y2,R1,T+1),nat(X1,Y1,R2,T+1).

collison(R1,R2,T1,X,Y):-nat(X,Y,R1,T1),fp(X,Y,R2,T2),T1 > T2, R1 != R2.

avoidcollison(R1,R2,T):-collison(R1,R2,T,X,Y),node(X+DX,Y+DY),d(DX,DY),
not nat(X+DX,Y+DY,_,T+1),not avoidcollison(R3,_,T),R3 != R1,robot(R3) .


:-collison(_,R2,T1,_,_),nat(_,_,R2,T1).
:-collison(R,_,T1,_,_),nat(_,_,R,T1),not avoidcollison(R,_,T1).
%spezifieren

%there is a free node in reach true last stand
%vektorcollison..


d(0,1). d(0,-1). d(1,0). d(-1,0).

at(X,Y,R,T):- nat(X,Y,R,T).

#maximize{  T:tnt(T) }.
tnt(T) :- T ={nat(_,_,_,_)} . 

%if robot stands still continue standing in robon

%Frag ob da noch ein roboter drauf ist.
%finalpositon of robot
fp(X,Y,R,T):- nat(X,Y,R,T),not nat(_,_,R,T+1).

%#show laststandrobot/4.
%#show tnt/1.

%#show avoidcollison/3.

%#show goal/3.
#show at/4.
%#show nat/4.
%#show horizon/1.
%#show robOn/3.
%#show reached/4.




