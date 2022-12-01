# EnergyPlusPlus  

Optimizing energy for building infrastructure  
BGCE class 22-23' honours project  

*Little science with a lot of selling*  

-- some description goes here --  

#### How to run web wrapping  
To test web staff, first do `pip install flask flask-cors` either in virtual env, or locally  
Open frontend/index.html with a web browser, then run backend/app.py  

---

#### Section to-be moved or removed description before merging into main

[Drive with meetings and personal info](https://drive.google.com/drive/folders/1SanSRlWefZBU_X_bpvDEbwvL42WLAsri)  
[SDE extra materials](https://splm.sharepoint.com/:f:/r/sites/BGCE2022/Shared%20Documents/General/Literature/sde?csf=1&web=1&e=Ma0rYR)  
Articles on RC and ML to-be added :smiley:  
How git works:  [link from Manish to-be added]()  

Planned schedule:
| Date | Type |
| - | - |
|19.07|regular meeting|
|30.08| -- |
|13.09| -- |
|18.10|Milestone 1.|
|08.11| -- |
|22.11| -- |
|06.12| -- |
|20.12|Milestone 2.|
|10.01| -- |
|31.01| -- |
|14.03| -- |
|21.03|Milestone 3.|

Feel free to add other things for better navigation or important nuances 
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

# GUI in Gatsby
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
    -> now the website is executed and can be seen in e.g. http://localhost:9000/
