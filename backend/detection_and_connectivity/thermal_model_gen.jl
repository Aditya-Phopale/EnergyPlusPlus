include("utils.jl")
include("custom_datastructure.jl")

FIG_PATH = "images/"

"""
parse_JSON() reads the JSON file and returns connectivity dictionary
with neighbours information, wall and room area/volume data
"""
function parse_JSON()
    # run(`sudo chmod +rwx connectivity.json`) ????
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
        text = "room" * string(i)
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

    return buildNetwork
end

"""
creating thermal network
Takes buildNetwork MetaGraph as input
Generates the circuit with nodes as Capacitor + heating source
and walls as 2R1C circuit 
Returns an ODE system
"""
function creat_thermalnetwork(buildNetwork, t)
    nRooms = Graphs.nv(buildNetwork)-1;
    nWalls = Graphs.ne(buildNetwork);
    
    @named ground = Ground()
    
    # The Room_array  will provide a way to give the named returned value a unique value every time 
    rho = 1.225 # Kg/m3
    Cp = 1000 #J/Kg/K
    V = 0.0
    V_heating = 50.0 # Temperature heating fluid
    V_desired = 20.0 # desired Temperature
    proportional_const = 1.0 # m_dot * Cp_air
    prop_const = zeros(nRooms, 1)
    prop_const[4] = proportional_const
    
    #constVSource = 303
    #@named source = Voltage()
    #@named constant_v = Constant(k=constVSource)
    #@named variable_v = Cosine(frequency=frequency, amplitude=10, phase=pi, offset=293.0, smooth=true)
    
    #rooms = MetaGraphsNext.vertices(buildNetwork)
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
    global i = 1
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
        
    @named wall_array 1:nWalls i -> wall_2R1C(; R1 = R1_walls[i], R2 = R2_walls[i], C = C_walls[i])
    
    global i = 1
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
    
    @named buildingThermalModel = ODESystem(eqs, t, systems=systemBuild)

    return buildingThermalModel, Room_array, wall_array
end