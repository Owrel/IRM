import clingo

ctl = clingo.Control('0')
ctl.load('encodings/targetassignment/ta.lp')
ctl.ground([("base", [])])

ctl.solve(on_model=print)