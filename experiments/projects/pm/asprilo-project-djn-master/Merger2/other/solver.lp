%%% M-Domain Solver %%%
%
% Jakob Westphal
%%%

% always stop after maxt steps
maxt(20).
% possible directions for the robot to move in
d(0,1). d(0,-1). d(1,0). d(-1,0).
% set a goal for each shelf
goal(N,X,Y) :- init(object(shelf, N), value(at,(X,Y))).
% basic initialisation
node(X,Y) :- init(object(node, N),value(at, (X,Y))).
robot(R) :- init(object(robot, R), _).

% set robot starting position
at(X,Y,R,0) :- init(object(robot, R), value(at, (X,Y))).

% generate a path for the robot
{ at(X+DX,Y+DY,R,T+1) : d(DX,DY), node(X+DX,Y+DY) }1:- at(X,Y,R,T), node(X,Y), not goal(R,X,Y), T<MT, maxt(MT).

% check if all robots have reached their goal
reached(R,T) :- at(X,Y,R,T), goal(R,X,Y).
:- not reached(R,_), robot(R).

occurs(object(robot,R),action(move,(DX,DY)),T+1) :- at(X,Y,R,T), at(X+DX,Y+DY,R,T+1), d(DX,DY).

#minimize{ T,R : reached(R,T), robot(R) }.
%#show reached/2.
#show occurs/3.