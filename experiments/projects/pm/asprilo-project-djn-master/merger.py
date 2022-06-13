import clingo
import numpy as np
import time
import sys, os


class Model:
     def __init__(self, model=None, cost=None, number=None, stats=None):
        self.model = model
        self.cost = cost
        self.number = number
        self.stats = stats


class Merger:
    def __init__(self, instance, max_iter=100, verbose=False):
        self.instance = "problem-instances/"+instance+"/instance.lp"
        f = open("problem-instances/"+instance+"/plan.lp","r")
        self.plan = f.read()
        f.close()
        self.max_iter = max_iter
        self.verbose = verbose
        self.models = []
        self.stats = []
        self.totals = []
        self.wm1 = "merger_j/wait_merger1.lp"
        self.wm2 = "merger_j/wait_merger2.lp"
        self.pm1 = "merger_j/planswitch_merger1.lp"
        self.pm2 = "merger_j/planswitch_merger2.lp"
        self.pm3 = "merger_j/planswitch_merger3.lp"


    def on_model(self, m):
        self.models.append(Model(self.to_plan(str(m)), m.cost, m.number))

    def to_plan(self, model):
        return model.replace(" ", ".\n") + "."


    def solve(self, merger):
        ctl = clingo.Control()
        ctl.load(merger)
        ctl.load(self.instance)
        ctl.add("base", [], self.plan)
        ctl.ground([("base", [])])
        ctl.solve(on_model=self.on_model)
        self.models[-1].stats = ctl.statistics
        self.save_stats(self.models[-1])
        self.plan = self.models[-1].model
        if self.verbose:
            self.print_stats(self.stats[-1])

    def planswitch(self):
        self.solve(self.pm1)
        self.solve(self.pm2)
        old_cost = self.models[-1].cost
        self.solve(self.pm3)
        cost = self.models[-1].cost
        iter = 0
        while (cost != old_cost and iter != self.max_iter):
            old_cost = cost
            self.solve(self.pm3)
            cost = self.models[-1].cost
            iter += 1

    def wait(self):
        iter = 0
        cost = [1, 1]
        while iter < 2 and not (cost == [0, 0] or cost == [0]):
            self.solve(self.wm1)
            cost = self.models[-1].cost[:-1]
            iter += 1

        while not (cost == [0, 0] or cost == [0]) and iter != self.max_iter:
            self.solve(self.wm2)
            cost = self.models[-1].cost[:-1]
            iter += 1
    
    def merge(self):
        self.planswitch()
        self.wait()
        self.set_total_stats()

        print("\nTotal merging stats :\n")
        self.print_stats(self.totals)


    def save_stats(self, model):
        self.stats.append([model.stats['summary']['times']['total'],
            #model.stats['summary']['times']['cpu'],
            model.stats['summary']['times']['total'] - model.stats['summary']['times']['solve'],
            model.stats['summary']['times']['solve'],
            model.number,
            model.stats['solving']['solvers']['choices'],
            model.stats['problem']['lp']['atoms'],
            model.stats['problem']['lp']['rules'],
            model.cost])

    def set_total_stats(self):
        stats = np.array(self.stats,dtype=object)
        self.totals = []
        for i in range(stats.shape[1]-1):
            self.totals.append(np.sum(stats[:,i]))
        self.totals.append(stats[-1][-1])

    def print_stats(self, stats):
        print("Total merge time: {} sec".format(stats[0]))
        print("Grounding time: {} sec".format(stats[1]))
        print("Solving time: {} sec".format(stats[2]))
        print("Number of models: {}".format(stats[3]))
        print("Choices : {}".format(stats[4]))
        print("Atoms : {}".format(stats[5]))
        print("Rules : {}".format(stats[6]))
        print("Optimization : {}\n".format(stats[7]) + '\n')  



def main():

    inst = str(sys.argv[1])
    if (len(sys.argv) > 2 and sys.argv[2] == 'verbose') or (len(sys.argv) > 3 and sys.argv[3] == 'verbose'):
        verbose = True
    else:
        verbose = False
    merger = Merger(inst, verbose=verbose)

    merger.merge()
    ###############################################

    if (len(sys.argv) > 2 and sys.argv[2] == 'viz') or (len(sys.argv) > 3 and sys.argv[3] == 'viz'):
            f = open('problem-instances/'+inst+'/mergeplan_wait.lp', 'w')
            f.write(merger.plan)
            f.close()
            os.system('viz -l {} -p {}'.format('problem-instances/'+inst+'/instance.lp','problem-instances/'+inst+'/mergeplan_wait.lp'))

if __name__ == '__main__':
    main()
