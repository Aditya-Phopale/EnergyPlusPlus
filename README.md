# EnergyPlusPlus  

Optimizing energy for building infrastructure  
BGCE class 22-23' honours project  

# Graph Connectivity

Currently, the connectivity_python.py file takes the image "test.png" and converts it into a connectivity graph and saves it in connectivity.json format. 

The connectivity_julia.jl takes this connectivity.json and initializes a graph with nodes and edges according to the metagraph description provided initially in the RC subsystem.

It seems that yolov5 repository is not necessary at the moment and if the weight is provided, the torch command just downloads and caches the yolov5 required files for the weight loading. (need to test it on different systems at the moment)

There is also a jupyter notebook test_run.ipynb where you could go through the code step by step for each outpput. 

The result of the bounding box detection is saved as image0.jpg.

You can run all of this by running the run.sh bash script in terminal.

```
./run.sh
```
Or you can run them individually to first check the connectivity json file and then see the running of julia file.

```
python3 connectivity_python.py
julia connectivity_julia.jl
```
(Check run.sh incase permissions are required)