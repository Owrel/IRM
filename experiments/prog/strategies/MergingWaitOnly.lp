% Definition of global variable
time(1..20).

% Possiple direction
direction(1,0). direction(-1,0). direction(0,1). direction(0,-1).


% Getting nodes from original path
available_node(R,(X,Y)) :- position(R,(X,Y),_).

new_position(R,(X,Y),0) :- position(R,(X,Y),0).

{move(R,(DX,DY),T): direction(DX,DY)}1 :- time(T),  robot(R).
% %If move at time step T
new_position(R,(X+DX,Y+DY),T) :- new_position(R,(X,Y),T-1), move(R,(DX,DY),T), available_node(R,(X+DX,Y+DY)).
% %If no move at time step T (wait)
new_position(R,(X,Y),T) :- new_position(R,(X,Y),T-1), not move(R,(_,_),T), time(T), wait_zone(X,Y).
% % wic(X,Y,T) :- position(X,Y,N,T-1), not move(_,_,N,T), time(T), conflict_zone(X,Y).

% % Management of reaching the goal
{picked(R,T)} :- shelf(S,(X,Y)), new_position(R,(X,Y),T), assigned(R,S). % target assignment


:- move(R,(_,_),T), picked(R,T'), T>T'.
:- not picked(R,_), robot(R).

% Conflict management
:- {new_position(R,(X,Y),T): robot(N)}>1, time(T), node(X,Y).
:- new_position(R,(X,Y),T), new_position(R,(X',Y'),T+1), new_position(R',(X',Y'),T), new_position(R',(X,Y),T+1), R!=R', (X,Y)!=(X',Y').




% Showing section
%translation to occurs
% #show  occurs(object(robot,N), action(move,(DX,DY)),     T) :   move(R,(DX,DY),T).
% #show new_step(N,T,X,Y) : position(X,Y,N,T).
% #show goalReached(N,T) : picked(N,T).
% #show wic/3.
% #minimize {1,X,Y,T: wic(X,Y,T)}.

#show new_position/3.
