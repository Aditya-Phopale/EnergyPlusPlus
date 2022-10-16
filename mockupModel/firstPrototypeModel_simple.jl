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

###

## Three Port
function ThreePort(; name, v1_start = 0.0, v2_start = 0.0, i1_start = 0.0, i2_start = 0.0, i3_start = 0.0)
    @named p1 = Pin()
    @named p2 = Pin()
    @named n = Pin()
    sts = @variables begin
        v1(t) = v1_start
        v2(t) = v2_start
        i1(t) = i1_start
        i2(t) = i2_start
        i3(t) = i3_start
        vc(t) = v1_start
    end
    eqs = [v1 ~ p1.v - n.v
           v2 ~ p2.v - n.v
           0 ~ p1.i + p2.i - n.i
           i1 ~ p1.i
           i2 ~ p2.i
           i3 ~ n.i
          ]
    return compose(ODESystem(eqs, t, sts, []; name = name), p1, p2, n)
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

###

## Traversing the graph to create the network model
nRooms = nv(buildNetwork);
nWalls = ne(buildNetwork);

@named ground = Ground()
@parameters t
D = Differential(t)
R1wall = 1
R2wall = 1
Cwall = 1

rooms = vertices(buildNetwork)
walls = edges(buildNetwork)
eqs = []
systemBuild = [ground]
capacitor_room_array = []
wall_array = Dict()

currRoomLabel = label_for(buildNetwork, 1)
@named capacitor_room_0 = Capacitor(C = buildNetwork[currRoomLabel].Volume, v_start=2.0)
push!(systemBuild, capacitor_room_0)
push!(eqs, connect(capacitor_room_0.n, ground.g))

currRoomLabel = label_for(buildNetwork, 2)
@named capacitor_room_1 = Capacitor(C = buildNetwork[currRoomLabel].Volume, v_start=1.0)
push!(systemBuild, capacitor_room_1)
push!(eqs, connect(capacitor_room_1.n, ground.g))

currRoomLabel = label_for(buildNetwork, 3)
@named capacitor_room_2 = Capacitor(C = buildNetwork[currRoomLabel].Volume, v_start=1.0)
push!(systemBuild, capacitor_room_2)
push!(eqs, connect(capacitor_room_2.n, ground.g))

currRoomLabel = label_for(buildNetwork, 4)
@named capacitor_room_3 = Capacitor(C = buildNetwork[currRoomLabel].Volume, v_start=1.0)
push!(systemBuild, capacitor_room_3)
push!(eqs, connect(capacitor_room_3.n, ground.g))

currRoomLabel = label_for(buildNetwork, 5)
@named capacitor_room_4 = Capacitor(C = buildNetwork[currRoomLabel].Volume, v_start=1.0)
push!(systemBuild, capacitor_room_4)
push!(eqs, connect(capacitor_room_4.n, ground.g))

@named wall_04 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_04)
push!(eqs, connect(wall_04.n, ground.g))
push!(eqs, connect(wall_04.p1, capacitor_room_0.p))
push!(eqs, connect(wall_04.p2, capacitor_room_4.p))

@named wall_03 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_03)
push!(eqs, connect(wall_03.n, ground.g))
push!(eqs, connect(wall_03.p1, capacitor_room_0.p))
push!(eqs, connect(wall_03.p2, capacitor_room_3.p))

@named wall_01 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_01)
push!(eqs, connect(wall_01.n, ground.g))
push!(eqs, connect(wall_01.p1, capacitor_room_0.p))
push!(eqs, connect(wall_01.p2, capacitor_room_1.p))

@named wall_14 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_14)
push!(eqs, connect(wall_14.n, ground.g))
push!(eqs, connect(wall_14.p1, capacitor_room_1.p))
push!(eqs, connect(wall_14.p2, capacitor_room_4.p))

@named wall_13 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_13)
push!(eqs, connect(wall_13.n, ground.g))
push!(eqs, connect(wall_13.p1, capacitor_room_1.p))
push!(eqs, connect(wall_13.p2, capacitor_room_3.p))

@named wall_12 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_12)
push!(eqs, connect(wall_12.n, ground.g))
push!(eqs, connect(wall_12.p1, capacitor_room_1.p))
push!(eqs, connect(wall_12.p2, capacitor_room_2.p))

@named wall_10 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_10)
push!(eqs, connect(wall_10.n, ground.g))
push!(eqs, connect(wall_10.p1, capacitor_room_1.p))
push!(eqs, connect(wall_10.p2, capacitor_room_0.p))

@named wall_24 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_24)
push!(eqs, connect(wall_24.n, ground.g))
push!(eqs, connect(wall_24.p1, capacitor_room_2.p))
push!(eqs, connect(wall_24.p2, capacitor_room_4.p))

@named wall_21 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_21)
push!(eqs, connect(wall_21.n, ground.g))
push!(eqs, connect(wall_21.p1, capacitor_room_2.p))
push!(eqs, connect(wall_21.p2, capacitor_room_1.p))

@named wall_31 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_31)
push!(eqs, connect(wall_31.n, ground.g))
push!(eqs, connect(wall_31.p1, capacitor_room_3.p))
push!(eqs, connect(wall_31.p2, capacitor_room_1.p))

@named wall_30 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_30)
push!(eqs, connect(wall_30.n, ground.g))
push!(eqs, connect(wall_30.p1, capacitor_room_3.p))
push!(eqs, connect(wall_30.p2, capacitor_room_0.p))

@named wall_42 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_42)
push!(eqs, connect(wall_42.n, ground.g))
push!(eqs, connect(wall_42.p1, capacitor_room_4.p))
push!(eqs, connect(wall_42.p2, capacitor_room_2.p))

@named wall_41 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_41)
push!(eqs, connect(wall_41.n, ground.g))
push!(eqs, connect(wall_41.p1, capacitor_room_4.p))
push!(eqs, connect(wall_41.p2, capacitor_room_1.p))

@named wall_40 = wall_2R1C(; R1 = R1wall, R2 = R2wall, C = Cwall)
push!(systemBuild, wall_40)
push!(eqs, connect(wall_40.n, ground.g))
push!(eqs, connect(wall_40.p1, capacitor_room_4.p))
push!(eqs, connect(wall_40.p2, capacitor_room_0.p))


@named buildingThermalModel = ODESystem(eqs, t, systems=systemBuild)
sys = structural_simplify(buildingThermalModel)
prob = ODAEProblem(sys, Pair[] , (0, 50.0))
sol = solve(prob, Tsit5())  

println("Executed successfully")
plot(sol, vars = [capacitor_room_0.v, capacitor_room_1.v, capacitor_room_2.v, capacitor_room_3.v, capacitor_room_4.v], title = "Mockup Model", labels = ["Room 0 Temperature" "Room 1 Temperature" "Room 2 Temperature" "Room 3 Temperature" "Room 4 Temperature"], lw = 3)
savefig("mockUpModelPlot.png")

using GraphPlot, Colors
nodefillc = distinguishable_colors(nv(g), colorant"blue")
nodelabel = 1:nv(buildNetwork)
gplot(buildNetwork, nodelabel=nodelabel, nodefillc=nodefillc)

#using StatsPlots
#violin(["Room 0 Temperature" "Room 1 Temperature" "Room 2 Temperature" "Room 3 Temperature" "Room 4 Temperature"], [capacitor_room_0.v capacitor_room_1.v capacitor_room_2.v capacitor_room_3.v capacitor_room_4.v], leg=false)