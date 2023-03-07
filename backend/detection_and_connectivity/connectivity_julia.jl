include("thermal_model_gen.jl")
include("plot_functions.jl")

println("\nRUNNING JULIA SCRIPT\n")

# metadata that can be added to python later. Assuming a value for now
height = 3.0

# parsing JSON file generated to extract connectivity (neighbours, wall and room data) information
connectivity = parse_JSON()

# creating a graph with data from connectivity
buildNetwork = create_graph(connectivity)

# plotting the generated graph and saving
plot_graph(buildNetwork)
println("\nGraph Created Successfully!!\n")

# creating the thermal model (system of ode) from the graph as input
buildingThermalModel = creat_thermalnetwork(buildNetwork)
println("\n Built Thermal Model \n")

# simplifying the ode system
sys = structural_simplify(buildingThermalModel)
println("\n Simplified Structure \n")

prob = ODAEProblem(sys, Pair[] , (0, 86400.0))
println("\n ODE problem Defined \n")

sol = OrdinaryDiffEq.solve(prob, OrdinaryDiffEq.Tsit5())

println("Executed successfully")

plot_results(buildNetwork)
