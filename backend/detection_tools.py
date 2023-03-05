import base64
from io import BytesIO
import re
import julia
from PIL import Image

BASE_PATH = "./detection_and_connectivity/"

def msg_to_png(byte_string):
    base_string = byte_string.decode()  # string -> bytes
    base_string = base_string[8:]  # remove xml data format
    base_string = re.sub('^data:image/.+;base64,', '', base_string) # remove image header

    bytes_decoded = base64.b64decode(base_string)  # string -> bytes of image
    img = Image.open(BytesIO(bytes_decoded))  # bytes -> PIL image object
    return img

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