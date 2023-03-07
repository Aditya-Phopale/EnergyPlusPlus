using GraphPlot, Colors

"""
parse_JSON() reads the JSON file and returns connectivity dictionary
with neighbours information, wall and room area/volume data
"""
function parse_JSON()
    run(`sudo chmod +rwx connectivity.json`)
    connectivity = Dict()
    # using connectivity from json and converting it into a julia dictionary
    JSON.open("connectivity.json", "r") do f
    global connectivity
    dicttxt = JSON.read(f, String)  # file information to string
    connectivity = JSON.parse(dicttxt)  # parse and transform data
    end
end

"""
create_graph() takes the connectivity dict as input, and 
returns a MetaGraph with room data at nodes and wall data at edges
"""
function create_graph(connectivity)
    rooms = String[]
    for i in 1:length(connectivity)
        text = "room" *string(i)
        push!(rooms, text)
    end

    buildNetwork = MetaGraphsNext.MetaGraph(Graphs.Graph(), VertexData = Room, EdgeData = Wall, graph_data = "build connec model")

    # Create Nodes
    # The room name cannot directly be fed into the network Symbol so it has to be
    # converted to a Symbol first and then used
    for room in rooms
        for (key, value) in connectivity
            if (room==key)
                sym = Symbol(key)
                buildNetwork[sym] = Room(key, connectivity[key]["volume"])
            end
        end
    end

    buildNetwork[Symbol("room0")] =  Room("room0", 1000)
    # println("\n NODES CREATED\n")

    # Create Edges
    for (key, value) in connectivity
        itr = 1
        if length(connectivity[key]["neighbors"])!=0
            for rooms in connectivity[key]["neighbors"]
                area = connectivity[key]["wall"][itr] * height
                sym1 = Symbol(key)
                sym2 = Symbol(rooms)
                buildNetwork[sym1, sym2] = Wall(area, connectivity[key]["thickness"])
                itr+=1
            end
        end
    end

    # println("\n EDGES CREATED\n")
    return buildNetwork
end

"""
plots the MetaGraph
"""
function plot_graph(buildNetwork)
    nRooms = Graphs.nv(buildNetwork)-1;
    nodefillc = distinguishable_colors(nRooms+1, colorant"blue")
    nodelabel = 1:nRooms+1
    graph_viz = gplot(buildNetwork, nodelabel=nodelabel, nodefillc=nodefillc)
    draw(PNG("graph_viz.png", 30cm, 30cm), graph_viz)

    println("\nGraph Created Successfully!!\n")
end