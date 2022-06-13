%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Grid size X: 5
%Grid size Y: 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

%init
init(object(node, 6), value(at, (1, 2))).
init(object(node, 7), value(at, (2, 2))).
init(object(node, 8), value(at, (3, 2))).
init(object(node, 3), value(at, (2, 1))).
init(object(node, 10), value(at, (5, 2))).
init(object(node, 9), value(at, (4, 2))).
init(object(shelf,1), value(at,(1,2))).
init(object(shelf,2), value(at,(5,2))).
init(object(robot,1), value(at,(4,2))).
init(object(robot,1), value(max_energy,0)).
init(object(robot,1), value(energy,0)).
init(object(robot,2), value(at,(2,2))).
init(object(robot,2), value(max_energy,0)).
init(object(robot,2), value(energy,0)).
