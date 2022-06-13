def parseTerminaltoClingo():
    f = open('InputPlan.lp', 'r')
    text = f.read()
    text = text.split("Answer:")
    text = text[len(text) - 1]
    text = text.replace("final", '')
    thisMany = text.count("occurs")
    text = text.split("\n")[1]
    text = text.split("occurs")
    forFile = ""
    for i in range(thisMany + 1):
        if len(text[i]) > 10:
            forFile += "occurs" + text[i] + "." + "\n"

    for i in range(thisMany + 1):
        if len(text[i]) >10:
            forFile += "occurs" + text[i] + "." + "\n"
    text_file = open("InputPlan.lp", "w")
    text_file.write(forFile)
    text_file.close()

