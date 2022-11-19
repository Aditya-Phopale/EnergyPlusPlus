using MetaGraphsNext
using Graphs
using JSON
using DataStructures
using ModelingToolkit, OrdinaryDiffEq, Plots
using ModelingToolkitStandardLibrary.Electrical
using ModelingToolkitStandardLibrary.Blocks: Constant
using Compose, Cairo

include("utils.jl")

struct Room
	Name::String
	Vol::Float64
end

struct Wall
	Ar::Float64
	t::Float64
end

## Wall function
function wall_2R1C(; name, R1, R2, C)
    
    @named threeport = ThreePort()
    @unpack v1,v2,i1,i2,i3,vc = threeport

    pars = @parameters begin 
        R1 = R1
        R2 = R2
        C = C
    end 

    wall_eqs = [
        v2 ~ R2*i2 + vc
        v1 ~ R1*i1 + vc
        D(vc) ~ i3/C
        ]
    extend(ODESystem(wall_eqs, t, [], pars; name = name), threeport)   
end


println("\nRUNNING JULIA SCRIPT\n")


# metadata that can be added to python later. Assuming a value for now
height = 3.0
connectivity = Dict()
# using connectivity from json and converting it into a julia dictionary
open("connectivity.json", "r") do f
    global connectivity
    dicttxt = read(f, String)  # file information to string
    connectivity=JSON.parse(dicttxt)  # parse and transform data
end

rooms = String[]
for i in 1:length(connectivity)
    text = "room" *string(i-1)
    push!(rooms, text)
end


buildNetwork = MetaGraph(Graph(), VertexData = Room, EdgeData = Wall, graph_data = "build connec model")
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
println("\n NODES CREATED\n")

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

println("\n EDGES CREATED\n")


print("\nGraph Created Successfully!!\n")




nRooms = nv(buildNetwork);
nWalls = ne(buildNetwork);

@named ground = Ground()
@parameters t
D = Differential(t)
R1wall = 1
R2wall = 1
Cwall = 1
counter = 1
rooms = vertices(buildNetwork)
walls = edges(buildNetwork)
eqs = []
systemBuild = [ground]
wall_array = Dict()

# The capacitor_room will provide a way to give the named returned value a unique value every time 
# Checkout Julia maps for more
capacitor_room = MutableLinkedList{Any}()
# This keeps a collection of all initialized capacitors which later on is used for wall connections
capacitor_collection = MutableLinkedList{Any}()

# Define capacitance for rooms
for i in 1:length(connectivity)
    currRoomLabel = label_for( buildNetwork, i)
    curr = String(currRoomLabel)
    curr = string(curr[length(curr)])
    cap_room = @named capacitor_room[collect(curr)] = Capacitor(C = buildNetwork[currRoomLabel].Vol, v_start=2.0)
    push!(capacitor_collection, cap_room[1])
    # global capacitor, systemBuild, ground, eqs, buildNetwork
    # print(typeof(cap))
    # @named capacitorString[currRoomLabel_new] = 
    push!( systemBuild, cap_room[1])
    push!(eqs, connect(cap_room[1].n, ground.g))
end



wall_room = MutableLinkedList{Any}()

# This string gives unique name to connections - has to be as long as there are connections in our graph
##TODO: Find a way to add variable length strings to the @named entity
temp_string = "abcdefghijklmnopqrstuvwxyz1234567890"
# define Resistance for walls 
for (key, value) in connectivity
    itr = 1
    if length(connectivity[key]["neighbors"])!=0
        for rooms in connectivity[key]["neighbors"]
            # get indices for the rooms that are being dealt with
            first_room = string(key[length(key)])
            second_room = string(rooms[length(rooms)])
            first_room_n = (parse(Int, first_room) + 1)
            second_room_n = (parse(Int, second_room) + 1)
            global counter
            temp_name = string(temp_string[counter])
            z = @named wall_room[collect(temp_name)] = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
            push!(systemBuild, z[1])
            push!(eqs, connect(z[1].n, ground.g))
            push!(eqs, connect(z[1].p1, capacitor_collection[first_room_n].p))
            push!(eqs, connect(z[1].p2, capacitor_collection[second_room_n].p))
            counter+=1        
        end
    end
end

@named buildingThermalModel = ODESystem(eqs, t, systems=systemBuild)
println("\n Built Thermal Model \n")

sys = structural_simplify(buildingThermalModel)
println("\n Simplified Structure \n")

prob = ODAEProblem(sys, Pair[] , (0, 50.0))
println("\n ODE problem Defined \n")

sol = solve(prob, Tsit5())

println("Executed successfully")

for (key,value) in connectivity
    i = parse(Int, string(key[length(key)]))
    plot(sol, vars = [capacitor_collection[i+1].v], title = "Mockup Model", labels = ["Room Temperature"])
    text = key*"_"*"Prototype_Model_Simple.png"
    savefig(text)
end

using GraphPlot, Colors
nodefillc = distinguishable_colors(nv(buildNetwork), colorant"blue")
nodelabel = 0:nv(buildNetwork)-1
graph_viz = gplot(buildNetwork, nodelabel=nodelabel, nodefillc=nodefillc)
draw(PNG("graph_viz.png", 30cm, 30cm), graph_viz)