"""
Room is used to initialize the graph nodes
It stores a string to identify the nodes, and volume 
Data is later used to calculate capacitance to construct the circuit
"""
struct Room
	Name::String
	Vol::Float64
end

"""
Wall is used to initialize the graph edges
It stores a wall area and thickness 
Data is later used to calculate the resistance and capacitance for 2R1C circuit
"""
struct Wall
	Ar::Float64
	t::Float64
end