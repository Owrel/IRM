

class Model:
    def __init__(self, cmodel):
        m = cmodel.__str__()
        self.symbols = m.split(' ')

    def to_prg(self):
        ret = ''
        for s in self.symbols:
            ret += s +'.\n' 
        return ret[:-1]

    def get_robots(self):
        r = [] 
        for i in self.symbols:
            if 'robot' in i:
                r.append(i[i.index('(')+1:i.index(')')])
        return r

    def merge(self, model):
        for s in model.symbols:
            if not s in self.symbols:
                self.symbols.append(s) 

    def __str__(self):
        ret = ""
        for i,s in enumerate(self.symbols):
            ret += s + ' '
        return ret


class Strategy:
    def __init__(self, parameters) -> None:
        self.parameters = parameters
        self.prog_pass = None
        self.transfered_models = None
        pass

    def init_prog(self, prog)->None:

        if self.prog_pass is None:
            self.prog_pass = prog
        else :
            self.prog_pass += prog

    def transfer(self, models):
        self.transfered_models = models

    def get(self) -> str:
        pass
        
    





