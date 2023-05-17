include("thermal_model_gen.jl")
include("plot_functions.jl")

println("RUNNING JULIA SCRIPT")


# metadata that can be added to python later. Assuming a value for now
height = 3.0

# parsing JSON file generated to extract connectivity (neighbours, wall and room data) information
connectivity = parse_JSON()


# creating a graph with data from connectivity
buildNetwork = create_graph(connectivity)

# plotting the generated graph and saving
plot_graph(buildNetwork)
println("Graph Created Successfully!!")

@parameters t
D = Differential(t)


# creating the thermal model (system of ode) from the graph as input
buildingThermalModel, Room_array, wall_array = creat_thermalnetwork(buildNetwork, t)
println("Built Thermal Model")

# simplifying the ode system
sys = structural_simplify(buildingThermalModel)
println("Simplified Structure")

prob = ODAEProblem(sys, Pair[] , (0, 24.0))
println("ODE problem Defined")

sol = OrdinaryDiffEq.solve(prob, OrdinaryDiffEq.ROCK2())
println("Executed successfully")

# plotting simulation results
plot_results(buildNetwork, sol, Room_array, wall_array)
