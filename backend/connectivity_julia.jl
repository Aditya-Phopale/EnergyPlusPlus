import Pkg; Pkg.add("MetaGraphsNext")
import Pkg; Pkg.add("Graphs")
import Pkg; Pkg.add("JSON")


using MetaGraphsNext
using Graphs
using JSON

println("\n\nRUNNING JULIA SCRIPT\n")

struct Room
	Name::String
	Vol::Float64
end

struct Wall
	Ar::Float64
	t::Float64
end

# metadata that can be added to python later. Assuming a value for now
height = 3.0
#connectivity = Dict("room4"=> Dict("neighbors"=> ["room2", "room1", "room0"], "wall"=> [2.977658235000927, 1.0955763457436944, 2.6962233043852306], "area"=> 15.472864785008328, "thickness"=> 0.25, "volume"=> 46.418594355024986), "room3"=> Dict("neighbors"=> ["room1", "room0"], "wall"=> [2.309544881184896, 2.0], "area"=> 5.825389295701141, "thickness"=> 0.25, "volume"=> 17.476167887103422), "room2"=> Dict("neighbors"=> ["room1"], "wall"=> [2.0, 2.346283685593378], "area"=> 7.558755450801348, "thickness"=> 0.25, "volume"=> 22.676266352404042), "room1"=> Dict("neighbors"=> ["room0"], "wall"=> [1.0, 2.309544881184896, 2.346283685593378, 1.0], "area"=> 3.715817185759679, "thickness"=> 0.25, "volume"=> 11.147451557279037), "room0"=> Dict("neighbors"=> [], "wall"=> [2.6962233043852306, 2.0114615692229227, 1.2110642792563056], "area"=> 7.989626554018199, "thickness"=> 0.25, "volume"=> 23.968879662054597))
connectivity = Dict()

# using connectivity from json and converting it into a julia dictionary
open("connectivity.json", "r") do f
    global connectivity
    dicttxt = read(f, String)  # file information to string
    connectivity=JSON.parse(dicttxt)  # parse and transform data
end

buildNetwork = MetaGraph(Graph(), VertexData = Room, EdgeData = Wall, graph_data = "build connec model")
# Create Nodes
# The room name cannot directly be fed into the network Symbol so it has to be
# converted to a Symbol first and then used
for (key, value) in connectivity
	sym = Symbol(key)
	buildNetwork[sym] = Room(key, connectivity[key]["volume"])
end

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

nRooms = nv(buildNetwork);
nWalls = ne(buildNetwork);

print("\nGraph Created Successfully!!\n")