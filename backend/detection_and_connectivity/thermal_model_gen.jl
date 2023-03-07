"""
parse_JSON() reads the JSON file and returns connectivity dictionary
with neighbours information, wall and room area/volume data
"""
function parse_JSON()
    run(`sudo chmod +rwx connectivity.json`)
    connectivity = Dict()
    # using connectivity from json and converting it into a julia dictionary
    JSON.open("connectivity.json", "r") do f
    global connectivity
    dicttxt = JSON.read(f, String)  # file information to string
    connectivity = JSON.parse(dicttxt)  # parse and transform data
    end
end

