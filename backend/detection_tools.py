import base64
import julia
from PIL import Image

BASE_PATH = "./detection_and_connectivity/"

def msg_to_png(string):
    return base64.b64decode(string)

def png_to_msg(image):
    return base64.b64encode(image)

def detect_rooms(image):
    image.save(BASE_PATH + "floor_plan.png")
    exec(open(BASE_PATH + "connectivity_python.py").read())
    rooms_render = Image.open(BASE_PATH + "boxed_ordered_rooms.png")
    return rooms_render

# https://stackoverflow.com/questions/49750067/running-julia-jl-file-in-python
def run_thermal_model():
    j = julia.Julia(compiled_modules=False)
    j.include(BASE_PATH + "connectivity_julia.jl")
    thermal_model = Image.open(BASE_PATH + "images/plot.png")
    graph = Image.open(BASE_PATH + "graph_vis.png")
    return thermal_model, graph