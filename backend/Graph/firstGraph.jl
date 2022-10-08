using MetaGraphsNext
using Graphs

struct Room
	Vol::Float64
end

struct Wall
	Ar::Float64
	t::Float64
end


buildNetwork = MetaGraph(Graph(), VertexData = Room, EdgeData = Wall, graph_data = "build connec model")

buildNetwork[:mainroom] = Room(1.5);
buildNetwork[:out] = Room(100);

buildNetwork[:mainroom, :out] = Wall(1.0, 0.1);



nRooms = nv(buildNetwork);
nWalls = ne(buildNetwork);


