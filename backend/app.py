# https://tms-dev-blog.com/python-backend-with-javascript-frontend-how-to/

from flask import Flask, request
import flask
import json
from flask_cors import CORS
import julia    #https://stackoverflow.com/questions/49750067/running-julia-jl-file-in-python

import matplotlib.pyplot as plt
import detection_tools as dt

app = Flask(__name__)
CORS(app)

rooms_image = None
labels = None

@app.route('/image', methods=["POST"])
def callback():
    print("user endpoint reached...")
    if request.method == "POST":
        received_data = request.get_json()
        return_data = {
            "status": "success"
        }
        print("before conversion")
        #TODO: make the conversion work and print it back
        floor_plan = dt.msg_to_png(received_data)
        print("after conversion")
        rooms_image, labels = dt.detect_rooms(floor_plan)
        return flask.Response(response=return_data, status=201)


@app.route('/rooms', methods=["GET"])
def callback_rooms():
    print("user endpoint rooms reached...")
    if request.method == "GET":
        print("GET request worked")
        
        return_data = {
            # picture generation from yolo converted to msg
            "status":"success"
        }

        return flask.Response(response=return_data, status=201)

@app.route('/rc', methods=["GET"])
def callback_rc():
    print("user endpoint rc reached...")
    if request.method == "GET":
        # execute julia -> plot.png is updated 
        print("GET request went through")
        j = julia.Julia()
        j.include("./2R1C_simulation/wall_function.jl")
        print("execution of julia finished")

        # return the results to frontend 
        return_data = {
            # picture generation from rc converted to msg
            "status":"success"
        }

        return flask.Response(response=return_data, status=201)

if __name__ == "__main__":
    app.run("localhost", 6969)