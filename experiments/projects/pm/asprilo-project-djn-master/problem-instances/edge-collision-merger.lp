%%% Merger for basic problem of edge collision with evades using layers %%%

%%% Initialization %%%

% Plan length
horizon(H) :- H = #max{ 0; T : occurs( _, _, T) }.
time(0..H) :-  horizon(H).
% find out at what time the first collision happens in each dimension
edgecoltime(T, D) :- edgecollision(_, _, _, D), T = #min { T1 : edgecollision(_, _, T1, D)}.
%nodecoltime(T, D) :- nodecollision(_, _, _, _, _, D), T = #min { T1 : nodecollision(_, _, _, _, T1, D)}.
% maximum depth
maxD(5).
% possible directions for the robot to move in
d(0,1). d(0,-1). d(1,0). d(-1,0).

% Set robot initial position
at(R, X, Y, 0, D) :- init(object(robot, R), value(at, (X,Y))), moves(R, _, _, _, D).

% Domain switch
moves(R, DX, DY, T, 0) :- occurs(object(robot, R), action(move, (DX,DY)), T).
node(X,Y) :- init(object(node, N),value(at, (X,Y))).
robot(R) :- init(object(robot, R), _).

% Generate path
at(R, X+DX, Y+DY, T, D) :- at(R, X, Y, T-1, D), moves(R, DX, DY, T, D).
at(R, X, Y, T, D) :- at(R, X, Y, T-1, D), not moves(R, _, _, T, D), time(T).


%%% Collision detection

% 2 Robots on the same node (node collision)
%nodecollision(X, Y, R1, R2, T, D) :- at(R1, X, Y, T, D), at(R2, X, Y, T, D), R1 < R2, maxD(D1), D <= D1.

% 2 Robots want to swap position (edge collision)
edgecollision(R1, R2, T, D) :- at(R1, X1, Y1, T, D);
                            at(R2, X2, Y2, T, D);
                            at(R1, X2, Y2, T-1, D);
                            at(R2, X1, Y1, T-1, D);
                            maxD(D1), D <= D1;
                            R1 < R2, |X2-X1|+|Y2-Y1|==1.


%%% Solve collision conflict:

% Define who has to wait
%wait(R2, R1, T, D) :- nodecollision(X, Y, R1, R2, T, D), R1 < R2, nodecoltime(T, D).                     

% Define who has to evade
evade(R2, R1, T, D) :- edgecollision(R1, R2, T, D), R1 < R2, edgecoltime(T, D). 


%%% Create new dimension with the new move commands:

%% Robots that dont have to wait/evade (plan remains unchanged):
% all moves get copied into new dimension
%moves(R, DX, DY, T, D+1) :- moves(R, DX, DY, T, D), not wait(R, _, _, D), nodecollision(_, _, _, _, _, D).
moves(R, DX, DY, T, D+1) :- moves(R, DX, DY, T, D), not evade(R, _, _, D), edgecollision(_, _, _, D).

%% Robots that have to wait (plan needs to change):
% moves prior to collision get copied into new dimension
%moves(R, DX, DY, T1, D+1) :- wait(R, _, T, D), moves(R, DX, DY, T1, D), T1 < T.
moves(R, DX, DY, T1, D+1) :- evade(R, _, T, D), moves(R, DX, DY, T1, D), T1 < T.

% create new evade movement (evade in any direction and then return to original node)
{ evades(R2, DX1, DY1, T, D) : d(DX1, DY1), node(X+DX1, Y+DY1), (DX,DY) != (DX1,DY1) } = 1 :- evade(R2, R1, T, D), moves(R2, DX, DY, T, D), at(R2, X, Y, T-1, D).  % chose one direction to evade in
moves(R, DX, DY, T, D+1) :- evades(R, DX, DY, T, D).
moves(R, -DX, -DY, T+1, D+1) :- evades(R, DX, DY, T, D).

% Push all movement starting at the time of nodecollision back X timesteps, where X is the number of waits
%numwait(R, X, D) :- X = #count{ R1, T : wait(R, R1, T, D) }, wait(R, _, _, D).
%moves(R, DX, DY, T1+DT, D+1) :- wait(R, _, T, D), numwait(R, DT, D), moves(R, DX, DY, T1, D), T1 >= T.

% Push all movement starting at the time of the edgecollision back 2 timesteps (after 2 steps of evading the robot is back at his original position)
moves(R, DX, DY, T1+2, D+1) :- evade(R, _, T, D), moves(R, DX, DY, T1, D), T1 >= T.

%%% create final plan %%%
finalD(D) :- D = #max{ D1 : moves(_, _, _, _, D1) }.
final(R, DX, DY, T) :- moves(R, DX, DY, T, D), finalD(D).


#minimize{ D : finalD(D) }.

#show finalD/1.
#show final/4.
%#show moves/5.
%#show edgecollision/4.
%#show nodecollision/6.
%#show wait/4.
%#show at/5.
%#show nodecoltime/2.
%#show edgecoltime/2.