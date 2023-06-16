import tskit, pyslim, msprime

ts = tskit.load("ex.trees")

ts.draw_svg("sim_ts.svg", size=(1200, 400), y_axis=True)
