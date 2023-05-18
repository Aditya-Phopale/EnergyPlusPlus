using GraphPlot, Colors, Plots

FIG_PATH = "images/"

"""
plots the MetaGraph
"""
function plot_graph(buildNetwork)
    nRooms = Graphs.nv(buildNetwork)-1;
    nodefillc = distinguishable_colors(nRooms+1, colorant"blue")
    nodelabel = 1:nRooms+1
    graph_viz = gplot(buildNetwork, nodelabel=nodelabel, nodefillc=nodefillc)
    draw(PNG(FIG_PATH * "graph_viz.png", 30cm, 30cm), graph_viz)
end


"""
plot simulation results
"""
function plot_results(buildNetwork, sol, Room_array, wall_array)
    nRooms = Graphs.nv(buildNetwork)-1;
    Plots.plot()

    for i in 1:nRooms
    Plots.plot!(sol, vars = [Room_array[i].v1], labels = "Room Temperature "*string(i-1), linewidth=3, fontsize=14, legend=:topright)
    #    if i==4
    #    Plots.plot!(sol, vars = [-1*Room_array[i].i3], labels = "", linewidth=3, fontsize=14, legend=:bottomright)
    #    end
    # text = "Room_"*string(i)*"_"*"Prototype_Model_Simple.png"
    # savefig(text)
    end
    Plots.xlabel!("time (s)")
    Plots.ylabel!("Temperature (deg C)")
    graph_title = "Prototype_Model_Simple.png"
    Plots.savefig(FIG_PATH * graph_title)
end