from flask import Flask, jsonify, request
from modAL.models import ActiveLearner


app = Flask(__name__)

@app.route("/server", methods=["POST"])
def response():
    print(request.form)
    query = dict(request.form)['query']
    res = query + " " + time.ctime()
    return jsonify({"response" : res})

@app.route("/server", methods=["GET"])
def checkNewDataAvailable():
    return jsonify(["Test"])



if __name__ == "__main__":
    app.run()