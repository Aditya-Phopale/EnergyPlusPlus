import base64

def msg_to_png(string):
    return base64.b64decode(string)

def png_to_msg(image):
    return base64.b64encode(image)

def detect_rooms(image):
    # load yolov5 model
    # run to get labels
    # display rooms on the image
    return image, labels

def get_connectivity(image):
    # deterministically get the graph
    return