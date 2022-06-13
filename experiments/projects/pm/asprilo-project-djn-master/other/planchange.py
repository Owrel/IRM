f = open("testplan.lp", "rt")
tmp = []
for line in f:
    if line =="\n":
        continue
    a = int(line[-4])
    if a == 9:
        a = 0
        line = line[:-4] + str(a) + line[-3:]
        if line[-5] == ',':
            line = line[:-4] + '1' + line[-4:]
        else:
            b = int(line[-5])
            b += 1
            line = line[:-5] + str(b) + line[-4:]
    else:    
        a += 1
        line = line[:-4] + str(a) + line[-3:]
    tmp.append(line)
f.close()
plan = str(tmp)
f = open('testplan2.lp', 'wt')
for i in range(len(tmp)):
    f.write(tmp[i])

f.close()