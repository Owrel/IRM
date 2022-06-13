import clingo

ctl = clingo.Control('0')
ctl.load('encodings/moving_goal/moving_goal.lp')
ctl.ground([("base", [])])

ctl.solve(on_model=print)