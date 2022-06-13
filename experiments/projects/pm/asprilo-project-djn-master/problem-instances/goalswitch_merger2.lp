%%% Merger for basic problems using dimensions/layers %%%


%%% Initialization %%%

% Plan length
%horizon(H) :- H = #max{ 0; T : occurs( _, _, T) }.
horizon(15).
time(0..H) :-  horizon(H).
% find out at what time the first collision happens in each dimension
%edgecoltime(T, D) :- edgecollision(_, _, _, D), T = #min { T1 : edgecollision(_, _, T1, D)}, time(T).
%etime(T, D) :- edgecollision(_, _, T, D).
%edgecoltime(T, D) :- etime(_, D), T = #min{T1 : etime(T1, D) }.
%edgecoltime(1,1).
%nodecoltime(T, D) :- nodecollision(_, _, _, _, _, D), T = #min { T1 : nodecollision(_, _, _, _, T1, D)}, time(T).
%ntime(T, D) :- nodecollision(_, _, _, _, T, D).
%nodecoltime(T, D) :- ntime(_, D), T = #min{ T1 : ntime(T1, D) }.
% maximum depth
maxD(10).
% possible directions for the robot to move in
d(0,1). d(0,-1). d(1,0). d(-1,0).

% Set robot initial position
at(R, X, Y, 0, D) :- init(object(robot, R), value(at, (X,Y))), moves(R, _, _, _, D), maxD(D1), D <= D1.

% Domain switch
moves(R, DX, DY, T, 0) :- occurs(object(robot, R), action(move, (DX,DY)), T).
node(X,Y) :- init(object(node, N),value(at, (X,Y))).
robot(R) :- init(object(robot, R), _).

% Generate path
at(R, X+DX, Y+DY, T, D) :- at(R, X, Y, T-1, D), moves(R, DX, DY, T, D), time(T).
at(R, X, Y, T, D) :- at(R, X, Y, T-1, D), not moves(R, _, _, T, D), time(T).

% ------------------------------------------------------------------------------------------------------------------- %

%%% Collision detection

% 2 Robots on the same node (node collision)
nodecollision(X, Y, R1, R2, T, D) :- at(R1, X, Y, T, D), at(R2, X, Y, T, D), R1 < R2, maxD(D1), D <= D1, time(T).
%{ nctime(R1, R2, T1, D) } :- nodecollision(_, _, R1, R2, T1, D), nodecollision(_, _, R1, R2, T2, D), T1 < T2.
%:- nodecollision(_, _, R1, R2, _, D), not nctime(R1, R2, _, D).
%nct(T1, D) :- nctime(_, _, T1, D), nctime(_, _, T2, D), T1 < T2.
%:- nctime(_, _, _, D), not nct(_, D).
late_nodecoltime(T2, D) :- nodecollision(_, _, _, _, T1, D), nodecollision(_, _, _, _, T2, D), T1 < T2.
nodecoltime(T, D) :- nodecollision(_, _, _, _, T, D), not late_nodecoltime(T, D).

% 2 Robots want to swap position (edge collision)
edgecollision(R1, R2, T, D) :- at(R1, X1, Y1, T, D);
                            at(R2, X2, Y2, T, D);
                            at(R1, X2, Y2, T-1, D);
                            at(R2, X1, Y1, T-1, D);
                            maxD(D1), D <= D1;
                            R1 < R2, |X2-X1|+|Y2-Y1|==1, time(T).

late_edgecoltime(T2, D) :- edgecollision(_, _, T1, D), edgecollision(_, _, T2, D), T1 < T2.
edgecoltime(T, D) :- edgecollision(_, _, T, D), not late_edgecoltime(T, D).

%%% Solve collision conflict:
collision(1, T1, D) :- nodecoltime(T1, D), edgecoltime(T2, D), T1 < T2.
collision(1, T, D) :- nodecoltime(T, D), not edgecoltime(_, D).
collision(2, T2, D) :- nodecoltime(T1, D), edgecoltime(T2, D), T2 <= T1.
collision(2, T, D) :- edgecoltime(T, D), not nodecoltime(_, D).
:- collision(1, _, D), collision(2, _, D).


% Define who has to wait
wait(R2, R1, T, D) :- nodecollision(X, Y, R1, R2, T, D), R1 < R2, collision(_, T, D).                     

% Define who has to evade
evade(R2, R1, T, D) :- edgecollision(R1, R2, T, D), R1 < R2, collision(_, T, D).

% ------------------------------------------------------------------------------------------------------------------- %

%%%% Create new dimension with the new move commands:   %%%%

%%% Node collision solving: %%%
%% Robots that dont have to wait (plan remains unchanged):
% all moves get copied into new dimension
moves(R, DX, DY, T, D+1) :- moves(R, DX, DY, T, D), not wait(R, _, _, D), collision(1, _, D), time(T).

%% robots that have to wait (plan needs to change):
% moves prior to collision get copied into new dimension
moves(R, DX, DY, T1, D+1) :- wait(R, _, T, D), moves(R, DX, DY, T1, D), T1 < T, time(T).

% Push all movement starting at the time of nodecollision back X timesteps, where X is the number of waits
numwait(R, X, D) :- X = #count{ R1, T : wait(R, R1, T, D) }, wait(R, _, _, D).
moves(R, DX, DY, T1+DT, D+1) :- wait(R, _, T, D), numwait(R, DT, D), moves(R, DX, DY, T1, D), T1 >= T, time(T), time(T1).

% ------------------------------------------------------------------------------ %

%%% Edge collision solving: %%%
%% Either create evade movement or switch plans!

%%% create evade movement: choose 1 direction to evade in then move back to original position
%{ evades(R2, DX1, DY1, T, D) : d(DX1, DY1), (DX,DY) != (DX1,DY1), node(X+DX1,Y+DY1) } 1 :- evade(R2, _, T, D);
%                                                                                            moves(R2, DX, DY, T, D);
%                                                                                            at(R2, X, Y, T-1, D).

%% Robots that have to evade(plan needs to change):
% moves prior to collision get copied into new dimension
%moves(R, DX, DY, T1, D+1) :- evades(R, _, _, T, D), moves(R, DX, DY, T1, D), T1 < T.

% evade in chosen direction and immediately go back
%moves(R, DX, DY, T, D+1) :- evades(R, DX, DY, T, D).
%moves(R, -DX, -DY, T+1, D+1) :- evades(R, DX, DY, T, D).

% Push all movement of the evading robot starting at the time of the edgecollision back 2 timesteps (after 2 steps of evading the robot is back at his original position)
%moves(R, DX, DY, T1+2, D+1) :- evades(R, _, _, T, D), moves(R, DX, DY, T1, D), T1 >= T.

%% Robots that dont have to evade
% all moves get copied into new dimension unchanged
%moves(R, DX, DY, T, D+1) :- moves(R, DX, DY, T, D), not evades(R, _, _, _, D), evades(_, _, _, _, D), not wait(R, _, T, D).

% ---------------------------------------------------------------------------------- %

%%% alternatively switch goals %%%
goalswitch(R1, R2, T, D) :- evade(R1, R2, T, D).

%% Robots involved in conflict:
% copy all movement prior to conflict into new dimension
moves(R, DX, DY, T1, D+1) :- goalswitch(R, _, T, D), moves(R, DX, DY, T1, D), T1 < T.
moves(R, DX, DY, T1, D+1) :- goalswitch(_, R, T, D), moves(R, DX, DY, T1, D), T1 < T.

% switch plans of robots involved in conflict
moves(R2, DX, DY, T1-1, D+1) :- goalswitch(R1, R2, T, D), moves(R1, DX, DY, T1, D), T1 > T.
moves(R1, DX, DY, T1-1, D+1) :- goalswitch(R1, R2, T, D), moves(R2, DX, DY, T1, D), T1 > T.

%% Robots not involved in conflict:
% copy all movement into new dimension
moves(R, DX, DY, T, D+1) :- moves(R, DX, DY, T, D), not goalswitch(R, _, _, D), not goalswitch(_, R, _, D), collision(2, _, D), not wait(R, _, _, D), time(T).
%moves(R, DX, DY, T, D+1) :- moves(R, DX, DY, T, D), goalswitch(R1, R2, T, D), R1 != R, R2 != R, not wait(R, _, _, D).

% only one strategy can be applied per conflict
%:- evades(R, DX, DY, T, D), goalswitch(R, R2, T, D).
% there has to be at least one strategy applied per conflict
%:- evade(R1, R2, T, D), not evades(R1, _, _, T, D), not goalswitch(R1, R2, T, D).

% ------------------------------------------------------------------------------------------------------------------- %

%%% create final plan %%%
finalD(D) :- D = #max{ D1 : moves(_, _, _, _, D1) }.%, maxD(D2), D < D2.
final(R, DX, DY, T) :- moves(R, DX, DY, T, D), finalD(D), time(T).
:- finalD(D), maxD(D1), D > D1.


%:- moves(R, _, _, _, _), not robot(R).
%:- moves(_, DX, DY, _, _), not d(DX,DY).
%:- moves(_, _, _, _, D), maxD(D1), D > D1.

#minimize{ D : finalD(D) }.

#show finalD/1.
#show final/4.
#show moves/5.
%#show evades/5.
%#show evade/4.
#show goalswitch/4.
#show edgecollision/4.
#show nodecollision/6.
#show collision/3.  
#show wait/4.
%#show numwait/3.
%#show at/5.
%#show nodecoltime/2.
%#show nctime/4.
%#show nct/2.
%#show edgecoltime/2.
%#show occurs(object(robot,R), action(move, (DX,DY)), T) : final(R, DX, DY, T).
