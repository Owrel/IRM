import os
import sys
from functions import parseTerminaltoClingo
inputMerger = " other/InputMerger.lp"
inputPaths = " InputPlan.lp"
instance = sys.argv[1]
clingo = "/home/daniel/miniconda3/bin/clingo "
merger = " other/Merger.lp"
reslp = " res.lp"
finalplan = " finalplan.lp"
solver =" other/solver.lp"
print(instance)
os.system(clingo + " " + solver +" "+ instance + " > InputPlan.lp")
parseTerminaltoClingo()
os.system(clingo + inputMerger +" "+ instance + inputPaths + " > atfile.lp")

f = open('atfile.lp', 'r')
text = f.read()
text =text.split("Answer:")
text = text[len(text)-1]

forFile ="%%%Python generated \n"
thisManyAts =  text.count("at")
text=text.split("at")




for i in range(thisManyAts +1 ):
    if len(text[i]) > 10:
        text2 = text[i].split(")")[0]
        text2 += ")"
        text[i]=text2
    if text[i][:1] == "(":
        forFile += "at" + text[i] +"." +"\n"


text_file = open("res.lp", "w")
text_file.write(forFile)
text_file.close()

os.system(clingo +" "+ instance +" "+ merger +reslp + " > atfile.lp")
text = ""

f = open('atfile.lp', 'r')
text = f.read()

text =text.split("Answer:")
text = text[len(text)-1]
text = text.replace("final",'')
thisMany =  text.count("occurs")
text= text.split("\n")[1]


text=text.split("occurs")

forFile = ""
for i in range(thisMany + 1):
    if len(text[i]) >3:
        forFile += "occurs" + text[i] +"." +"\n"

text_file = open("finalplan.lp", "w")
text_file.write(forFile)
text_file.close()


os.system("/home/daniel/miniconda3/bin/viz -l "+ instance +" -p " + finalplan)
#os.system("/home/daniel/miniconda3/bin/viz -l Instance2.lp -p /home/daniel/Schreibtisch/gitKrr/asprilo-project-djn/problem-instances/1R/testing/Sol2.lp")


#viz - l[Instanz] - p[Plan]
