sudo -E env "PATH=$PATH" python3 connectivity_python.py --allow-root
sudo chmod +rwx connectivity.json
julia connectivity_julia.jl 
