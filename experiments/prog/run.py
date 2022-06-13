

from statistics import mean
from Strategy import Model, Strategy
import clingo
import json as JSON



class Model:
    def __init__(self, cmodel):
        
        m = cmodel.__str__()
        self.symbols = m.split(' ')

    def to_prg(self):
        ret = ''
        for s in self.symbols:
            if s:
                ret += s +'.\n' 
        return ret[:-1]

    def get_robots(self):
        r = [] 
        for i in self.symbols:
            if 'robot' in i:
                r.append(i[i.index('(')+1:i.index(')')])
        return r

    def merge(self, model):
        if isinstance(model,list):
            for m in model:
                self.merge(m)
        for s in model.symbols:
            if not s in self.symbols:
                self.symbols.append(s) 

    def __str__(self):
        ret = ""
        for i,s in enumerate(self.symbols):
            if s!= '\n':
                ret += s +' '
        return ret[:]




class Strategy:
    def __init__(self, parameters) -> None:
        self.parameters = parameters
        self.prog_pass = None
        self.transfered_models = None
        self._models = None
        self.statistics = {}
        # self.ctl_statistics = None

    @property
    def models(self):
        return self._models

    @models.setter
    def models(self,  models):

        if not self.transfered_models is None:
            self.statistics = {
                'n_transfered_model' : len(self.transfered_models),
                'n_models' : len(models),
                'n_models_difference' : len(models) -len(self.transfered_models),
                'average_symbols_transfered' : mean([len(m.symbols) for m in self.transfered_models]),
                'average_symbols_models' : mean([len(m.symbols) for m in models])
            }
        else :
            self.statistics = {
                'n_models' : len(models),
                'average_symbols_models' : mean([len(m.symbols) for m in models])
            }
        self._models = models

    def init_prog(self, prog)->None:

        if self.prog_pass is None:
            self.prog_pass = prog
        else :
            self.prog_pass += prog

    def transfer(self, models):
        self.transfered_models = models

    def compute(self):
        pass

        

    def get(self):
        if self.models is None:
            raise Exception("Should call compute function first")
        
        return self.models

    def __str__(self):
        # print(JSON.dumps(self.ctl_statistics,indent=4))
        # self.statistics['ctl_statistics'] =  {
        #     'rules' : self.ctl_statistics['problem']['lp']['rules'],
        #     'atoms' : self.ctl_statistics['problem']['lp']['atoms'],
        #     'solving': self.ctl_statistics['solving'],
        #     'time': self.ctl_statistics['summary']['times']['total']
        # }
        # self.statistics['ctl_statistics'] = self. ctl_statistics
        return JSON.dumps(self.statistics,indent =2)


 

class GraphTranslation(Strategy):
    def __init__(self, parameters='0') -> None:
        super().__init__(parameters)
        
        self.strat_path = "prog/strategies/GraphTranslation.lp"
        with open(self.strat_path,'r') as f:
            self.encoding = f.read()

    def compute(self):
        ctl = clingo.Control(self.parameters)
        ctl.load(self.strat_path)
        if not self.prog_pass is None:
            ctl.add('base',[],str(self.prog_pass))
        
        ctl.ground([("base", [])])
        models = []
        with ctl.solve(yield_=True) as hdl:
            for m in hdl:
                models.append(Model(m))
                
            hdl.get()

        # self.ctl_statistics = ctl.statistics
        self.models = models


class TA(Strategy):
    def __init__(self, parameters=None) -> None:
        super().__init__(parameters)
        self.strat_path = 'prog/strategies/RandomTargetAssignment.lp'
        with open(self.strat_path,'r') as f:
            self.encoding = f.read()
    def compute(self):
        if self.transfered_models is None:
            raise "Need models first"

        models = [] 
        for model in self.transfered_models:
            ctl = clingo.Control('0')
            ctl.add('base',[],model.to_prg())
            ctl.load(self.strat_path)
            ctl.ground([("base", [])])
            with ctl.solve(yield_=True) as hdl:
                for m in hdl:
                    models.append(Model(m))
                hdl.get()
        # self.ctl_statistics = ctl.statistics
        self.models = models


 
class IndividualPathFinding(Strategy):
    def __init__(self, parameters=None) -> None:
        super().__init__(parameters)
        self.strat_path = 'prog/strategies/IndividualPathFinding.lp'
        with open(self.strat_path,'r') as f:
            self.encoding = f.read()
        self.ctl_statistics = []


    def compute(self):
        if self.transfered_models is None:
            raise Exception("Need models first")
        models = []
        for model in self.transfered_models:
            mem = Model('')
            for r in model.get_robots():
                fastest_found = False
                for horizon in range(0,50):
                    ctl = clingo.Control(['1','-c', f'robot={r}','-c',f'horizon={horizon}'])
                    ctl.add('base',[],model.to_prg())
                    ctl.load(self.strat_path)
                    ctl.ground([("base", [])])
                    with ctl.solve(yield_=True) as hdl:
                        for m in hdl:
                            fastest_found = True
                            mem.merge(Model(m))
                        hdl.get()
                    if fastest_found:
                        self.ctl_statistics.append(ctl.statistics)
                        break
            mem.merge(model)
            models.append(mem)

        # self.ctl_statistics = ctl.statistics
        self.models = models


class FixingWaitOnlyPosition(Strategy):
    def __init__(self, parameters=None) -> None:
        super().__init__(parameters)
        self.strat_path = 'prog/strategies/FixingWaitOnlyPosition.lp'
        with open(self.strat_path,'r') as f:
            self.encoding = f.read()
        self.ctl_statistics = []

    def compute(self):
        if self.transfered_models is None:
            raise Exception("Need models first")
        models = []
        for model in self.transfered_models:
            # print(model)
            mem = Model('')
            ctl = clingo.Control('0')
            # print(model.to_prg())
            ctl.add('base',[],model.to_prg())
            ctl.load(self.strat_path)
            ctl.ground([("base", [])])
            with ctl.solve(yield_=True) as hdl:
                for m in hdl:
                    mem.merge(Model(m))
                hdl.get()
            mem.merge(model)
            models.append(mem)

        # self.ctl_statistics = ctl.statistics
        self.models = models


class MergingWaitOnly(Strategy):
    def __init__(self, parameters=None) -> None:
        super().__init__(parameters)
        self.strat_path = 'prog/strategies/MergingWaitOnly.lp'
        with open(self.strat_path,'r') as f:
            self.encoding = f.read()
        self.ctl_statistics = []

    def compute(self):
        if self.transfered_models is None:
            raise Exception("Need models first")
        models = []
        for model in self.transfered_models:
            # print(model)
            mem = Model('')
            ctl = clingo.Control('1')
            # print(model.to_prg())
            ctl.add('base',[],model.to_prg())
            ctl.load(self.strat_path)
            ctl.ground([("base", [])])
            with ctl.solve(yield_=True) as hdl:
                for m in hdl:
                    mem.merge(Model(m))
                    mem.merge(model)
                    models.append(mem)
                hdl.get()
            # print(ctl.statistics)

        # self.ctl_statistics = ctl.statistics
        self.models = models

instance_path ='encodings/instances/AFpriorityWaiting.lp'
with open(instance_path,'r') as f:
    encoding = f.read()

gr = GraphTranslation()
gr.init_prog(encoding)
gr.compute()


print(gr)

ta = TA()
ta.transfer(gr.get())
ta.compute()

print(ta)

ipf = IndividualPathFinding()
ipf.transfer(ta.get())
ipf.compute()

print(ipf)

fwo = FixingWaitOnlyPosition()
fwo.transfer(ipf.get())
fwo.compute()

print(fwo)

mwo = MergingWaitOnly()
mwo.transfer(fwo.get())
mwo.compute()
print(mwo)
print(mwo.get())


 



