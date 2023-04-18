import base64
from io import BytesIO
import os
import re
from PIL import Image

BASE_PATH = "./detection_and_connectivity/"
FIG_PATH = "./detection_and_connectivity/images/"

def msg_to_img(byte_string):
    base_string = byte_string.decode()  # string -> bytes
    base_string = base_string[8:]  # remove xml data format
    base_string = re.sub('^data:image/.+;base64,', '', base_string) # remove image header

    bytes_decoded = base64.b64decode(base_string)  # string -> bytes of image
    img = Image.open(BytesIO(bytes_decoded))  # bytes -> PIL image object
    return img

def img_to_msg(image):
    return base64.b64encode(image)

def detect_rooms(image):
    image.save(FIG_PATH + "floor_plan.png")
    exec(open(BASE_PATH + "connectivity_python.py").read())
    rooms_render = Image.open(FIG_PATH + "boxed_ordered_rooms.png")
    return rooms_render

# https://stackoverflow.com/questions/49750067/running-julia-jl-file-in-python
def run_thermal_model():
    print("got into thermal model")
    os.chdir(BASE_PATH)
    os.system('julia connectivity_julia.jl')  # runs the script on connectivity.json
    os.chdir("../")
    print("executed julia")
    thermal_model = Image.open(FIG_PATH + "Prototype_Model_Simple.png")
    graph = Image.open(FIG_PATH + "graph_viz.png")
    
    return thermal_model, graph