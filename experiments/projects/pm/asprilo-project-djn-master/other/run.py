import subprocess
import sys
import time

switch_merger1 = "planswitch_merger1.lp"
switch_merger2 = "planswitch_merger2.lp"
switch_merger3 = "planswitch_merger3.lp"
wait_merger = "wait_merger1.lp"
wait_merger2 = "wait_merger2.lp"

def solve(instance):
    solveCommand = 'clingo -q1 --out-ifs="\n" --out-atomf=%s. ./other/solver.lp ./problem-instances/'+instance+'/instance.lp'
    process = subprocess.run(solveCommand, shell=True, stdout=subprocess.PIPE, universal_newlines=True)

    output = process.stdout
    end = output.find('Optimization:')
    beginning = output.find('occurs')
    time = output.find('Time')

    f = open("./problem-instances/"+instance+"/plan.lp", "w")
    f.write(output[beginning:end])
    f.close()

    print(output[time:])

def switch_merge1(instance):
    mergeCommand = 'clingo -q1 --stats --out-ifs="\n" --out-atomf=%s. ./merger_j/'+switch_merger1+' ./problem-instances/'+instance+'/instance.lp ./problem-instances/'+instance+'/plan.lp'
    process = subprocess.run(mergeCommand, shell=True, stdout=subprocess.PIPE, universal_newlines=True)

    output = process.stdout
    end = output.find('Optimization')
    beginning = output.find('occurs')
    robots = output.find('robot')

    num_rob = output[robots:beginning].count('r')


    f = open("./problem-instances/"+instance+"/mergeplan.lp", "w")
    f.write(output[beginning:end])
    f.close()

    print(output[end:])
    return num_rob

def switch_merge3(instance):
    mergeCommand = 'clingo -q1 --stats --out-ifs="\n" --out-atomf=%s. ./merger_j/'+switch_merger3+' ./problem-instances/'+instance+'/instance.lp ./problem-instances/'+instance+'/mergeplan.lp'
    process = subprocess.run(mergeCommand, shell=True, stdout=subprocess.PIPE, universal_newlines=True)

    output = process.stdout
    end = output.find('Optimization:')
    beginning = output.find('occurs')

    f = open("./problem-instances/"+instance+"/mergeplan.lp", "w")
    f.write(output[beginning:end])
    f.close()

    print(output[end:])

def switch_merge2(instance):
    mergeCommand = 'clingo -q1 --stats --out-ifs="\n" --out-atomf=%s. ./merger_j/'+switch_merger2+' ./problem-instances/'+instance+'/instance.lp ./problem-instances/'+instance+'/mergeplan.lp'
    process = subprocess.run(mergeCommand, shell=True, stdout=subprocess.PIPE, universal_newlines=True)

    output = process.stdout
    end = output.find('Optimization:')
    beginning = output.find('occurs')

    f = open("./problem-instances/"+instance+"/mergeplan.lp", "w")
    f.write(output[beginning:end])
    f.close()

    print(output[end:])

def wait_merge(instance):
    mergeCommand = 'clingo -q1 --stats --out-ifs="\n" --out-atomf=%s. ./merger_j/'+wait_merger+' ./problem-instances/'+instance+'/instance.lp ./problem-instances/'+instance+'/mergeplan.lp'
    process = subprocess.run(mergeCommand, shell=True, stdout=subprocess.PIPE, universal_newlines=True)

    output = process.stdout
    end = output.find('Optimization:')
    beginning = output.find('occurs')

    f = open("./problem-instances/"+instance+"/mergeplan_wait.lp", "w")
    f.write(output[beginning:end])
    f.close()

    print(output[end:])

def wait_merge2(instance):
    mergeCommand = 'clingo -q1 --stats --out-ifs="\n" --out-atomf=%s. ./merger_j/'+wait_merger+' ./problem-instances/'+instance+'/instance.lp ./problem-instances/'+instance+'/mergeplan_wait.lp'
    process = subprocess.run(mergeCommand, shell=True, stdout=subprocess.PIPE, universal_newlines=True)

    output = process.stdout
    end = output.find('Optimization:')
    beginning = output.find('occurs')

    f = open("./problem-instances/"+instance+"/mergeplan_wait.lp", "w")
    f.write(output[beginning:end])
    f.close()

    print(output[end:])

def wait_merge3(instance):
    mergeCommand = 'clingo -q1 --stats --out-ifs="\n" --out-atomf=%s. ./merger_j/'+wait_merger2+' ./problem-instances/'+instance+'/instance.lp ./problem-instances/'+instance+'/mergeplan_wait.lp'
    process = subprocess.run(mergeCommand, shell=True, stdout=subprocess.PIPE, universal_newlines=True)

    output = process.stdout
    end = output.find('Optimization:')
    beginning = output.find('occurs')

    f = open("./problem-instances/"+instance+"/mergeplan_wait.lp", "w")
    f.write(output[beginning:end])
    f.close()

    print(output[end:])

def wait_merge_full(instance, num_rob):
    wait_merge(instance)
    for i in range(1):
        wait_merge2(instance)
    for i in range(num_rob-3):
        wait_merge3(instance)
    

def visualize_switch_merge(instance):
    vizCommand = 'viz  -l ./problem-instances/'+instance+'/instance.lp -p ./problem-instances/'+instance+'/mergeplan.lp'
    process = subprocess.run(vizCommand, shell=True)

def visualize_wait_merge(instance):
    vizCommand = 'viz  -l ./problem-instances/'+instance+'/instance.lp -p ./problem-instances/'+instance+'/mergeplan_wait.lp'
    process = subprocess.run(vizCommand, shell=True)

def visualize_solution(instance):
    vizCommand3 = 'viz  -l ./problem-instances/'+instance+'/instance.lp -p ./problem-instances/'+instance+'/plan.lp'
    process = subprocess.Popen(vizCommand3.split(), stdout=subprocess.PIPE, universal_newlines=True)
    stdout, stderr = process.communicate()

if (len(sys.argv) >= 2):
    if ('h' == str(sys.argv[1])) or ('help' == str(sys.argv[1])):
        print("Usage: type the name of the instance folder as the first argument. \n"+
                    "The second argument is optional and can be:\n"+
                    "s: solve only"+
                    "\nvs: solve and visualize the solution"+
                    "\nm: only merge once (planswitch)"+
                    "\nm2: merge twice (planswitch)"+
                    "\nm3: merge 3 times (planswitch)"+
                    "\nm4: merge 4 times (planswitch)"+
                    "\nmfull: merge 4 times (planswitch) and wait"+
                    "\nmw: only use waitmerger"+
                    "\nvm: merge once and visualize"+
                    "\nvm2: merge twice and visualize"+
                    "\nvm3: merge 3 times and visualize"+
                    "\nvm4: merge 4 times and visualize"+
                    "\nvmfull: merge 4 times, wait and visualize")
    else:
        instance = str(sys.argv[2])
        if ('s' == str(sys.argv[1])):
            solve(instance)
        elif ('vs' == str(sys.argv[1])):
            solve(instance)
            visualize_solution(instance)
        elif ('vm' == str(sys.argv[1])):
            switch_merge1(instance)
            visualize_switch_merge(instance)
        elif ('vm2' == str(sys.argv[1])):
            switch_merge1(instance)
            switch_merge2(instance)
            visualize_switch_merge(instance)
        elif ('vm3' == str(sys.argv[1])):
            switch_merge1(instance)
            switch_merge2(instance)
            switch_merge2(instance)
            visualize_switch_merge(instance)
        elif ('vm4' == str(sys.argv[1])):
            switch_merge1(instance)
            switch_merge2(instance)
            switch_merge2(instance)
            switch_merge2(instance)
            visualize_switch_merge(instance)
        elif ('vmfull' == str(sys.argv[1])):
            s = time.time()
            num_rob = switch_merge1(instance)
            print('number of robots: ' + str(num_rob))
            switch_merge2(instance)
            switch_merge3(instance)
            switch_merge3(instance)
            switch_merge3(instance)
            #num_rob = int(sys.argv[3])
            wait_merge_full(instance, num_rob)
            print('Total merge time : ' + str(time.time() - s))
            visualize_wait_merge(instance)
        elif ('m' == str(sys.argv[1])):
            switch_merge1(instance)
        elif ('m2' == str(sys.argv[1])):
            switch_merge1(instance)
            switch_merge2(instance)
        elif ('m3' == str(sys.argv[1])):
            switch_merge1(instance)
            switch_merge2(instance)
            switch_merge2(instance)
        elif ('m4' == str(sys.argv[1])):
            switch_merge1(instance)
            switch_merge2(instance)
            switch_merge2(instance)
            switch_merge2(instance)
        elif ('mfull' == str(sys.argv[1])):
            s = time.time()
            num_rob = switch_merge1(instance)
            print('number of robots: ' + str(num_rob))
            switch_merge3(instance)
            switch_merge3(instance)
            switch_merge3(instance)
            switch_merge3(instance)
            #num_rob = int(sys.argv[3])
            wait_merge_full(instance, num_rob)
            print('Total merge time : ' + str(time.time() - s))
        elif ('mw' == str(sys.argv[1])):
            wait_merge(instance)
        elif ('mw2' == str(sys.argv[1])):
            wait_merge2(instance)
        elif ('mwfull' == str(sys.argv[1])):
            num_rob = switch_merge1(instance)
            print('number of robots: ' + str(num_rob))
            #num_rob = int(sys.argv[3])
            wait_merge_full(instance, num_rob)
