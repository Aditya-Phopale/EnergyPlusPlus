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