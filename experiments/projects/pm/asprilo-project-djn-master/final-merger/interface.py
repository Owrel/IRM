from merger import Merger

# use this function to run plan merging on a benchmark file and return a json file into a directory
# [benchmark] should be a path to the instance file (example: "benchmarks/03_4r_node.lp")
# the plan should be saved in a different file with the same name + ".plan" suffix
# [save_dir] should be the folder where the json file is saved (example: save_dir = "testresults" -> file is saved as "testresults/benchmark.json")

def merge(benchmark, save_dir):
    merger = Merger(benchmark)
    merger.merge(save=True, save_dir=save_dir)