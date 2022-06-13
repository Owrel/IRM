%%%---------------------------------%%%
% test for preemptive(optimal?) waiting
% Jakob Westphal
%%%---------------------------------%%%

%%% ------------------------------- setup ------------------------------------------ %%%
maxwait(12).
horizon(H+W) :- H = #max{ 0; T : occurs( _, _, T) }, maxwait(W).
time(0..H) :-  horizon(H).

at(R, X, Y, 0) :- init(object(robot, R), value(at, (X,Y))).
moves(R, DX, DY, T) :- occurs(object(robot, R), action(move, (DX,DY)), T).
node(X,Y) :- init(object(node, N),value(at, (X,Y))).
robot(R) :- init(object(robot, R), _).
d(1,0). d(0,1). d(-1,0). d(0,-1).

at(R, X+DX, Y+DY, T) :- at(R, X, Y, T-1), moves(R, DX, DY, T), time(T).


%%% --------------------------------- waiting -------------------------------------- %%%
% add random wait times for robots that are involved in a collision
{ wait(R, T) : time(T), maxwait(W), T<W } = 1 :- robot(R).
% create new movement depending on waittime
finalplan(R, 0, 0, T+1) :- wait(R, T1), time(T), T < T1.
finalplan(R, DX, DY, T+T1) :- moves(R, DX, DY, T), wait(R, T1), time(T), d(DX, DY).


%%% ----------------------------- create final plan -------------------------------- %%%
% new positions
finalpos(R, X, Y, 0) :- at(R, X, Y, 0).
finalpos(R, X+DX, Y+DY, T) :- finalpos(R, X, Y, T-1), finalplan(R, DX, DY, T), time(T), node(X, Y).


%%% ------------------------------- constraints ------------------------------------ %%%
% remember endposition for robots that have reached their goal
endpos(R, X, Y, T) :- finalpos(R, X, Y, T), not finalpos(R, _, _, T+1), node(X, Y), time(T).
% check if there are any nodecollisions left
:- finalpos(R1, X, Y, T), finalpos(R2, X, Y, T), R1 < R2, time(T), node(X, Y).
:- finalpos(R1, X, Y, T), endpos(R2, X, Y, T1), T > T1, time(T), node(X, Y).
:- finalpos(R1, X1, Y1, T), finalpos(R2, X2, Y2, T), finalpos(R1, X2, Y2, T-1), finalpos(R2, X1, Y1, T-1), R1<R2, |X2-X1|+|Y2-Y1|==1, time(T).


%%% ----------------- minimize over the arrival time of each robot ----------------- %%%
% minimize over the timesteps of each robot
#minimize{ T,R : finalplan(R, _, _, T), robot(R) }.

#show.
%#show wait/2.
%#show final/2.
%#show horizon/1.
%#show edgecollision/2.
%#show finalpos/4.
%#show finalplan/4.
%#show endpos/4.
#show occurs(object(robot,R), action(move, (DX,DY)), T) : finalplan(R, DX, DY, T).