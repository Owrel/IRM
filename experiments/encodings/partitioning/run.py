import clingo

ctl = clingo.Control('1')
ctl.load('encodings/partitioning/partitioning.lp')
ctl.load('encodings/instances/AFTAlotofrobots.lp.step')
ctl.load('encodings/partitioning/waitonly.lp')
ctl.ground([("base", [])])
model=''
with ctl.solve(yield_=True) as handle:
    for m in handle:
        model = m.__str__()
        print('model found')
    handle.get()

model = model.split(' ')
file = ''
for e in model:
    if e:
        file += e +'.\n'

with open('encodings/instances/lastout.lp', 'w') as f:
    f.write(file)