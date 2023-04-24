# EnergyPlusPlus  

Optimizing energy for building infrastructure  
BGCE class 22-23' honours project  

https://energyplusplus.gatsbyjs.io/


#### Prerequisites 

You, of course, need a web browser to render html and css

Python backend requires flask: `pip install flask flask-cors`  

Julia packages required:  

```
Dict{String, VersionNumber} with 18 entries:
  "Distributions"                  => v"0.25.86"
  "StatsPlots"                     => v"0.15.1"
  "Graphs"                         => v"1.7.1"
  "StochasticDiffEq"               => v"6.50.1"
  "JSON"                           => v"0.21.3"
  "MetaGraphsNext"                 => v"0.4.0"
  "IfElse"                         => v"0.1.1"
  "DataStructures"                 => v"0.18.13"
  "Compose"                        => v"0.9.4"
  "OrdinaryDiffEq"                 => v"6.19.0"
  "Plots"                          => v"1.31.3"
  "Colors"                         => v"0.12.8"
  "ModelingToolkit"                => v"8.17.0"
  "GraphPlot"                      => v"0.5.2"
  "QuadGK"                         => v"2.6.0"
  "DifferentialEquations"          => v"7.2.0"
  "Cairo"                          => v"1.0.5"
  "ModelingToolkitStandardLibrary" => v"1.4.0"
```

#### How to run the project with gatsby cloud web interface:  

In terminal start local computational server:
```
    cd backend/
    python3 app.py
```
Then open web interface, and then feel free to click around at https://energyplusplus.gatsbyjs.io/

#### How to run with local gatsby deployment:  

To use Gatsby, install Node.js and npm at the following link: [Node.js download](https://nodejs.org/en/download/) and install Gatsby CLI with
    ```
    npm install -g gatsby-cli
    ```
in the terminal. Check it the installation was successful with
    ```
    gatsby --version
    ```
You should be on v3 or newer.

To run the frontend application, locally go into the frontend folder:
    ```
    cd ./directory_to_frontend
    ```

Run in the terminal:
    ```
    npm install
    ```
Note: if you're on Mac, especially ARM architecture, you might need to force installation by:
    ```
    npm install --force
    ```

Finally, run in the terminal: 
    ```
    gatsby develop
    ```
    -> is nice for developement, because changes can be immediatley seen in the browser. 
    
for production run: 
    ```
    gatsby build 
    ```
    -> has to be only done once, after changing the code. This builds the website in an optimized way into public
    and then 
    ```
    gatsby serve 
    ```
    -> now the website is executed, URL should be seen in the terminal e.g. http://localhost:9000/

run backend as previously, should work  


__Graph Connectivity__

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
