import tskit, pyslim, msprime

ts = tskit.load("ex.trees")
today_nodes = [n for i in pyslim.individuals_alive_at(ts, 0) for n in ts.individual(i).nodes]

sts, node_map = ts.simplify(today_nodes, map_nodes=True)
inv_map = {n : k for k, n in enumerate(node_map) if n >= 0}

sts.draw_svg("sim_ts.svg", size=(1200, 400), y_axis=True)

ts.draw_svg("big_ts.svg", x_lim=[0, 100_000], size=(1200, 600))

t = ts.first()
node_labels = {n : str(n) if n in today_nodes else "" for n in range(ts.num_nodes)}

# highlight modern nodes
num_desc = [0 for _ in ts.nodes()]
for p in today_nodes:
    while p != tskit.NULL:
        num_desc[p] += 1
        p = t.parent(p)
        
y = [False for _ in ts.nodes()]
for n in range(ts.num_nodes):
    if n in today_nodes:
        y[n] = True
    if num_desc[n] > 0 and t.parent(n) != tskit.NULL and num_desc[n] != num_desc[t.parent(n)]:
        y[t.parent(n)] = True

styles = []
for n in t.nodes():
    if num_desc[n] == 1 and y[n]:
        s = f".node.n{n} > .sym " + "{fill: red; transform: scale(2); stroke: black;}"
        styles.append(s)

css_string = " ".join(styles)

t.draw_svg("tree0.svg", size=(1000,500), node_labels=node_labels, style=css_string)

# highlight their subtree
styles = []
for n in t.nodes():
    if y[n]:
        # target the symbols only (class "sym")
        s = f".node.n{n} > .sym " + "{fill: red; transform: scale(2); stroke: black;}"
        styles.append(s)
    p = t.parent(n)
    if num_desc[n] > 0 and p != tskit.NULL and num_desc[n] < len(today_nodes):
        s = f".a{p}.n{n} > .edge" +  "{stroke: red; stroke-width: 2px}"
        styles.append(s)

css_string = " ".join(styles)

t.draw_svg("tree1.svg", size=(1000,500), node_labels=node_labels, style=css_string)

# show the simplified tree
t = sts.first()
node_labels = {n : str(inv_map[n]) if n in list(sts.samples()) else "" for n in range(sts.num_nodes)}

t.draw_svg("tree2.svg", size=(400,200), node_labels=node_labels)
