using MetaGraphsNext
using Graphs

using ModelingToolkit, OrdinaryDiffEq, Plots
using ModelingToolkitStandardLibrary.Electrical
using ModelingToolkitStandardLibrary.Blocks: Constant

## Data from Segmentation of floor plan
# coordinates in pixels, area and vol converted to SI units
# Room 0 (736.1, 999.2) to (1363.7, 1697.1) - Neighbors: 4, 3, 1 (2.6962233043852306, 2.0114615692229227, 1.2110642792563056), Vol: 23.968879662054597
# Room 1 (1236.8, 1735.7) to (1691.2, 22098.6) - Neighbors: 4, 3, 2, 0 (1.0, 2.309544881184896, 2.346283685593378, 1.0), Vol: 11.147451557279037
# Room 2 (1296.1, 1016.4) to (1722.5, 1518.1) - Neighbors: 4, 1 (2.0, 2.346283685593378), Vol: 22.676266352404042
# Room 3 (1303.2, 1512.5) to (1697.4, 1779.4) - Neighbors: 1, 0 (2.309544881184896, 2.0), Vol: 17.476167887103422
# Room 4 (787.3, 1575.3) to (1240.3, 2074.6) - Neighbors: 2, 1, 0 (2.977658235000927, 1.0955763457436944, 2.6962233043852306), Vol: 46.418594355024986

# Wall thickness: 0.25m
# Room height: 3m

# Directly creating the graph for mockup Model
struct Room
	roomId::Int64
	Volume::Float64
end

struct Wall
	Area::Float64
	thickness::Float64
end

buildNetwork = MetaGraph(Graph(), VertexData = Room, EdgeData = Wall, graph_data = "build connec model")

buildNetwork[:room_0] = Room(0,24);
buildNetwork[:room_1] = Room(1,11);
buildNetwork[:room_2] = Room(2,23);
buildNetwork[:room_3] = Room(3,17);
buildNetwork[:room_4] = Room(4,46);

buildNetwork[:room_0, :room_4] = Wall(2.7, 0.25);
buildNetwork[:room_0, :room_3] = Wall(2.0, 0.25);
buildNetwork[:room_0, :room_1] = Wall(1.2, 0.25);

buildNetwork[:room_1, :room_4] = Wall(1.0, 0.25);
buildNetwork[:room_1, :room_3] = Wall(2.3, 0.25);
buildNetwork[:room_1, :room_2] = Wall(2.3, 0.25);
buildNetwork[:room_1, :room_0] = Wall(1.0, 0.25);

buildNetwork[:room_2, :room_4] = Wall(2.0, 0.25);
buildNetwork[:room_2, :room_1] = Wall(2.3, 0.25);

buildNetwork[:room_3, :room_1] = Wall(2.3, 0.25);
buildNetwork[:room_3, :room_0] = Wall(2.0, 0.25);

buildNetwork[:room_4, :room_2] = Wall(3.0, 0.25);
buildNetwork[:room_4, :room_1] = Wall(1.1, 0.25);
buildNetwork[:room_4, :room_0] = Wall(2.7, 0.25);


#mktemp() do file, io
#	savegraph(file, buildNetwork, DOTFormat())
#	print(read(file, String))
#end

## Wall function
function wall_2R1C(; name, R1, R2, C)
    
    @named threeport = ThreePort()
    @unpack v1,v2,i1,i2,i3,vc = threeport

    pars = @parameters begin 
        R1 = R1
        R2 = R2
        C = C
    end 

    # @named r1 = Resistor(R=R1)
    # @named r2 = Resistor(R=R2)
    # @named capacitor = Capacitor(C=C)

    wall_eqs = [
        v2 ~ R2*i2 + vc
        v1 ~ R1*i1 + vc
        D(vc) ~ i3/C
        
        
        # v ~ r1.p.v - r1.n.v
        # connect(oneport.p, r1.p),
        # connect(oneport.n, r2.n)
        # i ~ r1.p.i
        ]
    extend(ODESystem(wall_eqs, t, [], pars; name = name), threeport)   
end

## Traversing the graph to create the network model

nRooms = nv(buildNetwork);
nWalls = ne(buildNetwork);

Croom = Array{Float64}(undef, nRooms)
Cwall = Array{Float64}(undef, nWalls)
R1wall = Array{Float64}(undef, nWalls)
R2wall = Array{Float64}(undef, nWalls)

@named ground = Ground()
@parameters t
D = Differential(t)

rooms = vertices(buildNetwork)
for currRoom in rooms
	currRoomLabel = label_for(buildNetwork, currRoom)
	print("Entering ")
	println(currRoomLabel)
	#println((buildNetwork[currRoomLabel].Volume))
	if currRoom == 1
		@named capacitor_room[currRoom] = Capacitor(C = buildNetwork[currRoomLabel].Volume, v_start=2.0)
	else
		@named capacitor_room[currRoom] = Capacitor(C = buildNetwork[currRoomLabel].Volume, v_start=1.0)
	end
end

walls = edges(buildNetwork)
for currWall in walls
	println("Wall between ", label_for(buildNetwork, src(currWall)), " and ", label_for(buildNetwork, dst(currWall)))
end
