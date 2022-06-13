% INITIAL SETUP ================================================================

% - Initial State --------------------------------------------------------------

holds(O, V, 0) :- init(O, V).


% - Plan Length ----------------------------------------------------------------

horizon(H) :- H = #max{ 0; T : occurs( _, _, T) }.
time(1..H) :-  horizon(H).


% - General Law of Interia -----------------------------------------------------

holds(O, V, T) :- holds(O, V, T-1), not ab(O, V, T), time(T).







% = ACTION move ================================================================

% - Domain ---------------------------------------------------------------------

action(move, (0,1;1,0;0,-1;-1,0)).

% - Checks: Preconditions ------------------------------------------------------

% Target node non-existent
err(move, node, (R, T))   :-     occurs(object(robot, R), action(move, (DX,    DY)),  T  );
                                 holds( object(robot, R), value(at,    (X,      Y)),  T-1);
                             not holds( object(node,  _), value(at,    (X+DX, Y+DY)), T  ).

% Movement domain violated
err(move, domain, (R, T)) :-     occurs(object(robot, R), action(move, (DX,    DY)),  T  );
                                 holds( object(robot, R), value(at,    (X,      Y)),  T-1);
                             not action(move, (DX, DY)).



%adjacent(R, DX, DY, T) :- holds( object(node,  _), value(at,    (X+DX, Y+DY)), T  ).at(robot(R), X, Y, T-1); node(X+DX, Y+DY); action(move(DX, DY)).

% - Book-Keeping: Effects --------------------------------------------------------------------

holds(object(robot, R), value(at, (X+DX, Y+DY)), T) :- occurs(object(robot, R), action(move,   (DX, DY)), T  );
                                                       holds( object(robot, R), value(at,      (X, Y)),   T-1).

% - Book-Keeping: Related Inertia Abnormals ---------------------------------------

ab(object(robot, R), value(at, (X, Y)), T) :- holds( object(robot, R), value(at,      (X, Y)), T-1);
                                              occurs(object(robot, R), action(move,        _), T  ).
                                              
                                              
                                              
                                              
                                              
                                              
% = STATIC LAWS ================================================================

% - Verification of Object Locations --------------------------------------

% At most one object of the same type (robot. shelf, picking station, etc.)  may occupy a node at
% the same time, otherwise collision.
err(static, collNode, (OT, X, Y, T))      :- { holds(object(OT, _),     value(at, (X, Y)), T) } > 1;
                                             holds(object(node, _), value(at, (X, Y)),     T);
                                             init( object(OT,   _), _);
                                             time(T).


% Two adjacent objects of the same type (robots, shelves) must not swap places in one step, i.e,
% they would collide.
err(static, collSwap, (OT, R1, R2, T))    :- holds(object(OT, R1), value(at, (X1, Y1)), T);
                                             holds(object(OT, R2), value(at, (X2, Y2)), T);
                                             holds(object(OT, R1), value(at, (X2, Y2)), T-1);
                                             holds(object(OT, R2), value(at, (X1, Y1)), T-1);
                                             R1<R2, |X2-X1|+|Y2-Y1|==1.

% An object can only be at one postion at the same time.
err(static, twoPos, (OT,O, T))            :-  { holds(object(OT,   O), value(at, (X, Y)), T) :
                                                holds(object(node, _), value(at, (X, Y)), T)   } > 1;
                                              init(object(OT,   O), _);
                                              time(T).

%  An object can only do one action at a time.
err(static, multActions, (OT, O, T))      :-  { occurs(object(OT, O), _, T) } > 1;
                                              init(object(OT, O), _);
                                              time(T).

% A robot must never place a shelves on a highway node.
err(static, highwayPutdown, (R, X, Y, T)) :- holds( object(highway, _), value(at, (X, Y)),   T);
                                             holds( object(robot, R),   value(at, (X, Y)),   T);
                                             occurs(object(robot, R),   action(putdown, ()), T);
                                             time(T).

% An order must be assigned to exactly one picking stations
%err(static, assigned, O)                  :- { holds(object(order, O), value(pickingStation, _), T) } > 1;
%                                             holds(object(order, O), _, T);
%                                             time(T).
%err(static, assigned, O)                  :- { holds(object(order, O), value(pickingStation, _), T) } < 1;
%                                             holds(object(order, O), _, T);
%                                             time(T).        







% = ORDER FULFILLMENT ==============================================================================
%
%   Sequence of actions and conditions required to fulfill (i.e., fully process) an order.
%

% Auxilliary fluents to indicate permanent parking of robots.
holds(object(robot, R), value(moves,       ()), T)   :- occurs(object(robot, R), action(move, _), T).
holds(object(robot, R), value(perma_parks, ()), H)   :- init(object(robot, R), _), horizon(H).
holds(object(robot, R), value(perma_parks, ()), T-1) :- not holds(object(robot, R), value(moves, ()), T);
                                                            holds(object(robot, R), value(perma_parks, ()), T);
                                                            init( object(robot, R), _                        );
                                                            time(T; T-1).

% Remove outdated order lines, i.e., order is fulfilled as soon as robot permanently parks under
% shelf for the remainder of the plan
ab(object(order, O), value(line, (P, RQ)), T) :- holds(object(robot,   R),  value(at,          (X, Y)),  T  );
                                                 holds(object(robot,   R),  value(perma_parks, ()),      T  );
                                                 holds(object(shelf,   S),  value(at,          (X, Y)),  T  );
                                                 holds(object(order,   O),  value(line,        (P, RQ)), T-1);
                                                 holds(object(product, P),  value(on,          (S,  _)), T-1).
                                                 
                                                 
                                                 
                                                 
                                                 
                                                 
                                                 
                                                 
% = GOAL CONDITION =============================================================

err(goal, unfilledOrder, (O, P, Q, H)) :- holds(object(order, O), value(line, (P, Q)), H);
                                          horizon(H).                                                                                 
