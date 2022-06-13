import encodings
from gettext import install
import clingo
import glob

CWD = "encodings/instances/pathfinding/"
instances_path ='encodings/instances/'

instances = glob.glob(instances_path + '/*.lp')[:2]


for i in instances:
    ret = set([])
    for r in range(100):
        ctl = clingo.Control(['0','--const',f'current={r}'])
        ctl.load(i)
        ctl.load(CWD + '/path.lp')
        ctl.ground([("base", [])])
        model = ''
        with ctl.solve(yield_=True) as handle:
            for m in handle:
                model = m.__str__()
            handle.get()

        ret = ret.union(set(model.split(' ')))
    file = ''
    for e in sorted(list(ret)):
        if e:
            file += e +'.\n'

    with open(i + '.step', 'w') as f:
        f.write(file)
    print(i, 'done')


    



