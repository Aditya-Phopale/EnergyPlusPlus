# https://tms-dev-blog.com/python-backend-with-javascript-frontend-how-to/
# https://github.com/josephlee94/intuitive-deep-learning/blob/master/Building%20a%20Web%20Application%20to%20Deploy%20Machine%20Learning%C2%A0Models/imgrec_webapp.py

from flask import Flask, request
from flask_cors import CORS
from PIL import Image

import detection_tools as dt

app = Flask(__name__)
CORS(app)

# buffers
rooms_image = dict()
connectivity = dict()
rc_data = dict()

# if data unavailable yet TODO
loading_image = Image.open("detection_and_connectivity/loading.png")


@app.route('/image/<picture_id>', methods = ['PUT'])
def callback(picture_id):
    if request.method == "PUT":
        # extract an image from the request
        received_data = request.get_json()
        floor_plan = dt.msg_to_png(received_data)
        print("received a new floor " + str(picture_id))
        # run yolo v5 simulation
        rooms_image[picture_id] = dt.detect_rooms(floor_plan)
        print("detected rooms on " + str(picture_id))
        # return success
        return flask.Response(response={"status":"success"}, status=201)
    # operation not permitted
    return flask.Response(status=403)


@app.route('/rooms/<picture_id>')
def callback_rooms(picture_id):
    if request.method == "GET":
        # check if rooms already saved
        if picture_id in rooms_image:
            return flask.Response(response=dt.png_to_msg(rooms_image[picture_id]), status=201)
        # rooms not detected yet
        return flask.Response(response=dt.png_to_msg(loading_image), status=201)
    # operation not permitted
    return flask.Response(status=403)

@app.route('/rc/<picture_id>')
def callback_rc(picture_id):
    # assuming that user input is sequential (connectivity.json was never overwritten)
    # TODO: make julia code receive connectivity.json as a parameter
    if request.method == "GET":
        # check if rc data is already in the base
        if picture_id in rc_data:
            return flask.Response(response=rc_data[picture_id], status=201)
        # calculate rc modelling
        rc_data[picture_id], connectivity[picture_id] = dt.run_thermal_model()
        return flask.Response(response=rc_data[picture_id], status=201)
    # operation not permitted
    return flask.Response(status=403)

if __name__ == "__main__":
    app.run("localhost", 6969)