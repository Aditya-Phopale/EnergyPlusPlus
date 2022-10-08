# https://tms-dev-blog.com/python-backend-with-javascript-frontend-how-to/

from flask import Flask, request
import flask
import json
from flask_cors import CORS

import detection_tools as dt

app = Flask(__name__)
CORS(app)

@app.route('/', methods=["POST"]) # new endpoint
def callback():
    print("user endpoint reached...")
    if request.method == "POST":
        received_data = request.get_json()
        return_data = {
            "status": "success"
        }
        
        floor_plan = dt.msg_to_png(received_data)
        rooms_image, labels = dt.detect_rooms(floor_plan)

        # send image to front to display

        return flask.Response(response=return_data, status=201)

if __name__ == "__main__":
    app.run("localhost", 6969)