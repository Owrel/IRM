%%%%%%%%%%%%%%%%%%%%
%Daniel Schreitter
%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% always stop after maxt steps
maxt(30).
% possible directions for the robot to move in
d(0,1). d(0,-1). d(1,0). d(-1,0). d(0,0).
% set a goal for each shelf

goal(N,X,Y) :- init(object(shelf, N), value(at,(X,Y) )).
%:- goal(R0,X,Y),goal(R1,X,Y),R1 !=R0. 

%need max of steps...
% basic initialisation
node(X,Y) :- init(object(node, N),value(at, (X,Y))).
allrobots(R) :- init(object(robot, R), _).
robot(R) :- init(object(robot, R), _).
robots(R2) :- init(object(robot, R2), _).


% generate a path for the robots that are not robot 1
{ at(X+DX,Y+DY,R,T+1) : d(DX,DY), node(X+DX,Y+DY) }1:- 
at(X,Y,R,T), node(X,Y), not goal(R,X,Y), T<MT, maxt(MT).

%at(X,Y,R2,T+1):-at(X,Y,R2,T),T < H,not at(_,_,R2,T+1),robots(R2),horizon(H).

:-at(X,Y,R1,T),at(X,Y,R2,T), R1 != R2.
:-at(X1,Y1,R1,T),at(X2,Y2,R2,T), R1 != R2,
at(X2,Y2,R1,T+1),at(X1,Y1,R2,T+1).

%do something about
:-at(X,Y,R1,T1),reached(X,Y,R2,T2),T2<T1, R1 != R2.


% check if all robots have reached their goal
reached(X,Y,R,T) :- at(X,Y,R,T), goal(R,X,Y) .
:- not reached(_,_,R,_), robots(R).

finaloccurs(object(robot,R),action(move,(DX,DY)),T+1) :- at(X,Y,R,T), at(X+DX,Y+DY,R,T+1), d(DX,DY).

horizon(H) :- H = #max{ 0; T : finaloccurs( _, _, T) }.
time(1..H) :-  horizon(H).

#minimize{ T : at(_,_,_,T) }.



#show finaloccurs/3.
%#show goal/3.

%#show horizon/1.
%#show robOn/3.
%#show reached/4.



