%%% Merger for basic problem of node collision using layers %%%

%%% Initialization %%%

% Plan length
horizon(H) :- H = #max{ 0; T : occurs( _, _, T) }.
time(0..H) :-  horizon(H).
coltime(T, D) :- collision(_, _, _, _, _, D), T = #min { T1 : collision(_, _, _, _, T1, D)}.
%maxD(D) :- D = #max{ D1 : moves(_, _, _, _, D1) }.
maxD(5).
%dim(0). dim(1). dim(2). dim(3). dim(4).
%dim(0..D) :- maxD(D).
robot(R) :- init(object(robot, R), _).

% Set robot initial position
at(R, X, Y, 0, D) :- init(object(robot, R), value(at, (X,Y))), moves(R, _, _, _, D).

% Domain switch
moves(R, DX, DY, T, 0) :- occurs(object(robot, R), action(move, (DX,DY)), T).

% Generate path
at(R, X+DX, Y+DY, T, D) :- at(R, X, Y, T-1, D), moves(R, DX, DY, T, D).
at(R, X, Y, T, D) :- at(R, X, Y, T-1, D), not moves(R, _, _, T, D), time(T).


%%% Collision detection

% 2 Robots on the same node (node collision)
collision(X, Y, R1, R2, T, D) :- at(R1, X, Y, T, D), at(R2, X, Y, T, D), R1 < R2, maxD(D1), D <= D1.


%%% Solve collision conflict:

% Define who has to wait
wait(R2, R1, T, D) :- collision(X, Y, R1, R2, T, D), R1 < R2, coltime(T, D).                     
  

%%% Create new dimension with the new move commands:

%% Robots that dont have to wait (plan remains unchanged):
% all moves get copied into new dimension
moves(R, DX, DY, T, D+1) :- moves(R, DX, DY, T, D), not wait(R, _, _, D), collision(_, _, _, _, _, D).

%% Robots that have to wait (plan needs to change):
% moves prior to collision get copied into new dimension
moves(R, DX, DY, T1, D+1) :- wait(R, _, T, D), moves(R, DX, DY, T1, D), T1 < T.

% Push all movement starting at the time of collision back X timesteps, where X is the number of waits
numwait(R, X, D) :- X = #count{ R1, T : wait(R, R1, T, D) }, wait(R, _, _, D).
moves(R, DX, DY, T1+DT, D+1) :- wait(R, _, T, D), numwait(R, DT, D), moves(R, DX, DY, T1, D), T1 >= T.

% initial position in new dimension
%at(R, X, Y, 0, D) :- moves(R, _, _, _, D), init(object(robot, R), value(at, (X,Y))).


%%% create final plan %%%
finalD(D) :- D = #max{ D1 : moves(_, _, _, _, D1) }.
final(R, DX, DY, T) :- moves(R, DX, DY, T, D), finalD(D).


%#show moves/5.
#show collision/6.
%#show wait/4.
#show finalD/1.
#show final/4.
%#show numwait/3.
%#show at/5.
%#show coltime/2.
%#show maxD/1.
%#show dim/1.