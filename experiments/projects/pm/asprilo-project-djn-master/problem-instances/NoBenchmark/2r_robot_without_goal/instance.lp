%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Grid size X: 5
%Grid size Y: 5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

%init
init(object(node, 1), value(at, (1, 1))).
init(object(node, 6), value(at, (1, 2))).
init(object(node, 11), value(at, (1, 3))).
init(object(node, 21), value(at, (1, 5))).
init(object(node, 25), value(at, (5, 5))).
init(object(node, 20), value(at, (5, 4))).
init(object(node, 19), value(at, (4, 4))).
init(object(node, 24), value(at, (4, 5))).
init(object(node, 15), value(at, (5, 3))).
init(object(node, 14), value(at, (4, 3))).
init(object(node, 13), value(at, (3, 3))).
init(object(node, 12), value(at, (2, 3))).
init(object(node, 16), value(at, (1, 4))).

init(object(robot,2), value(at,(1,4))).
init(object(robot,2), value(max_energy,0)).

init(object(shelf,1), value(at,(5,4))).
