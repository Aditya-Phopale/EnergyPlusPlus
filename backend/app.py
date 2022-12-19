# https://tms-dev-blog.com/python-backend-with-javascript-frontend-how-to/
# https://github.com/josephlee94/intuitive-deep-learning/blob/master/Building%20a%20Web%20Application%20to%20Deploy%20Machine%20Learning%C2%A0Models/imgrec_webapp.py

from flask import Flask, request, redirect
from flask_cors import CORS
from PIL import Image

import detection_tools as dt

app = Flask(__name__)
CORS(app)

# buffers
rooms_image = dict()
connectivity = dict()
rc_data = dict()

# if data unavailable yet
loading_image = Image.open("../image_path.png")


@app.route('/image/<picture_id>')
def callback(picture_id):
    if request.method == "PUT":
        # extract an image from the request
        received_data = request.get_json()
        floor_plan = dt.msg_to_png(received_data)
        # run yolo v5 simulation
        rooms, graph = dt.detect_rooms(floor_plan)
        rooms_image[picture_id] = rooms
        connectivity[picture_id] = graph
        # return success
        return flask.Response(response={"status":"success"}, status=201)
    # operation not permitted
    return flask.Response(status=403)


@app.route('/rooms/<picture_id>')
def callback_rooms(picture_id):
    if request.method == "GET":
        if picture_id in rooms_image:
            return flask.Response(response=dt.png_to_msg(rooms_image[picture_id]), status=201)
        return flask.Response(response=dt.png_to_msg(loading_image), status=201)
    # operation not permitted
    return flask.Response(status=403)

@app.route('/rc/<picture_id>')
def callback_rc(picture_id):
    if request.method == "GET":
        if picture_id in rc_data:
            return flask.Response(response=rc_data[picture_id], status=201)
        rc_data[picture_id] = dt.get_thermal_model(picture_id)
        return flask.Response(response=rc_data[picture_id], status=201)
    # operation not permitted
    return flask.Response(status=403)

if __name__ == "__main__":
    app.run("localhost", 6969)