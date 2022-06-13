%%%---------------------------------%%%
% test for preemptive(optimal?) planswitching
% Jakob Westphal
%%%---------------------------------%%%

%%% ----------------------- setup -------------------------------------------- %%%
%horizon(65).
horizon(H) :- H = #max{ 0; T : occurs( _, _, T) }.
time(0..H) :-  horizon(H).

at(R, X, Y, 0) :- init(object(robot, R), value(at, (X,Y))).
moves(R, DX, DY, T) :- occurs(object(robot, R), action(move, (DX,DY)), T).
node(X,Y) :- init(object(node, N),value(at, (X,Y))).
robot(R) :- init(object(robot, R), _).

at(R, X+DX, Y+DY, T) :- at(R, X, Y, T-1), moves(R, DX, DY, T), time(T).



%%% ------------------------ plan switching ------------------------------------- %%%
% detect if 2 robots are ever on the same node
same_pos(R1, R2, X, Y, T1, T2) :- robot(R1), robot(R2), R1 < R2, at(R1, X, Y, T1), at(R2, X, Y, T2), time(T1), time(T2).
same_pos(R2, R1, X, Y, T2, T1) :- same_pos(R1, R2, X, Y, T1, T2).

% find the earliest time that 2 specific robots are on the same position
late_pos(R1, R2, X, Y, T1) :- same_pos(R1, R2, X, Y, T1, T2), same_pos(R1, R2, X', Y', T1', T2'), T1 > T1'.
earliest_pos(R1, R2, X, Y, T, T2) :- same_pos(R1, R2, X, Y, T, T2), not late_pos(R1, R2, X, Y, T).

% randomly add switches between robots
{ switch(R1, R2, X, Y, T1, T2) } :- robot(R1), robot(R2), earliest_pos(R1, R2, X, Y, T1, T2).

% only one switch per robot
:- switch(R1, R2, _, _, _, _), switch(R1, R2', _, _, _, _), R2 != R2'.
% two robots can not switch to the same robot
:- switch(R1, R2, _, _, _, _), switch(R1', R2, _, _, _, _), R1 != R1'.
:- switch(R1, R2, _, _, _, _), not switch(R2, _, _, _, _, _).


%%% ----------------------- create new movement ---------------------------------- %%%
% Movement after switch
movement(R1, DX, DY, (T1+(T'-T2)) ) :- switch(R1, R2, _, _, T1, T2), moves(R2, DX, DY, T'), T' > T2.
% Movement before switch
movement(R1, DX, DY, T) :- moves(R1, DX, DY, T), switch(R1, R2, _, _, T1, T2), T <= T1.
% if no switch just copy the plan
movement(R, DX, DY, T) :- moves(R, DX, DY, T), not switch(R, _, _, _, _, _).


%%% ------------------- minimize over arrival time of each robot ------------------- %%%
% minimize over the timesteps of each robot
#minimize{ T,R : movement(R, _, _, T), robot(R) }.


#show.
%#show switch/6.
%#show final/2.
%#show movement/4.
%#show horizon/1.
%#show edgecollision/3.
%#show same_pos/6.
%#show collision/2.
#show occurs(object(robot,R), action(move, (DX,DY)), T) : movement(R, DX, DY, T).