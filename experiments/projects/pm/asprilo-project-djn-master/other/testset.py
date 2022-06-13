import os
import sys
import matplotlib.pyplot as plt



numberoftest=15
finalplan = " finalplan.lp"
Rtime= [0] * numberoftest
x=[0]*numberoftest
def testing(i):
    x[i] = i * 2 +2
    os.system("python run2.py  m3 " + " Testset1/" + str(i + 2) + "> times.txt")
    f = open('times.txt', 'r')
    text = f.read()
    text = text.split("CPU Time")
    text = text[1]
    text = text.split("C")
    text = text[0]
    text = text[:20]
    text = text.replace(':', '')
    text = text.replace(' ', '')
    text = text.replace('s', '')
    Rtime[i] = float(text)
    print(text)



for i in range(numberoftest):
    try:
        testing(i)
    except Exception as exc:
        print(exc)

    #print(text)
y=[0,max(Rtime)]
plt.xlim(0,len(x)*2)
plt.ylim(0,max(Rtime))
plt.xlabel("number of robots")
plt.ylabel("time in s")
plt.plot(x , Rtime, color='green', linestyle='dashed', linewidth = 3,
         marker='o', markerfacecolor='blue', markersize=12)

plt.savefig('plot.png')
plt.show()
