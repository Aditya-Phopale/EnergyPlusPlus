include("utils.jl")
include("custom_datastructure.jl")
include("thermal_model_gen.jl")

println("\nRUNNING JULIA SCRIPT\n")


# metadata that can be added to python later. Assuming a value for now
height = 3.0

# parsing JSON file generated to extract connectivity (neighbours, wall and room data) information
connectivity = parse_JSON()

# creating a graph with data from connectivity
buildNetwork = create_graph(connectivity)

# plotting the generated graph and saving
plot_graph(buildNetwork)

nRooms = Graphs.nv(buildNetwork)-1;
nWalls = Graphs.ne(buildNetwork);

@named ground = Ground()
@parameters t
D = Differential(t)

# The Room_array  will provide a way to give the named returned value a unique value every time 
rho = 1.225 # Kg/m3
Cp = 1000 #J/Kg/K
V = 273.0
V_heating = 323.0 # Temperature heating fluid
V_desired = 293.0 # desired Temperature
proportional_const = 1.0 # m_dot * Cp_air
prop_const = zeros(nRooms, 1)
prop_const[4] = proportional_const

#constVSource = 303
#@named source = Voltage()
#@named constant_v = Constant(k=constVSource)
#@named variable_v = Cosine(frequency=frequency, amplitude=10, phase=pi, offset=293.0, smooth=true)

rooms = MetaGraphsNext.vertices(buildNetwork)
walls = MetaGraphsNext.edges(buildNetwork)

@named source = Voltage()
@named constant_voltage = Constant(k=V)

eqs = [connect(constant_voltage.output, source.V)]
push!(eqs, connect(source.n, ground.g))
systemBuild = [ground]
push!(systemBuild, source)
push!(systemBuild, constant_voltage)

# adding source voltage (ambient)
#push!(systemBuild, variable_v)
#push!(eqs, connect(variable_v.output, source.V))
#push!(eqs, connect(ground, source.n))

# wall data for initializing wall function
i = 1
k_wall = 0.6
rho_wall = 2000 # Kg/m3
Cp_wall = 840  # J/Kg/K
R1_walls = zeros(nWalls)
R2_walls = zeros(nWalls)
C_walls = zeros(nWalls)
for currWall in walls
    sourceRoom = Graphs.src(currWall)
	destRoom = Graphs.dst(currWall) 
    Data_currwall = buildNetwork[MetaGraphsNext.label_for(buildNetwork,sourceRoom), MetaGraphsNext.label_for(buildNetwork,destRoom)] 
    Area_currwall = Data_currwall.Ar
    Thick_currwall = Data_currwall.t
    R1_walls[i] = Thick_currwall/Area_currwall/k_wall/2
    R2_walls[i] = Thick_currwall/Area_currwall/k_wall/2
    C_walls[i] = rho_wall * Cp_wall * (Area_currwall * Thick_currwall)
    global i = i+1
end

@named Room_array 1:nRooms i -> Room_component_pid(; Croom = buildNetwork[MetaGraphsNext.label_for( buildNetwork, i)].Vol * rho * Cp, V_heating, V_desired, proportional_const = prop_const[i])

# Define capacitance for rooms
for i in 1:nRooms
    push!(eqs, connect(Room_array[i].n1, Room_array[i].n2, ground.g))
    push!(systemBuild, Room_array[i])
end

println("\nADDED ROOM COMPONENT TO NODES\n")

@named wall_array 1:nWalls i -> wall_2R1C(; R1 = R1_walls[i], R2 = R2_walls[i], C = C_walls[i])

i = 1
for currWall in walls
    sourceRoom = Graphs.src(currWall)
	destRoom = Graphs.dst(currWall)    
    push!(systemBuild, wall_array[i])
	push!(eqs, connect(wall_array[i].n, ground.g))
	push!(eqs, connect(wall_array[i].p1, Room_array[sourceRoom].p))
    if (MetaGraphsNext.label_for( buildNetwork, nRooms+1) == Symbol("room0"))
        push!(eqs, connect(wall_array[i].p2, source.p))
    else
	    push!(eqs, connect(wall_array[i].p2, Room_array[destRoom].p))
    end
    global i = i+1
end

println("\nCONNECTED NODES WITH 2R1C\n")

@named buildingThermalModel = ODESystem(eqs, t, systems=systemBuild)
println("\n Built Thermal Model \n")

sys = structural_simplify(buildingThermalModel)
println("\n Simplified Structure \n")

prob = ODAEProblem(sys, Pair[] , (0, 86400.0))
println("\n ODE problem Defined \n")

sol = OrdinaryDiffEq.solve(prob, OrdinaryDiffEq.Tsit5())

println("Executed successfully")

Plots.plot()

for i in 1:nRooms
   Plots.plot!(sol, vars = [Room_array[i].v1], labels = "Room Temperature "*string(i-1), linewidth=3, fontsize=14, legend=:topright)
#    if i==4
#    Plots.plot!(sol, vars = [Room_array[i].i3], labels = "", linewidth=3, fontsize=14, legend=:bottomright)
#    end
   # text = "Room_"*string(i)*"_"*"Prototype_Model_Simple.png"
   # savefig(text)
end
Plots.xlabel!("time (s)")
Plots.ylabel!("Heat Flux (J/s)")
graph_title = "Prototype_Model_Simple.png"
Plots.savefig(graph_title)