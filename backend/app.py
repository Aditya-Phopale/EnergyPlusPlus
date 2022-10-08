# https://tms-dev-blog.com/python-backend-with-javascript-frontend-how-to/

from flask import Flask, request
import flask
import json
from flask_cors import CORS

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
        # add boxes and return boxed image?
        # dummy "OK" responce for now

        # filter_preprocess()
        # image, labels = yolov5() maybe save image for us
        # send image to front to display

        return flask.Response(response=return_data, status=201)

if __name__ == "__main__":
    app.run("localhost", 6969)