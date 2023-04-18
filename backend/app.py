# https://tms-dev-blog.com/python-backend-with-javascript-frontend-how-to/
# https://github.com/josephlee94/intuitive-deep-learning/blob/master/Building%20a%20Web%20Application%20to%20Deploy%20Machine%20Learning%C2%A0Models/imgrec_webapp.py

from flask import Flask, request, send_file
import flask
from flask_cors import CORS
from PIL import Image

import detection_tools as dt

app = Flask(__name__)
CORS(app)

# buffers
base_image = dict()
rooms_image = dict()
connectivity = dict()
rc_data = dict()

loading_img = "./detection_and_connectivity/images/loading.png"


# runs all of the code on a single image
@app.route('/image/<picture_id>', methods = ['POST'])
def callback(picture_id):
    if request.method == "POST":
        print(" -> started processing " + picture_id)
        image_data_xml = request.data  # modify, when stats are also in this call
        floor_plan = dt.msg_to_img(image_data_xml)
        base_image[picture_id] = floor_plan

        rooms_image[picture_id] = dt.detect_rooms(floor_plan)
        print(" -> detected rooms on " + picture_id)

        rc_data[picture_id], connectivity[picture_id] = dt.run_thermal_model()
        print(" -> ran thermal modelling on " + picture_id)

        return flask.Response(response={"status":"success"}, status=201)
    return flask.Response(status=403)  # operation not permitted


# fetches modelling data for result page
@app.route('/model/rooms/<picture_id>')
def callback_rooms(picture_id):
    if request.method == "GET":
        if picture_id in rooms_image:
            return None # flask.Responce(responce=)
        return send_file(loading_img, mimetype='image/gif')
    return flask.Response(status=403)  # operation not permitted


@app.route('/model/graph/<picture_id>')
def callback_graph(picture_id):
    if request.method == "GET":
        if picture_id in connectivity:
            return None # flask.Responce(responce=)
        return send_file(loading_img, mimetype='image/gif')
    return flask.Response(status=403)  # operation not permitted


@app.route('/model/rc/<picture_id>')
def callback_rc(picture_id):
    if request.method == "GET":
        if picture_id in rc_data:
            return None # flask.Responce(responce=)
        return send_file(loading_img, mimetype='image/png')
    return flask.Response(status=403)  # operation not permitted


if __name__ == "__main__":
    app.run("localhost", 6969)