import subprocess
import sys

merger = "newest"

def solve(instance):
    solveCommand = 'clingo -q1 --out-atomf=%s. ../other/solver.lp ./'+instance+'/instance.lp'
    process = subprocess.Popen(solveCommand.split(), stdout=subprocess.PIPE, universal_newlines=True)

    stdout, stderr = process.communicate()
    end = stdout.find('Optimization:')
    beginning = stdout.find('occurs')
    #print(stdout[78:end])

    time = stdout.find('Time')
    print(stdout[time:])

    f = open("./"+instance+"/plan.lp", "w")
    f.write(stdout[beginning:end])
    f.close()

def merge(instance):
    mergeCommand = 'clingo 0 --out-atomf=%s. '+merger+'_merger.lp ./'+instance+'/instance.lp ./'+instance+'/plan.lp'
    process = subprocess.Popen(mergeCommand.split(), stdout=subprocess.PIPE, universal_newlines=True)

    stdout, stderr = process.communicate()
    end = stdout.find('Optimization:')
    beginning = stdout.find('occurs')
    #print(stdout[beginning:end])
    
    time = stdout.find('Time')
    print(stdout[time:])

    finalD = stdout.find('finalD(')
    print(stdout[finalD:beginning])

    f = open("./"+instance+"/mergeplan.lp", "w")
    f.write(stdout[beginning:end])
    f.close()

def visualize(instance):
    vizCommand = 'viz  -l ./'+instance+'/instance.lp -p ./'+instance+'/mergeplan.lp'
    process = subprocess.Popen(vizCommand.split(), stdout=subprocess.PIPE, universal_newlines=True)
    stdout, stderr = process.communicate()

if (len(sys.argv) >= 2):
    if (str(sys.argv[1]) == "h") or (str(sys.argv[1]) == "help"):
        print("Usage: type the name of the instance folder as the first argument. \n"+
                    "The second argument is optional and can be:\n"+
                    "s: solve only\nb: solve and merge\nv: merge and visualize\na: solve, merge and visualize\nno argument: only merge")
    else:
        instance = str(sys.argv[1])
        if (len(sys.argv) == 3) and (str(sys.argv[2]) == 's'):
            solve(instance)
        elif (len(sys.argv) == 3) and (str(sys.argv[2]) == 'b'):
            solve(instance)
            merge(instance)
        elif (len(sys.argv) == 3) and (str(sys.argv[2]) == 'v'):
            merge(instance)
            visualize(instance)
        elif (len(sys.argv) == 3) and (str(sys.argv[2]) == 'a'):
            solve(instance)
            merge(instance)
            visualize(instance)
        else:
            merge(instance)
