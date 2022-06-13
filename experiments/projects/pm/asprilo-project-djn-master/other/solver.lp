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
node(N,X,Y) :- init(object(node, N),value(at, (X,Y))).
robot(R) :- init(object(robot, R), _).
% build edges
edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), |X'-X|+|Y'-Y|==1.

% set robot starting position/ path
{ path(R,X,Y,X',Y') : edge(X,Y,X',Y') } = 1 :- init(object(robot, R), value(at, (X,Y))).

% generate a path for the robot
{ path(R,X,Y,X',Y') : edge(X,Y,X',Y') } = 1 :- path(R,_,_,X,Y), not goal(R,X,Y).

% check if all robots have reached their goal
reached(R) :- path(R,_,_,X,Y), goal(R,X,Y).
:- not reached(R), robot(R).

% create timesteps from path
at(R,X,Y,0) :- init(object(robot, R), value(at, (X,Y))).
at(R,X',Y',T+1) :- at(R,X,Y,T), path(R,X,Y,X',Y'), T<M, maxt(M). 

occurs(object(robot,R),action(move,(DX,DY)),T+1) :- at(R,X,Y,T), at(R,X+DX,Y+DY,T+1), d(DX,DY).

%#minimize{ T,R : reached(R,T), robot(R) }.
#minimize{ T,R : at(R, _, _, T) }.
%#minimize{ R,T : at(R, _, _, T) }.
%#minimize{ 1,R,X,Y : path(R,X,Y,X',Y') }.

%#show reached/2.
#show occurs/3.