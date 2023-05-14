cd backend
# WARNING: You need to put your floorplan inside backend/detection_and_connectivity/images with the name "floor_plan.png"
python3 detection_and_connectivity/connectivity_python.py
cd detection_and_connectivity
julia connectivity_julia.jl
cd -
