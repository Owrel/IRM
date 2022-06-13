%%%---------------------------------%%%
% find all conflicts in a plan
% Jakob Westphal
%%%---------------------------------%%%

%%% ------------ setup -------------- %%%
horizon(H) :- H = #max{ 0; T : occurs( _, _, T) }.
time(0..H) :-  horizon(H).

at(R, X, Y, 0) :- init(object(robot, R), value(at, (X,Y))).
moves(R, DX, DY, T) :- occurs(object(robot, R), action(move, (DX,DY)), T).
node(X,Y) :- init(object(node, N),value(at, (X,Y))).
robot(R) :- init(object(robot, R), _).

at(R, X+DX, Y+DY, T) :- at(R, X, Y, T-1), moves(R, DX, DY, T), time(T).


%%% ----------- collisions ------------- %%%
% Nodecollision
nodecollision(R1, R2) :- at(R1, X, Y, T), at(R2, X, Y, T), R1 < R2, time(T).

% normal edge collision
edgecollision(R1, R2) :- at(R1, X1, Y1, T);
                        at(R2, X2, Y2, T);
                        at(R1, X2, Y2, T-1);
                        at(R2, X1, Y1, T-1);
                        R1 < R2, |X2-X1|+|Y2-Y1|==1, time(T).

% 2 robots switch places during 2 timesteps
nodeswitchcollision(R1, R2) :- at(R1, X1, Y1, T);
                        at(R2, X2, Y2, T);
                        at(R1, X2, Y2, T-2);
                        at(R2, X1, Y1, T-2);
                        R1 < R2, |X2-X1|+|Y2-Y1|==2, time(T).

% 1 robot reached his final position (is now sleeping) and another robot tries to pass over it
endpos(R, X, Y, T) :- at(R, X, Y, T), not at(R, _, _, T+1), node(X, Y), time(T).
sleepingcollision(R1, R2) :- endpos(R1, X, Y, T), at(R2, X, Y, T'), T' > T, R1 != R2, time(T').

#show nodecollision/2.
#show edgecollision/2.
#show edgeswitchcollision/2.
#show sleepingcollision/2.
